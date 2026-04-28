//
//  ExercisePickerView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 21.04.26.
//

import SwiftUI

struct ExercisePickerView: View {
    @State private var viewModel: ExercisePickerViewModel

    @Environment(\.dismiss)
    private var dismiss

    private let onAdd: (OrderedSet<ExerciseModel>) -> Void

    @State private var isAddingNewExercise: Bool = false

    init(
        viewModel: ExercisePickerViewModel,
        onAdd: @escaping (OrderedSet<ExerciseModel>) -> Void
    ) {
        _viewModel = .init(initialValue: viewModel)
        self.onAdd = onAdd
    }

    @ViewBuilder
    private func exerciseRow(_ exercise: ExerciseModel) -> some View {
        ExercisePickerRowView(
            exercise: exercise,
            order: viewModel.selectedOrder(exercise)
        )
        .onRowTap {
            viewModel.toggle(exercise)
        }
    }

    @ViewBuilder private var emptyState: some View {
        if viewModel.filteredExercises.isEmpty {
            if !viewModel.searchText.isEmpty {
                ContentUnavailableView.search
            } else {
                ExerciseLibraryEmptyView()
            }
        }
    }

    @ViewBuilder private var addExerciseSheet: some View {
        AddEditExerciseView { exercise in
            Task {
                await viewModel.createAndSelectExercise(exercise)
            }
        }
        .presentationDetents([.fraction(2 / 3)])
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(id: "exercise.library.pick.add", placement: .bottomBar) {
            AddBottomBarButton(with: AppLocalization.addExercise) {
                isAddingNewExercise = true
            }
        }

        ToolbarItem(
            id: "exercise.library.pick.cancel",
            placement: .topBarLeading
        ) {
            AdaptiveCancelButton {
                dismiss()
            }
        }

        ToolbarItem(
            id: "exercise.library.pick.done",
            placement: .topBarTrailing
        ) {
            AdaptiveConfirmButton {
                onAdd(viewModel.selectedExercises)
            }
            .disabled(viewModel.selectedExercises.isEmpty)
        }
    }

    var content: some View {
        List(viewModel.filteredExercises, id: \.id) {
            exerciseRow($0)
        }
        .animation(
            .easeInOut(duration: 0.3),
            value: viewModel.filteredExercises.map { $0.id }
        )
    }

    var body: some View {
        NavigationStack {
            content
            .scrollDismissesKeyboard(.interactively)
            .environment(\.defaultMinListRowHeight, 80)
            .overlay { emptyState }
            .navigationTitle(AppLocalization.pickExerciseFromLibrary)
            .toolbar { toolbar }
            .searchable(
                text: $viewModel.searchText,
                prompt: AppLocalization.searchExercise
            )
            .sheet(isPresented: $isAddingNewExercise) {
                addExerciseSheet
            }
            .alert(
                AppLocalization.error,
                isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.clearError() } }
                )
            ) {
                Button(AppLocalization.okay) { viewModel.clearError() }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
            .onAppear {
                Task {
                    await viewModel.loadExercises()
                }
            }
        }
    }
}

#Preview {
    ExercisePickerView(
        viewModel: ExercisePickerViewModel(
            repository: MockExerciseRepository()
        )
    ) { _ in
    }
}

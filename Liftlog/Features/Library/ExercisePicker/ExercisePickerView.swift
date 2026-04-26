//
//  ExercisePickerView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 21.04.26.
//

import SwiftUI

struct ExercisePickerView: View {
    @State private var viewModel: ExercisePickerViewModel
    @Environment(\.dismiss) private var dismiss

    init(
        viewModel: ExercisePickerViewModel,
        onAdd: (OrderedSet<ExerciseModel>) -> Void
    ) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    @ViewBuilder
    private func exerciseRow(_ exercise: ExerciseModel) -> some View {
        ExerciseRowView(
            exercise: exercise
        )
        .onRowTap {
            viewModel.toggle(exercise)
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if viewModel.filteredExercises.isEmpty {
            if !viewModel.searchText.isEmpty {
                ContentUnavailableView.search
            } else {
                ExerciseLibraryEmptyView()
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
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
                //TODO: implement selection confirmation
            }
        }
    }

    var body: some View {
        NavigationStack {
            List(viewModel.filteredExercises, id: \.id) {
                exerciseRow($0)
            }
            .animation(
                .easeInOut(duration: 0.3),
                value: viewModel.filteredExercises.map { $0.id }
            )
            .scrollDismissesKeyboard(.interactively)
            .environment(\.defaultMinListRowHeight, 80)
            .overlay { emptyState }
            .navigationTitle(
                String(
                    localized: "Pick Exercise from the Library"
                )
            )
            .toolbar { toolbar }
            .searchable(
                text: $viewModel.searchText,
                prompt: String(
                    localized: "Search Exercise"
                )
            )
            .alert(
                String(localized: "Error"),
                isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.nullifyError() } }
                )
            ) {
                Button("OK") { viewModel.nullifyError() }
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
        ),
        onAdd: { _ in
        }
    )
}

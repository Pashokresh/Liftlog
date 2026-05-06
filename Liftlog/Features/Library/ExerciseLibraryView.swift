//
//  ExerciseLibraryView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import SwiftUI

struct ExerciseLibraryView: View {
    @State private var viewModel: ExerciseLibraryViewModel

    @State private var isAddingExercise = false
    @State private var exerciseToDelete: ExerciseModel?

    init(
        viewModel: ExerciseLibraryViewModel
    ) {
        _viewModel = .init(
            initialValue: viewModel
        )
    }

    @ViewBuilder
    private func exerciseRow(_ exercise: ExerciseModel) -> some View {
        ExerciseRowView(
            exercise: exercise
        )
        .onRowTap {
            viewModel.editingExercise = exercise
        }
        .swipeActions {
            SwipeDeleteButton {
                exerciseToDelete = exercise
            }

            SwipeEditButton {
                viewModel.editingExercise = exercise
            }
        }
        .deleteConfirmation(item: $exerciseToDelete) { exercise in
            viewModel.deleteExercise(exercise)
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

    @ToolbarContentBuilder private var listToolbar: some ToolbarContent {
        ToolbarItem(
            id: "exercise.library.add.new",
            placement: .automatic
        ) {
            AddTopBarButton {
                isAddingExercise = true
            }
        }
    }

    @ViewBuilder private var addExerciseSheet: some View {
        AddEditExerciseView { exercise in
            viewModel.createExercise(exercise)
        }
        .presentationDetents([.fraction(2 / 3)])
    }

    @ViewBuilder
    private func editExerciseSheet(_ exercise: ExerciseModel) -> some View {
        AddEditExerciseView(exercise: exercise) { updatedExercise in
            viewModel.updateExercise(updatedExercise)
        }
        .presentationDetents([.fraction(2 / 3)])
    }

    var body: some View {
        List {
            ForEach(viewModel.exercisesByMuscleGroup, id: \.group) { item in
                Section {
                    ForEach(item.exercises) {
                        exerciseRow($0)
                    }
                } header: {
                    Text(
                        item.group?.localizedName ?? AppLocalization.otherGroup
                    )
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }
        }
        .animation(
            .easeInOut(duration: 0.3),
            value: viewModel.filteredExercises.map { $0.id }
        )
        .scrollDismissesKeyboard(.interactively)
        .overlay { emptyState }
        .navigationTitle(
            AppLocalization.exerciseLibrary
        )
        .toolbar { listToolbar }
        .searchable(
            text: $viewModel.searchText,
            prompt: AppLocalization.searchExercise
        )
        .sheet(isPresented: $isAddingExercise) { addExerciseSheet }
        .sheet(item: $viewModel.editingExercise) { editExerciseSheet($0) }
        .alert(
            AppLocalization.error,
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.nullifyError() } }
            )
        ) {
            Button(AppLocalization.okay) { viewModel.nullifyError() }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
        .onAppear {
            viewModel.onApper()
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseLibraryView(
            viewModel: ExerciseLibraryViewModel(
                repository: MockExerciseRepository()
            )
        )
    }
}

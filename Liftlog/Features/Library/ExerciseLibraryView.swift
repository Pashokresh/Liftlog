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
            Task {
                await viewModel.deleteExercise(exercise.id)
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if viewModel.filteredExercises.isEmpty {
            if !viewModel.searchText.isEmpty {
                ContentUnavailableView.search
            } else {
                UnavailableContentView(
                    title: String(
                        localized: "No exercises in the library yet."
                    ),
                    message: String(
                        localized: "Tap \"+\" to add a new one."
                    )
                )
            }
        }
    }

    @ToolbarContentBuilder
    private var listToolbar: some ToolbarContent {
        ToolbarItem(
            id: "exercise.library.add.new",
            placement: .automatic
        ) {
            AddTopBarButton {
                isAddingExercise = true
            }
        }
    }

    @ViewBuilder
    private var addExerciseSheet: some View {
        AddEditExerciseView { exercise in
            Task {
                await viewModel.createExercise(
                    name: exercise.name,
                    type: exercise.type,
                    description: exercise.description
                )
            }
        }
        .presentationDetents([.fraction(2 / 3)])
    }

    @ViewBuilder
    private func editExerciseSheet(_ exercise: ExerciseModel) -> some View {
        AddEditExerciseView(exercise: exercise) { updatedExercise in
            Task {
                await viewModel.updateExercise(updatedExercise)
            }
        }
        .presentationDetents([.fraction(2 / 3)])
    }

    var body: some View {
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
                localized: "Exercise Library"
            )
        )
        // TODO: Fix white navigation bar background on search
        .toolbar { listToolbar }
        .searchable(
            text: $viewModel.searchText,
            prompt: String(
                localized: "Search Exercise"
            )
        )
        .sheet(isPresented: $isAddingExercise) { addExerciseSheet }
        .sheet(item: $viewModel.editingExercise) { editExerciseSheet($0) }
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

#Preview {
    NavigationStack {
        ExerciseLibraryView(
            viewModel: ExerciseLibraryViewModel(
                repository: MockExerciseRepository()
            )
        )
    }
}

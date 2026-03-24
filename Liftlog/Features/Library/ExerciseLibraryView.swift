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
    @State private var searchText = ""

    let onSelect: ((ExerciseModel) -> Void)?

    init(
        viewModel: ExerciseLibraryViewModel,
        onSelect: ((ExerciseModel) -> Void)? = nil
    ) {
        _viewModel = .init(
            initialValue: viewModel
        )

        self.onSelect = onSelect
    }

    private var filteredExercises: [ExerciseModel] {
        guard !searchText.isEmpty else { return viewModel.exercises }
        return viewModel.exercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var navigationContent: some View {
        List(filteredExercises, id: \.id) {
            exerciseRow($0)
        }
        .animation(
            .easeInOut(duration: 0.3),
            value: filteredExercises.map { $0.id }
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
            text: $searchText,
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

    @ViewBuilder
    private func exerciseRow(_ exercise: ExerciseModel) -> some View {
        ExerciseRowView(
            exercise: exercise
        )
        .onRowTap {
            if let onSelect = onSelect {
                onSelect(exercise)
            } else {
                viewModel.editingExercise = exercise
            }
        }
        .swipeActions {
            if onSelect == nil {
                SwipeDeleteButton {
                    Task {
                        await viewModel.deleteExercise(exercise.id)
                    }
                }

                SwipeEditButton {
                    viewModel.editingExercise = exercise
                }
            }
        }
    }

    @ViewBuilder
    private var emptyState: some View {
        if filteredExercises.isEmpty {
            if !searchText.isEmpty {
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
        if onSelect != nil {
            NavigationStack {
                navigationContent
            }
        } else {
            navigationContent
        }
    }
}

#Preview {
    ExerciseLibraryView(
        viewModel: ExerciseLibraryViewModel(
            repository: MockExerciseRepository()
        ),
        onSelect: { _ in }
    )
}

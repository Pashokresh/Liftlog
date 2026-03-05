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
        List {
            ForEach(filteredExercises) { exercise in
               ExerciseRowView(exercise: exercise)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect?(exercise)
                    }
                .swipeActions {
                    if onSelect == nil {
                        SwipeDeleteButton {
                            viewModel.deleteExercise(exercise.id)
                        }
                        SwipeEditButton {
                            viewModel.editingExercise = exercise
                        }
                    }
                }
            }
        }
        .animation(
            .easeInOut(duration: 0.3),
            value: filteredExercises.map { $0.id }
        )
        .scrollDismissesKeyboard(.interactively)
        .environment(\.defaultMinListRowHeight, 80)
        .overlay {
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
        .navigationTitle(
            String(
                localized: "Exercise Library"
            )
        )
        // TODO: Fix white navigation bar background on search
        .toolbar {
            ToolbarItem(
                id: "exercise.library.add.new",
                placement: .automatic
            ) {
                AddTopBarButton {
                    isAddingExercise = true
                }
            }
        }
        .searchable(
            text: $searchText,
            prompt: String(
                localized: "Search Exercise"
            )
        )
        .sheet(isPresented: $isAddingExercise) {
            AddEditExerciseView {
                viewModel.createExercise(
                    name: $0.name,
                    type: $0.type,
                    description: $0.description
                )
            }
            .presentationDetents([.fraction(2/3)])
        }
        .sheet(item: $viewModel.editingExercise) {
            AddEditExerciseView(exercise: $0) {
                viewModel.updateExercise($0)
            }
            .presentationDetents([.fraction(2/3)])
        }
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
            viewModel.loadExercises()
        }
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

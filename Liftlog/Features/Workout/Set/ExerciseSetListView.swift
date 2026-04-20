//
//  ExerciseSetListView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 02.03.26.
//

import SwiftUI

struct ExerciseSetListView: View {

    @State private var viewModel: ExerciseSetViewModel
    @State private var isAddingNewSet = false
    @State private var setToDelete: ExerciseSetModel?

    init(viewModel: ExerciseSetViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }

    @ViewBuilder
    var currentWorkoutSection: some View {
        Section {
            if !viewModel.workoutExercise.sets.isEmpty {
                ForEach(
                    Array(viewModel.workoutExercise.sets.enumerated()),
                    id: \.element.id
                ) { index, set in
                    SetRowView(
                        set: set,
                        number: index + 1,
                        copySet: {
                            Task {
                                await viewModel.copySet(set)
                            }
                        }
                    )
                    .onRowTap {
                        viewModel.setToEdit = set
                    }
                    .swipeActions {
                        SwipeDeleteButton {
                            setToDelete = set
                        }

                        SwipeEditButton {
                            viewModel.setToEdit = set
                        }
                    }
                }
            } else {
                noSetsPlaceholder
            }
        } header: {
            Text(String(localized: "Current workout"))
        }
    }

    var historyWorkoutSection: some View {
        ForEach(viewModel.history) { historyExercise in
            Section {
                ForEach(
                    Array(historyExercise.sets.enumerated()),
                    id: \.element.id
                ) { index, set in
                    SetRowView(
                        set: set,
                        number: index + 1,
                        copySet: {
                            Task {
                                await viewModel.copySet(set)
                            }
                        }
                    )
                }
            } header: {
                HStack(spacing: 8) {
                    Text(historyExercise.workoutName)
                    Text("·")
                    Text(
                        historyExercise.date.formatted(
                            date: .abbreviated,
                            time: .omitted
                        )
                    )
                }
            }
        }
    }

    var noSetsPlaceholder: some View {
        UnavailableContentView(
            title: String(localized: "No Sets yet"),
            message: String(localized: "Start by adding sets here")
        )
    }
    
    private var addSetSheet: some View {
        AddEditSetView(
            exerciseType: viewModel.workoutExercise.exercise.type,
            existingSet: nil,
            onSave: { newSet in
                Task {
                    await viewModel.addSet(set: newSet)
                }
            }
        )
        .presentationDetents([.fraction(CGFloat(2 / 3))])
        .presentationDragIndicator(.visible)
    }
    
    private func editSetSheet(_ setToEdit: ExerciseSetModel) -> some View {
        AddEditSetView(
            exerciseType: viewModel.workoutExercise.exercise.type,
            existingSet: setToEdit,
            onSave: { updatedSet in
                Task {
                    await viewModel.updateSet(updatedSet)
                }
            }
        )
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    var body: some View {
        List {
            // Current workout sets
            currentWorkoutSection

            // History sets
            historyWorkoutSection
        }
        .scrollDismissesKeyboard(.interactively)
        .environment(\.defaultMinListRowHeight, 80)
        .navigationTitle(viewModel.workoutExercise.exercise.name)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                AddBottomBarButton(
                    with: String(localized: "Add set")
                ) {
                    isAddingNewSet = true
                }
            }
        }
        .sheet(isPresented: $isAddingNewSet) { addSetSheet }
        .sheet(item: $viewModel.setToEdit) { editSetSheet($0) }
        .deleteConfirmation(item: $setToDelete) { set in
            Task {
                await viewModel.deleteSet(set.id)
            }
        }
        .alert(
            String(localized: "Error"),
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.nullifyError() } }
            )
        ) {
            Button("OK") {
                viewModel.nullifyError()
            }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "Unknown error")
        }
        .task {
            await viewModel.loadHistory()
        }
    }
}

#Preview {
    NavigationStack {
        ExerciseSetListView(
            viewModel: ExerciseSetViewModel(
                workoutExercise: WorkoutExerciseModel.mock,
                workoutRepository: MockWorkoutRepository(),
                exerciseRepository: MockExerciseRepository()
            )
        )
    }
}

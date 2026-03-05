//
//  ExerciseSetListView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 02.03.26.
//

import SwiftUI

struct ExerciseSetListView: View {

    @State var viewModel: ExerciseSetViewModel
    @State var isAddingNewSet = false

    init(viewModel: ExerciseSetViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }

    @ViewBuilder
    var currentWorkoutSection: some View {
        Section {
            if !viewModel.workoutExercise.sets.isEmpty {
                ForEach(viewModel.workoutExercise.sets) { set in
                    SetRowView(set: set, copySet: {
                        Task {
                            await viewModel.copySet(set)
                        }
                    })
                        .swipeActions {
                            SwipeDeleteButton {
                                Task {
                                    await viewModel.deleteSet(set.id)
                                }
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
                ForEach(historyExercise.sets) { set in
                    SetRowView(set: set, copySet: {
                        Task {
                            await viewModel.copySet(set)
                        }
                    })
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
        .sheet(isPresented: $isAddingNewSet) {
            AddEditSetView(
                exerciseType: viewModel.workoutExercise.exercise.type,
                existingSet: nil,
                onSave: { newSet in
                    Task {
                        await viewModel.addSet(set: newSet)
                    }
                }
            )
            .presentationDetents([.fraction(2 / 3)])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $viewModel.setToEdit) { set in
            AddEditSetView(
                exerciseType: viewModel.workoutExercise.exercise.type,
                existingSet: set,
                onSave: { updatedSet in
                    Task {
                        await viewModel.updateSet(updatedSet)
                    }
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
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

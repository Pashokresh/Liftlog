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

    private func setRow(with set: ExerciseSetModel, at index: Int?) -> some View {
        var displayIndex: Int?
        if let index = index {
            displayIndex = index + 1
        }

        return SetRowView(
            setItem: set,
            number: displayIndex
        ) {
            Task {
                await viewModel.copySet(set)
            }
        }
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

    @ViewBuilder var warmupSetsSection: some View {
        if !viewModel.warmupSets.isEmpty {
            ForEach(
                viewModel.warmupSets,
                id: \.id
            ) { setRow(with: $0, at: nil) }
        }
    }

    @ViewBuilder var workingSetsSection: some View {
        if !viewModel.workingSets.isEmpty {
            ForEach(
                Array(viewModel.workingSets.enumerated()),
                id: \.element.id
            ) { setRow(with: $1, at: $0) }
        }
    }

    @ViewBuilder var currentWorkoutSection: some View {
        Section {
            if !viewModel.warmupSets.isEmpty
                || !viewModel.workingSets.isEmpty {
                warmupSetsSection

                workingSetsSection
            } else {
                noSetsPlaceholder
            }
        } header: {
            Text(AppLocalization.currentWorkout)
        }
    }

    var historyWorkoutSection: some View {
        ForEach(viewModel.history) { historyExercise in
            Section {
                ForEach(
                    historyExercise.sets.filter({ $0.isWarmup }),
                    id: \.id
                ) { set in
                    SetRowView(
                        setItem: set,
                        number: nil
                    ) {
                        Task {
                            await viewModel.copySet(set)
                        }
                    }
                }

                ForEach(
                    Array(
                        historyExercise.sets.filter({ !$0.isWarmup })
                            .enumerated()
                    ),
                    id: \.element.id
                ) { index, set in
                    SetRowView(
                        setItem: set,
                        number: index + 1
                    ) {
                        Task {
                            await viewModel.copySet(set)
                        }
                    }
                }
            } header: {
                HStack(spacing: 8) {
                    Text(historyExercise.workoutName)
                    Text("·")
                    Image(
                        systemName: Images.calendar(
                            day: Calendar.current.component(
                                .day,
                                from: historyExercise.date
                            )
                        )
                    )
                    Text(
                        "\(historyExercise.date.formatted(date: .abbreviated, time: .omitted))"
                    )
                }
            }
        }
    }

    var noSetsPlaceholder: some View {
        UnavailableContentView(
            title: AppLocalization.noSetsYet,
            message: AppLocalization.startByAddingSetsHere
        )
    }

    private var addSetSheet: some View {
        AddEditSetView(
            exerciseType: viewModel.workoutExercise.exercise.type,
            existingSet: nil
        ) { newSet in
            Task {
                await viewModel.addSet(set: newSet)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private func editSetSheet(_ setToEdit: ExerciseSetModel) -> some View {
        AddEditSetView(
            exerciseType: viewModel.workoutExercise.exercise.type,
            existingSet: setToEdit
        ) { updatedSet in
            Task {
                await viewModel.updateSet(updatedSet)
            }
        }
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
        .navigationTitle(viewModel.workoutExercise.exercise.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AddTopBarButton {
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
            AppLocalization.error,
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.nullifyError() } }
            )
        ) {
            Button(AppLocalization.okay) {
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

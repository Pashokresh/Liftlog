//
//  WorkoutDetailView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import SwiftUI

struct WorkoutDetailView: View {

    @Environment(ViewModelFactory.self) private var viewModelFactory

    @State private var viewModel: WorkoutDetailViewModel
    @State private var isAddingExercise = false

    init(viewModel: WorkoutDetailViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(viewModel.workout.exercises) { exercise in
                NavigationLink(
                    value: Route.exerciseSet(exercise),
                    label: {
                        WorkoutDetailRow(workoutExercise: exercise)
                    }
                )
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    Task {
                        await viewModel.deleteExercise(
                            viewModel.workout.exercises[index].id
                        )
                    }
                }
            }
            .onMove { source, destination in
                Task {
                    await viewModel.moveExercise(
                        fromSource: source,
                        to: destination
                    )
                }
            }
        }
        .environment(\.defaultMinListRowHeight, 80)
        .navigationTitle(viewModel.workout.name)
        .navigationSubtitle(
            viewModel.workout.date.formatted(date: .abbreviated, time: .omitted)
        )
        .toolbar {
            if !viewModel.workout.exercises.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }

            ToolbarItem(placement: .bottomBar) {
                AddBottomBarButton(
                    with: String(localized: "Add Exercise")
                ) {
                    isAddingExercise = true
                }
            }
        }
        .overlay {
            if viewModel.workout.exercises.isEmpty {
                ContentUnavailableView(
                    String(localized: "No Exercises yet"),
                    systemImage: Images.figureStrengthTraining,
                    description: Text(
                        String(localized: "Start by adding exercises here")
                    )
                )
            }
        }
        .sheet(isPresented: $isAddingExercise) {
            ExerciseLibraryView(
                viewModel: viewModelFactory.makeExerciseLibraryViewModel(),
                onSelect: { exercise in
                    Task {
                        await viewModel.addExercise(exercise)
                    }
                    isAddingExercise = false
                }
            )
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
            Text(viewModel.error?.localizedDescription ?? "")
        }
        .onAppear {
            Task {
                await viewModel.reloadWorkout()
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(
            viewModel: WorkoutDetailViewModel(
                workout: WorkoutModel.mock,
                repository: MockWorkoutRepository()
            )
        )
    }
    .environment(
        ViewModelFactory(
            dependencies: AppDependencies.mock
        )
    )
}

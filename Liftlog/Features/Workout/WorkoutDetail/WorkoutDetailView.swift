//
//  WorkoutDetailView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import SwiftUI

struct WorkoutDetailView: View {
    @Environment(ViewModelFactory.self)
    private var viewModelFactory

    @State private var viewModel: WorkoutDetailViewModel
    @State private var isAddingExercise = false

    init(viewModel: WorkoutDetailViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
        if !viewModel.workout.exercises.isEmpty {
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
        }

        ToolbarItem(placement: .topBarTrailing) {
            AddTopBarButton {
                isAddingExercise = true
            }
        }
    }

    @ViewBuilder private var emptyState: some View {
        if viewModel.workout.exercises.isEmpty {
            ContentUnavailableView(
                AppLocalization.noExercisesYet,
                systemImage: Images.figureStrengthTraining,
                description: Text(AppLocalization.startByAddingExercisesHere)
            )
        }
    }

    private var exerciseLibrarySheet: some View {
        ExercisePickerView(
            viewModel: viewModelFactory.makeExercisePickerViewModel()
        ) { newExercises in
            viewModel.addExercises(newExercises.elements)
        }
    }

    var body: some View {
        List {
            ForEach(viewModel.workout.exercises) { exercise in
                NavigationLink(
                    value: Route.exerciseSet(exercise)
                ) {
                    WorkoutDetailRow(workoutExercise: exercise)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    viewModel.deleteExercise(viewModel.workout.exercises[index].id)
                }
            }
            .onMove { source, destination in
                viewModel.moveExercise(fromSource: source, to: destination)
            }
        }
        .navigationTitle(viewModel.workout.name)
        .adaptiveNavigationSubtitle(
            viewModel.workout.date.formatted(date: .abbreviated, time: .omitted)
        )
        .toolbar { toolbarContent }
        .overlay { emptyState }
        .sheet(isPresented: $isAddingExercise) { exerciseLibrarySheet }
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
            Text(viewModel.error?.localizedDescription ?? "")
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(
            viewModel: WorkoutDetailViewModel(
                workout: WorkoutModel.mock,
                repository: MockWorkoutRepository(workouts: WorkoutModel.mocks),
                addExercisesUseCase: AppDependencies.mock.addExercisesToWorkoutUseCase
            )
        )
    }
    .environment(
        ViewModelFactory(
            dependencies: .mock
        )
    )
}

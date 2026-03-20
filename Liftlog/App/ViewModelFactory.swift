//
//  ViewModelFactory.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import Foundation

@Observable
final class ViewModelFactory {

    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func makeWorkoutListViewModel() -> WorkoutListViewModel {
        WorkoutListViewModel(
            workoutRepository: dependencies.workoutRepository,
            tagRepository: dependencies.tagRepository
        )
    }

    func makeExerciseLibraryViewModel() -> ExerciseLibraryViewModel {
        ExerciseLibraryViewModel(repository: dependencies.exerciseRepository)
    }

    func makeWorkoutDetailViewModel(_ workout: WorkoutModel)
        -> WorkoutDetailViewModel
    {
        WorkoutDetailViewModel(
            workout: workout,
            repository: dependencies.workoutRepository
        )
    }

    func makeExerciseSetViewModel(workoutExercise: WorkoutExerciseModel)
        -> ExerciseSetViewModel
    {
        ExerciseSetViewModel(
            workoutExercise: workoutExercise,
            workoutRepository: dependencies.workoutRepository,
            exerciseRepository: dependencies.exerciseRepository
        )
    }

    func makeAddEditWorkoutViewModel(workout: WorkoutModel? = nil)
        -> AddEditWorkoutViewModel
    {
        AddEditWorkoutViewModel(
            tagRepository: dependencies.tagRepository,
            workout: workout
        )
    }
}

extension ViewModelFactory {
    static let mock = ViewModelFactory(dependencies: .mock)
}

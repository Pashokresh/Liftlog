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
            tagRepository: dependencies.tagRepository,
            deleteWorkoutUseCase: dependencies.deleteWorkoutUseCase
        )
    }

    func makeExerciseLibraryViewModel() -> ExerciseLibraryViewModel {
        ExerciseLibraryViewModel(
            fetchExerciseLibraryUseCase: dependencies
                .fetchExerciseLibraryUseCase,
            manageExerciseUseCase: dependencies.manageExerciseUseCase
        )
    }

    func makeExercisePickerViewModel() -> ExercisePickerViewModel {
        ExercisePickerViewModel(
            fetchExerciseLibraryUseCase: dependencies
                .fetchExerciseLibraryUseCase,
            manageExerciseUseCase: dependencies.manageExerciseUseCase
        )
    }

    func makeWorkoutDetailViewModel(_ workout: WorkoutModel)
        -> WorkoutDetailViewModel {
        WorkoutDetailViewModel(
            workout: workout,
            workoutRepository: dependencies.workoutRepository,
            exerciseRepository: dependencies.workoutExerciseRepository,
            setRepository: dependencies.workoutSetRepository,
            addExercisesUseCase: dependencies.addExercisesToWorkoutUseCase
        )
    }

    func makeExerciseSetViewModel(workoutExercise: WorkoutExerciseModel)
        -> ExerciseSetViewModel {
        ExerciseSetViewModel(
            workoutExercise: workoutExercise,
            setRepository: dependencies.workoutSetRepository,
            exerciseRepository: dependencies.exerciseRepository
        )
    }

    func makeAddEditWorkoutViewModel(workout: WorkoutModel? = nil)
        -> AddEditWorkoutViewModel {
        AddEditWorkoutViewModel(
            tagRepository: dependencies.tagRepository,
            manageTagUseCase: dependencies.manageWorkoutTagsUseCase,
            workout: workout
        )
    }

    func makeExerciseProgressViewModel(exercise: ExerciseModel)
        -> ExerciseProgressViewModel {
        ExerciseProgressViewModel(
            exercise: exercise,
            fetchProgressUseCase: dependencies.fetchExerciseProgressUseCase
        )
    }
}

extension ViewModelFactory {
    static let mock = ViewModelFactory(dependencies: .mock)
}

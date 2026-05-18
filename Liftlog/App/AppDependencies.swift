//
//  AppDependencies.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.02.26.
//

import Foundation

final class AppDependencies {
    let exerciseRepository: ExerciseRepositoryProtocol
    let workoutRepository: WorkoutRepositoryProtocol
    let workoutExerciseRepository: WorkoutExerciseRepositoryProtocol
    let workoutSetRepository: WorkoutSetRepositoryProtocol
    let tagRepository: TagRepositoryProtocol

    let manageExerciseUseCase: ManageExerciseUseCaseProtocol
    let fetchExerciseLibraryUseCase: FetchExerciseLibraryUseCase
    let addExercisesToWorkoutUseCase: AddExercisesToWorkoutUseCaseProtocol
    let deleteWorkoutUseCase: DeleteWorkoutUseCaseProtocol
    let manageWorkoutTagsUseCase: ManageWorkoutTagsUseCaseProtocol
    let fetchExerciseProgressUseCase: FetchExerciseProgressUseCaseProtocol

    init(
        exerciseRepository: ExerciseRepositoryProtocol,
        workoutRepository: WorkoutRepositoryProtocol,
        workoutExerciseRepository: WorkoutExerciseRepositoryProtocol,
        workoutSetRepository: WorkoutSetRepositoryProtocol,
        tagRepository: TagRepositoryProtocol
    ) {
        self.exerciseRepository = exerciseRepository
        self.workoutRepository = workoutRepository
        self.workoutExerciseRepository = workoutExerciseRepository
        self.workoutSetRepository = workoutSetRepository
        self.tagRepository = tagRepository

        self.manageExerciseUseCase = ManageExerciseUseCase(
            repository: exerciseRepository
        )
        self.fetchExerciseLibraryUseCase = FetchExerciseLibraryUseCase(
            repository: exerciseRepository
        )

        self.addExercisesToWorkoutUseCase = AddExercisesToWorkoutUseCase(
            workoutRepository: workoutExerciseRepository
        )
        self.deleteWorkoutUseCase = DeleteWorkoutUseCase(
            workoutRepository: workoutRepository
        )
        self.manageWorkoutTagsUseCase = ManageWorkoutTagsUseCase(
            workoutRepository: workoutRepository,
            tagRepository: tagRepository
        )
        self.fetchExerciseProgressUseCase = FetchExerciseProgressUseCase(
            exerciseRepository: exerciseRepository
        )
    }
}

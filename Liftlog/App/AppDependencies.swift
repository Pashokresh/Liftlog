//
//  AppDependencies.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.02.26.
//

import CoreData
import Foundation

@Observable
final class AppDependencies {
    let exerciseRepository: ExerciseRepositoryProtocol
    let workoutRepository: WorkoutRepositoryProtocol
    let tagRepository: TagRepositoryProtocol

    let addExercisesToWorkoutUseCase: AddExercisesToWorkoutUseCaseProtocol

    init(persistenceController: PersistenceController = .shared) {
        let context = persistenceController.container.viewContext

        let exerciseRepository = CoreDataExerciseRepository(context: context)
        let tagRepository = CoreDataTagRepository(context: context)
        let workoutRepository = CoreDataWorkoutRepository(context: context)

        self.exerciseRepository = exerciseRepository
        self.workoutRepository = workoutRepository
        self.tagRepository = tagRepository

        self.addExercisesToWorkoutUseCase = AddExercisesToWorkoutUseCase(workoutRepository: workoutRepository)
    }

    // mock init
    init(
        exerciseRepository: ExerciseRepositoryProtocol,
        workoutRepository: WorkoutRepositoryProtocol,
        tagRepository: TagRepositoryProtocol
    ) {
        self.exerciseRepository = exerciseRepository
        self.workoutRepository = workoutRepository
        self.tagRepository = tagRepository

        self.addExercisesToWorkoutUseCase = AddExercisesToWorkoutUseCase(workoutRepository: workoutRepository)
    }
}

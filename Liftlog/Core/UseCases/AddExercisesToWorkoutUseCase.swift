//
//  AddExercisesToWorkoutUseCase.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Foundation

protocol AddExercisesToWorkoutUseCaseProtocol {
    func execute(
        exercises: [ExerciseModel],
        workoutID: UUID,
        currentExercises: [WorkoutExerciseModel]
    ) async throws -> [WorkoutExerciseModel]
}

final class AddExercisesToWorkoutUseCase: AddExercisesToWorkoutUseCaseProtocol {
    private let workoutRepository: WorkoutRepositoryProtocol

    init(workoutRepository: WorkoutRepositoryProtocol) {
        self.workoutRepository = workoutRepository
    }

    func execute(
        exercises: [ExerciseModel],
        workoutID: UUID,
        currentExercises: [WorkoutExerciseModel]
    ) async throws -> [WorkoutExerciseModel] {
        var exercisesToAdd: [WorkoutExerciseModel] = []
        var currentIDs = Set(currentExercises.map { $0.exercise.id })
        var duplicates: [ExerciseModel] = []

        var order = (currentExercises.last?.order ?? -1) + 1

        for exercise in exercises {
            if currentIDs.contains(exercise.id) {
                duplicates.append(exercise)
            } else {
                let workoutExercise = WorkoutExerciseModel(
                    id: UUID(),
                    order: order,
                    exercise: exercise,
                    sets: []
                )
                exercisesToAdd.append(workoutExercise)
                currentIDs.insert(exercise.id)
                order += 1
            }
        }

        guard !exercisesToAdd.isEmpty else {
            throw DomainError.duplicateExercise
        }

        try await workoutRepository.addExercises(exercisesToAdd, to: workoutID)

        return exercisesToAdd
    }
}

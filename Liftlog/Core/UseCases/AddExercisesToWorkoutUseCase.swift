//
//  AddExercisesToWorkoutUseCase.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Foundation

protocol AddExercisesToWorkoutUseCaseProtocol {
    /// Adds exercises to a workout, skipping any that are already present.
    ///
    /// Partial success is intentional: if the user selects 5 exercises and 3 are already in
    /// the workout, only the 2 new ones are added and returned. The operation throws
    /// `DomainError.duplicateExercise` only when *every* selected exercise is already present.
    ///
    /// New exercises are assigned sequential `order` values starting after the last existing one.
    ///
    /// - Returns: The newly added `WorkoutExerciseModel` items (never includes pre-existing ones).
    /// - Throws: `DomainError.duplicateExercise` if all exercises are already in the workout.
    func execute(
        exercises: [ExerciseModel],
        workoutID: UUID,
        currentExercises: [WorkoutExerciseModel]
    ) async throws -> [WorkoutExerciseModel]
}

final class AddExercisesToWorkoutUseCase: AddExercisesToWorkoutUseCaseProtocol {
    private let workoutRepository: WorkoutExerciseRepositoryProtocol

    init(workoutRepository: WorkoutExerciseRepositoryProtocol) {
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

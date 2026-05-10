//
//  WorkoutExerciseRepositoryProtocol.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

protocol WorkoutExerciseRepositoryProtocol: AnyObject {
    /// Persists the given exercises and appends them to the workout.
    ///
    /// The `order` field on each `WorkoutExerciseModel` is used as-is; callers are
    /// responsible for assigning sequential, non-conflicting values before calling this method.
    func addExercises(_ exercisesModel: [WorkoutExerciseModel], to workoutID: UUID)
        async throws

    func updateExercise(_ model: WorkoutExerciseModel, in workoutID: UUID)
        async throws

    func deleteExercise(_ id: UUID) async throws
}

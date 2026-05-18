//
//  WorkoutSetRepositoryProtocol.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

protocol WorkoutSetRepositoryProtocol: AnyObject {
    func addSet(_ setModel: ExerciseSetModel, to workoutExerciseID: UUID)
        async throws

    func updateSet(_ model: ExerciseSetModel) async throws

    func deleteSet(_ id: UUID) async throws
}

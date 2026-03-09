//
//  WorkoutRepositoryProtocol.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData
import Foundation

protocol WorkoutRepositoryProtocol {

    // MARK: - Methods working with Workout

    func fetchAll() async throws -> [WorkoutModel]
    
    func fetch(_ id: UUID) async throws -> WorkoutModel

    func create(_ workoutModel: WorkoutModel) async throws -> WorkoutModel

    func update(_ model: WorkoutModel) async throws

    func delete(_ id: UUID) async throws

    // MARK: - Methods working with exercises

    func addExercise(_ exerciseModel: WorkoutExerciseModel, to workoutID: UUID)
        async throws

    func updateExercise(_ model: WorkoutExerciseModel, in workoutID: UUID)
        async throws

    func deleteExercise(_ id: UUID) async throws

    // MARK: - Methods working with sets

    func addSet(_ setModel: ExerciseSetModel, to workoutExerciseID: UUID)
        async throws

    func updateSet(_ model: ExerciseSetModel) async throws

    func deleteSet(_ id: UUID) async throws
}

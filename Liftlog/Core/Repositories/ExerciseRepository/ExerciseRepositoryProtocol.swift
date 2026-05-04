//
//  ExerciseRepositoryProtocol.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation
import CoreData

protocol ExerciseRepositoryProtocol: AnyObject {
    func fetchAll() async throws -> [ExerciseModel]

    func fetchHistory(for exerciseID: UUID, excluding workoutExerciseID: UUID) async throws -> [ExerciseHistorySectionModel]

    func create(name: String, description: String?, type: ExerciseType, muscleGroup: ExerciseModel.MuscleGroup?) async throws -> ExerciseModel

    func update(_ model: ExerciseModel) async throws

    func delete(_ id: UUID) async throws

    func fetchProgress(for exerciseID: UUID, from startDate: Date) async throws -> [ExerciseProgressEntry]
}

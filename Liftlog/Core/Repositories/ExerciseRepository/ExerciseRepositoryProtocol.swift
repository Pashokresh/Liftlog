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

    func fetchHistory(for exerciseID: UUID, excluding workoutExerciseID: UUID) async throws -> [ExerciseHistorySection]

    func create(name: String, description: String?, type: ExerciseType) async throws -> ExerciseModel

    func update(_ model: ExerciseModel) async throws

    func delete(_ id: UUID) async throws
}

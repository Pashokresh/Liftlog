//
//  WorkoutRepositoryProtocol.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

protocol WorkoutRepositoryProtocol: AnyObject {
    func fetchAll() async throws -> [WorkoutModel]

    func fetch(_ id: UUID) async throws -> WorkoutModel

    func create(_ workoutModel: WorkoutModel) async throws -> WorkoutModel

    func update(_ model: WorkoutModel) async throws

    func delete(_ id: UUID) async throws
}

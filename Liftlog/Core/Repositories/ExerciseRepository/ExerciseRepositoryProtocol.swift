//
//  ExerciseRepositoryProtocol.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation
import CoreData

protocol ExerciseRepositoryProtocol {
    
    func fetchAll() async throws -> [ExerciseModel]
    
    func create(name: String, description: String?) async throws -> ExerciseModel
    
    func update(_ model: ExerciseModel) async throws
    
    func delete(_ id: UUID) async throws
}

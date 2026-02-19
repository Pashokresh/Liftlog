//
//  ExerciseRepositoryProtocol.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

protocol ExerciseRepositoryProtocol {
    
    func fetchAll() throws -> [ExerciseModel]
    
    func create(name: String, description: String?) throws -> ExerciseModel
    
    func update(_ model: ExerciseModel) throws
    
    func delete(_ id: UUID) throws
}

protocol ExerciseEntityProviderProtocol {
    
    func fetchExercise(_ id: UUID) throws -> Exercise
}

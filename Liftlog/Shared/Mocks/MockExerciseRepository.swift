//
//  MockExerciseRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

final class MockExerciseRepository: ExerciseRepositoryProtocol {
    
    private var exercises = ExerciseModel.mocks
    
    func fetchAll() throws -> [ExerciseModel] {
        return exercises
    }
    
    func create(name: String, description: String?) throws -> ExerciseModel {
        let exercise = ExerciseModel(id: UUID(), name: name, description: description)
        exercises.append(exercise)
        
        return exercise
    }
    
    func update(_ model: ExerciseModel) throws {
        guard let index = exercises.firstIndex(where: { $0.id == model.id }) else { return }
        exercises[index] = model
    }
    
    func delete(_ id: UUID) throws {
        exercises.removeAll { $0.id == id }
    }
    
    
}

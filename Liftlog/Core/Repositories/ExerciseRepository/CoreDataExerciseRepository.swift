//
//  CoreDataExerciseRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData
import Foundation

final class CoreDataExerciseRepository: ExerciseRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAll() async throws -> [ExerciseModel] {
        try await context.perform {
            let request = Exercise.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            return try self.context.fetch(request).map { $0.toDomain() }
        }
    }
    
    func create(name: String, description: String?) async throws -> ExerciseModel {
        try await context.perform {
            let exercise = Exercise(context: self.context)
            exercise.id = UUID()
            exercise.name = name
            exercise.exerciseDescription = description
            
            try self.context.save()
            
            return exercise.toDomain()
        }
    }
    
    func update(_ model: ExerciseModel) async throws {
        try await context.perform {
            let exercise = try self.fetchExercise(model.id)
            
            exercise.name = model.name
            exercise.exerciseDescription = model.description
            
            try self.context.save()
        }
    }
    
    func delete(_ id: UUID) async throws {
        try await context.perform {
            let exercise = try self.fetchExercise(id)
            
            self.context.delete(exercise)
            try self.context.save()
        }
    }
}

extension CoreDataExerciseRepository {
    fileprivate func fetchExercise(_ id: UUID) throws -> Exercise {
        let request = fetchRequest(for: Exercise.self, with: [id])
        
        guard let exercise = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Exercise was not found"))
         }
        
        return exercise
    }
}

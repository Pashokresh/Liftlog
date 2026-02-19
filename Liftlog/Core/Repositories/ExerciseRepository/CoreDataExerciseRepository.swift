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
        
    func fetchAll() throws -> [ExerciseModel] {
        let request = Exercise.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        return try context.fetch(request).map { $0.toDomain() }
    }
    
    func create(name: String, description: String?) throws -> ExerciseModel {
        let exercise = Exercise(context: context)
        exercise.id = UUID()
        exercise.name = name
        exercise.exerciseDescription = description
        
        try context.save()
        
        return exercise.toDomain()
    }
    
    func update(_ model: ExerciseModel) throws {
        let exercise = try fetchExercise(model.id)
        
        exercise.name = model.name
        exercise.exerciseDescription = model.description
        
        try context.save()
    }
    
    func delete(_ id: UUID) throws {
        let exercise = try fetchExercise(id)
        
        context.delete(exercise)
        try context.save()
    }
}

extension CoreDataExerciseRepository: ExerciseEntityProviderProtocol {
    func fetchExercise(_ id: UUID) throws -> Exercise {
        let request = Exercise.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let exercise = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Exercise was not found"))
         }
        
        return exercise
    }
}

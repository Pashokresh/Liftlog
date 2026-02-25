//
//  CoreDataWorkoutRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation
import CoreData

final class CoreDataWorkoutRepository: WorkoutRepositoryProtocol {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchAll() async throws -> [WorkoutModel] {
        try await context.perform {
            let request = Workout.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
            
            return try self.context.fetch(request).map { $0.toDomain() }
        }
    }
    
    func create(_ workoutModel: WorkoutModel) async throws -> WorkoutModel {
        try await context.perform {
            let workout = Workout(context: self.context)
            
            workout.id = UUID()
            workout.name = workoutModel.name
            workout.date = workoutModel.date
            workout.notes = workoutModel.notes
            
            try self.context.save()
            
            return workout.toDomain()
        }
    }
    
    func update(_ model: WorkoutModel) async throws {
        try await context.perform {
            let workout = try self.fetchWorkout(model.id)
            
            workout.name = model.name
            workout.date = model.date
            workout.notes = model.notes
            
            /// * Updating Tags *
            
            let newTagIDs = Set(model.tags.map(\.id))
            let currentTags = (workout.tags as? Set<Tag>) ?? []
            let currentTagIds = Set(currentTags.map { $0.id })
        
            /// * Removing old ones *
            currentTags
                .filter { !newTagIDs.contains($0.id!) }
                .forEach { workout.removeFromTags($0) }
            
            /// * Adding new ones *
            let tagsToAddIDs = model.tags
                .filter { !currentTagIds.contains($0.id) }
                .map(\.id)
            
            let tagsToAddRequest = fetchRequest(for: Tag.self, with: tagsToAddIDs)
            let tagsToAdd = try self.context.fetch(tagsToAddRequest)
            tagsToAdd.forEach { workout.addToTags($0) }
            
            try self.context.save()
        }
    }
    
    func delete(_ id: UUID) async throws {
        try await context.perform {
            let workout = try self.fetchWorkout(id)
            
            self.context.delete(workout)
            try self.context.save()
        }
    }
    
    func addExercise(_ exerciseModel: WorkoutExerciseModel, to workoutID: UUID) async throws {
        try await context.perform {
            let workout = try self.fetchWorkout(workoutID)
            
            guard let exercise = try self.context.fetch(
                fetchRequest(
                    for: Exercise.self,
                    with: [exerciseModel.exercise.id])
            ).first else {
                throw LiftlogError.failure(description: String(localized: "Exercise was not found"))
            }
            
            let workoutExercise = WorkoutExercise(context: self.context)
            workoutExercise.id = UUID()
            workoutExercise.order = Int16(exerciseModel.order)
            workoutExercise.workout = workout
            workoutExercise.exercise = exercise
            
            try self.context.save()
        }
    }
    
    func updateExercise(_ model: WorkoutExerciseModel, in workoutID: UUID) async throws {
        try await context.perform {
            let request = fetchRequest(for: WorkoutExercise.self, with: [model.id])
            
            guard let workoutExercise = try self.context.fetch(request).first else {
                throw LiftlogError.noData(description: String("Exercise was not found"))
            }
            
            workoutExercise.order = Int16(model.order)
            
            try self.context.save()
        }
    }
    
    func deleteExercise(_ id: UUID) async throws {
        try await context.perform {
            let workoutExercise = try self.fetchWorkoutExercise(id)
            
            self.context.delete(workoutExercise)
            try self.context.save()
        }
    }
    
    func addSet(_ setModel: ExerciseSetModel, to workoutExerciseID: UUID) async throws {
        try await context.perform {
            let workoutExercise = try self.fetchWorkoutExercise(workoutExerciseID)
            
            let set = ExerciseSet(context: self.context)
            set.id = UUID()
            set.order = Int16(setModel.order)
            set.note = setModel.note
            set.workoutExercise = workoutExercise
            
            switch setModel.type {
            case .weighted(let reps, let weight):
                set.reps = Int16(reps)
                set.weight = weight
            case .timed(let duration):
                set.duration = duration
            }
            
            try self.context.save()
        }
    }
    
    func updateSet(_ model: ExerciseSetModel) async throws {
        try await context.perform {
            let set = try self.fetchSet(model.id)
            
            set.id = model.id
            set.order = Int16(model.order)
            set.note = model.note
            
            switch model.type {
            case .weighted(let reps, let weight):
                set.reps = Int16(reps)
                set.weight = weight
            case .timed(let duration):
                set.duration = duration
            }
            
            try self.context.save()
        }
    }
    
    func deleteSet(_ id: UUID) async throws {
        try await context.perform {
            let set = try self.fetchSet(id)
            
            self.context.delete(set)
            try self.context.save()
        }
    }
    
    func addTag(_ tagModel: TagModel, to workoutID: UUID) async throws {
        try await context.perform {
            let workout = try self.fetchWorkout(workoutID)
            
            guard let tag = try self.context.fetch(fetchRequest(for: Tag.self, with: [tagModel.id])).first else {
                throw LiftlogError.failure(description: String(localized: "Tag was not found"))
            }
            
            workout.addToTags(tag)
            
            try self.context.save()
        }
    }
    
    func removeTag(_ tagID: UUID, from workoutID: UUID) async throws {
        try await context.perform {
            let request = fetchRequest(for: Workout.self, with: [workoutID])
            
            guard let workout = try self.context.fetch(request).first else {
                throw LiftlogError.noData(description: String(localized: "Workout was not found"))
            }
            
            guard let tag = try self.context.fetch(fetchRequest(for: Tag.self, with: [tagID])).first else {
                throw LiftlogError.failure(description: String(localized: "Tag was not found"))
            }
            
            workout.removeFromTags(tag)
            
            try self.context.save()
        }
    }
}

extension CoreDataWorkoutRepository {
    fileprivate func fetchSet(_ id: UUID) throws -> ExerciseSet {
        let request = fetchRequest(for: ExerciseSet.self, with: [id])
        
        guard let set = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Set was not found"))
        }
        
        return set
    }
    
    fileprivate func fetchWorkoutExercise(_ id: UUID) throws -> WorkoutExercise {
        let request = fetchRequest(for: WorkoutExercise.self, with: [id])
        
        guard let workoutExercise = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Set was not found"))
        }
        
        return workoutExercise
    }
    
    fileprivate func fetchWorkout(_ id: UUID) throws -> Workout {
        let request = fetchRequest(for: Workout.self, with: [id])
        
        guard let workout = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Set was not found"))
        }
        
        return workout
    }
}

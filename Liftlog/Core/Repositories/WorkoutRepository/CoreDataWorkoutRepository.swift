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
    private let exerciseRepository: ExerciseEntityProviderProtocol
    private let tagRepository: TagEntityProviderProtocol
    
    init(context: NSManagedObjectContext,
         exerciseRepository: ExerciseEntityProviderProtocol,
         tagRepository: TagEntityProviderProtocol
    ) {
        self.context = context
        self.exerciseRepository = exerciseRepository
        self.tagRepository = tagRepository
    }
    
    func fetchAll() throws -> [WorkoutModel] {
        let request = Workout.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        return try context.fetch(request).map { $0.toDomain() }
    }
    
    func create(_ workoutModel: WorkoutModel) throws -> WorkoutModel {
        let workout = Workout(context: context)
        
        workout.id = UUID()
        workout.name = workoutModel.name
        workout.date = workoutModel.date
        workout.notes = workoutModel.notes
        
        try context.save()
        
        return workout.toDomain()
    }
    
    func update(_ model: WorkoutModel) throws {
        let workout = try fetchWorkout(model.id)
        
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
        
        let tagsToAdd = try tagRepository.fetchTags(tagsToAddIDs)
        tagsToAdd.forEach { workout.addToTags($0) }
        
        try context.save()
    }
    
    func delete(_ id: UUID) throws {
        let workout = try fetchWorkout(id)
        
        context.delete(workout)
        try context.save()
    }
    
    func addExercise(_ exerciseModel: WorkoutExerciseModel, to workoutID: UUID) throws {
        let workout = try fetchWorkout(workoutID)
        let exercise = try exerciseRepository.fetchExercise(exerciseModel.exercise.id)
        
        let workoutExercise = WorkoutExercise(context: context)
        workoutExercise.id = UUID()
        workoutExercise.order = Int16(exerciseModel.order)
        workoutExercise.workout = workout
        workoutExercise.exercise = exercise
        
        try context.save()
    }
    
    func deleteExercise(_ id: UUID) throws {
        let request = WorkoutExercise.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let workoutExercise = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Exercise was not found"))
        }
        
        context.delete(workoutExercise)
        try context.save()
    }
    
    func addSet(_ setModel: ExerciseSetModel, to workoutExerciseID: UUID) throws {
        let request = WorkoutExercise.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", workoutExerciseID as CVarArg)
        
        guard let workoutExercise = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Set was not found"))
        }
        
        let set = ExerciseSet(context: context)
        set.id = UUID()
        set.order = Int16(setModel.order)
        set.workoutExercise = workoutExercise
        
        switch setModel.type {
        case .weighted(let reps, let weight):
            set.reps = Int16(reps)
            set.weight = weight
        case .timed(let duration):
            set.duration = duration
        }
        
        try context.save()
    }
    
    func deleteSet(_ id: UUID) throws {
        let request = ExerciseSet.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let set = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Set was not found"))
        }
        
        context.delete(set)
        try context.save()
    }
    
    func addTag(_ tagModel: TagModel, to workoutID: UUID) throws {
        let workout = try fetchWorkout(workoutID)
        let tag = try tagRepository.fetchTag(tagModel.id)
        
        workout.addToTags(tag)
        
        try context.save()
    }
    
    func removeTag(_ tagID: UUID, from workoutID: UUID) throws {
        let workout = try fetchWorkout(workoutID)
        let tag = try tagRepository.fetchTag(tagID)
        
        workout.removeFromTags(tag)
        
        try context.save()
    }
}


extension CoreDataWorkoutRepository: WorkoutEntityProviderProtocol {
    
    func fetchWorkout(_ id: UUID) throws -> Workout {
        let request = Workout.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        guard let workout = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Workout was not found"))
        }
        
        return workout
    }
}

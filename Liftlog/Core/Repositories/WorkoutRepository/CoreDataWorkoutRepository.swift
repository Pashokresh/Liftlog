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
        let request = Workout.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        return try context.fetch(request).map { $0.toDomain() }
    }
    
    func create(_ workoutModel: WorkoutModel) async throws -> WorkoutModel {
        let workout = Workout(context: context)
        
        workout.id = UUID()
        workout.name = workoutModel.name
        workout.date = workoutModel.date
        workout.notes = workoutModel.notes
        
        try context.save()
        
        return workout.toDomain()
    }
    
    func update(_ model: WorkoutModel) async throws {
        let workout = try await fetchWorkout(model.id)
        
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
        let tagsToAdd = try context.fetch(tagsToAddRequest)
        tagsToAdd.forEach { workout.addToTags($0) }
        
        try context.save()
    }
    
    func delete(_ id: UUID) async throws {
        let workout = try await fetchWorkout(id)
        
        context.delete(workout)
        try context.save()
    }
    
    func addExercise(_ exerciseModel: WorkoutExerciseModel, to workoutID: UUID) async throws {
        let workout = try await fetchWorkout(workoutID)
        
        guard let exercise = try context.fetch(
            fetchRequest(
                for: Exercise.self,
                with: [exerciseModel.exercise.id])
        ).first else {
            throw LiftlogError.failure(description: String(localized: "Exercise was not found"))
        }
        
        let workoutExercise = WorkoutExercise(context: context)
        workoutExercise.id = UUID()
        workoutExercise.order = Int16(exerciseModel.order)
        workoutExercise.workout = workout
        workoutExercise.exercise = exercise
        
        try context.save()
    }
    
    func deleteExercise(_ id: UUID) async throws {
        let workoutExercise = try await fetchWorkoutExercise(id)
        
        context.delete(workoutExercise)
        try context.save()
    }
    
    func addSet(_ setModel: ExerciseSetModel, to workoutExerciseID: UUID) async throws {
        let workoutExercise = try await fetchWorkoutExercise(workoutExerciseID)
        
        let set = ExerciseSet(context: context)
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
        
        try context.save()
    }
    
    func updateSet(_ model: ExerciseSetModel) async throws {
        let set = try await fetchSet(model.id)
        
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
        
        try context.save()
    }
    
    func deleteSet(_ id: UUID) async throws {
        let set = try await fetchSet(id)
        
        context.delete(set)
        try context.save()
    }
    
    func addTag(_ tagModel: TagModel, to workoutID: UUID) async throws {
        let workout = try await fetchWorkout(workoutID)
        
        guard let tag = try context.fetch(fetchRequest(for: Tag.self, with: [tagModel.id])).first else {
            throw LiftlogError.failure(description: String(localized: "Tag was not found"))
        }
        
        workout.addToTags(tag)
        
        try context.save()
    }
    
    func removeTag(_ tagID: UUID, from workoutID: UUID) async throws {
        let request = fetchRequest(for: Workout.self, with: [workoutID])
        
        guard let workout = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Workout was not found"))
        }
        
        guard let tag = try context.fetch(fetchRequest(for: Tag.self, with: [tagID])).first else {
            throw LiftlogError.failure(description: String(localized: "Tag was not found"))
        }
        
        workout.removeFromTags(tag)
        
        try context.save()
    }
}

extension CoreDataWorkoutRepository {
    fileprivate func fetchSet(_ id: UUID) async throws -> ExerciseSet {
        let request = fetchRequest(for: ExerciseSet.self, with: [id])
        
        guard let set = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Set was not found"))
        }
        
        return set
    }
    
    fileprivate func fetchWorkoutExercise(_ id: UUID) async throws -> WorkoutExercise {
        let request = fetchRequest(for: WorkoutExercise.self, with: [id])
        
        guard let workoutExercise = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Set was not found"))
        }
        
        return workoutExercise
    }
    
    fileprivate func fetchWorkout(_ id: UUID) async throws -> Workout {
        let request = fetchRequest(for: Workout.self, with: [id])
        
        guard let workout = try context.fetch(request).first else {
            throw LiftlogError.noData(description: String(localized: "Set was not found"))
        }
        
        return workout
    }
}

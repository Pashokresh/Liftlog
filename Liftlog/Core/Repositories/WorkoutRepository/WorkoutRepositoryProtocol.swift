//
//  WorkoutRepositoryProtocol.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

protocol WorkoutRepositoryProtocol {
    
    // MARK: - Methods working with Workout
    
    func fetchAll() throws -> [WorkoutModel]
    
    func create(_ workoutModel: WorkoutModel) throws -> WorkoutModel
    
    func update(_ model: WorkoutModel) throws
    
    func delete(_ id: UUID) throws
    
    // MARK: - Methods working with exercises
    
    func addExercise(_ exerciseModel: WorkoutExerciseModel, to workoutID: UUID) throws
    
    func deleteExercise(_ id: UUID) throws
    
    // MARK: - Methods working with sets
    
    func addSet(_ setModel: ExerciseSetModel, to workoutExerciseID: UUID) throws
    
    func updateSet(_ model: ExerciseSetModel) throws
    
    func deleteSet(_ id: UUID) throws
    
    // MARK: - Methods working with tags
    
    func addTag(_ tagModel: TagModel, to workoutID: UUID) throws
    
    func removeTag(_ tagID: UUID, from workoutID: UUID) throws
}

protocol WorkoutEntityProviderProtocol {
    
    func fetchWorkout(_ id: UUID) throws -> Workout
}

//
//  MockWorkoutRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.02.26.
//

import Foundation

final class MockWorkoutRepository: WorkoutRepositoryProtocol {
        
    private var workouts = WorkoutModel.mocks
    
    func fetchAll() throws -> [WorkoutModel] {
        workouts
    }
    
    func fetch(_ id: UUID) async throws -> WorkoutModel {
        guard let workout = workouts.first(where: { $0.id == id }) else {
            throw LiftlogError.failure(description: String(localized: "Workout not found"))
        }
        return workout
    }
    
    func create(_ workoutModel: WorkoutModel) throws -> WorkoutModel {
        workouts.append(workoutModel)
        return workoutModel
    }
    
    func update(_ model: WorkoutModel) throws {
        guard let index = getModelIndex(model.id) else { return }
        workouts[index] = model
    }
    
    func delete(_ id: UUID) throws {
        workouts.removeAll(where: { $0.id == id })
    }
    
    func addExercise(_ exerciseModel: WorkoutExerciseModel, to workoutID: UUID) throws {
        guard let index = getModelIndex(workoutID) else { return }
        workouts[index].exercises.append(exerciseModel)
    }
    
    func updateExercise(_ model: WorkoutExerciseModel, in workoutID: UUID) async throws {
        guard let index = getModelIndex(workoutID),
        let workoutExerciseIndex = workouts[index].exercises.firstIndex(where: { $0.id == model.id }) else { return }
        
        workouts[index].exercises[workoutExerciseIndex] = model
    }

    func deleteExercise(_ id: UUID) throws {
        for index in workouts.indices {
            workouts[index].exercises.removeAll { $0.id == id }
        }
    }

    func addSet(_ setModel: ExerciseSetModel, to workoutExerciseID: UUID) throws {
        for workoutIndex in workouts.indices {
            guard let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == workoutExerciseID }) else { continue }
            workouts[workoutIndex].exercises[exerciseIndex].sets.append(setModel)
            return
        }
    }
    
    func updateSet(_ model: ExerciseSetModel) throws {
        
    }

    func deleteSet(_ id: UUID) throws {
        for workoutIndex in workouts.indices {
            for exerciseIndex in workouts[workoutIndex].exercises.indices {
                workouts[workoutIndex].exercises[exerciseIndex].sets.removeAll { $0.id == id }
            }
        }
    }
    
    private func getModelIndex(_ id: UUID) -> Int? {
        workouts.firstIndex(where: { $0.id == id })
    }
}

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
        guard let exerciseIndex = workouts[index]
            .exercises.firstIndex(where: {
                $0.id == exerciseModel.exercise.id
            }) else { return
        }
        workouts[index].exercises[exerciseIndex].workoutExercises.append(exerciseModel)
    }

    func deleteExercise(_ id: UUID) throws {
        for index in workouts.indices {
            workouts[index].exercises.removeAll { $0.id == id }
        }
    }

    func addSet(_ setModel: ExerciseSetModel, to workoutExerciseID: UUID) throws {
        for workoutIndex in workouts.indices {
            guard let exerciseIndex = workouts[workoutIndex].exercises.firstIndex(where: { $0.id == workoutExerciseID }) else { continue }
            workouts[workoutIndex].exercises[exerciseIndex].workoutExercises[workoutIndex].sets.append(setModel)
            return
        }
    }
    
    func updateSet(_ model: ExerciseSetModel) throws {
        
    }

    func deleteSet(_ id: UUID) throws {
        for workoutIndex in workouts.indices {
            for exerciseIndex in workouts[workoutIndex].exercises.indices {
                workouts[workoutIndex].exercises[exerciseIndex].workoutExercises[workoutIndex].sets.removeAll { $0.id == id }
            }
        }
    }

    func addTag(_ tagModel: TagModel, to workoutID: UUID) throws {
        guard let index = getModelIndex(workoutID) else { return }
        workouts[index].tags.append(tagModel)
    }

    func removeTag(_ tagID: UUID, from workoutID: UUID) throws {
        guard let index = getModelIndex(workoutID) else { return }
        workouts[index].tags.removeAll { $0.id == tagID }
    }
    
    private func getModelIndex(_ id: UUID) -> Int? {
        workouts.firstIndex(where: { $0.id == id })
    }
}

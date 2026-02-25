//
//  WorkoutDetailViewModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class WorkoutDetailViewModel {
    
    private(set) var workout: WorkoutModel
    private(set) var error: Error?
    
    private let repository: WorkoutRepositoryProtocol
    
    init(workout: WorkoutModel, repository: WorkoutRepositoryProtocol) {
        self.workout = workout
        self.repository = repository
    }
    
    func addExercise(_ exercise: ExerciseModel) async {
        let workoutExercise = WorkoutExerciseModel(
            id: UUID(),
            order: workout.exercises.count,
            workout: workout,
            exercise: exercise,
            sets: [])
        
        do {
            try await repository.addExercise(workoutExercise, to: workout.id)
            workout.exercises.append(workoutExercise)
        } catch {
            self.error = error
        }
    }
    
    func deleteExercise(_ id: UUID) async {
        do {
            try await repository.deleteExercise(id)
            withAnimation {
                workout.exercises.removeAll(where: { $0.id == id })
            }
        } catch {
            self.error = error
        }
    }
    
    func moveExercise(fromSource: IndexSet, to destination: Int) async {
        workout.exercises.move(fromOffsets: fromSource, toOffset: destination)
        
        await withThrowingTaskGroup { taskGroup in
            for (index, exercise) in workout.exercises.enumerated() {
                var updated = exercise
                updated.order = index
                
                taskGroup.addTask {
                    try await self.repository.updateExercise(updated, in: self.workout.id)
                }
                
                while !taskGroup.isEmpty {
                    do {
                        try await taskGroup.next()
                    } catch {
                        self.error = error
                        taskGroup.cancelAll()
                    }
                }
            }
        }
    }
    
    func addSet(_ set: ExerciseSetModel, to workoutExerciseID: UUID) async {
        do {
            try await repository.addSet(set, to: workoutExerciseID)
            withAnimation {
                guard let index = workout.exercises.firstIndex(where: { $0.id == workoutExerciseID }) else { return }
                workout.exercises[index].sets.append(set)
            }
        } catch {
            self.error = error
        }
    }
    
    func deleteSet(_ id: UUID, from workoutExerciseID: UUID) async {
        do {
            try await repository.deleteSet(id)
            withAnimation {
                guard let index = workout.exercises.firstIndex(where: { $0.id == workoutExerciseID }) else { return }
                workout.exercises[index].sets.removeAll { $0.id == id }
            }
        } catch {
            self.error = error
        }
    }
}

//
//  WorkoutExercise+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

extension WorkoutExercise {
    
    func toDomain() -> WorkoutExerciseModel {
        let exercise = exercise?.toDomain() ??
        ExerciseModel(id: UUID(), name: "", description: description, workoutExercises: [])
        let sets = (sets as? Set<ExerciseSet>)?
            .map { $0.toDomain() }
            .sorted(by: { $0.order < $1.order }) ?? []
        let workout = workout?.toDomain() ?? WorkoutModel(id: UUID(), name: "", date: Date.now, notes: nil, tags: [], exercises: [])
 
        
        return WorkoutExerciseModel(
            id: id ?? UUID(),
            order: Int(order),
            workout: workout,
            exercise: exercise,
            sets: sets
        )
    }
}

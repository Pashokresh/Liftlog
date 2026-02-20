//
//  Exercise+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

extension Exercise {
    
    func toDomain() -> ExerciseModel {
        let workoutExercises = (workoutExercises as? Set<WorkoutExercise>)?
            .map { $0.toDomain() }
            .sorted(by: { $0.order < $1.order }) ?? []
        return ExerciseModel(
            id: id ?? UUID(),
            name: name ?? "",
            description: exerciseDescription,
            workoutExercises: workoutExercises
        )
    }
}

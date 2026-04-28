//
//  WorkoutExercise+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

extension WorkoutExercise {
    func toDomain() -> WorkoutExerciseModel {
        let exercise =
            exercise?.toDomain()
            ?? ExerciseModel(
                id: UUID(),
                name: "",
                description: description,
                type: .reps
            )
        let sets =
            (sets as? Set<ExerciseSet>)?
            .map { $0.toDomain() }
            .sorted { $0.order < $1.order } ?? []

        return WorkoutExerciseModel(
            id: id ?? UUID(),
            order: Int(order),
            exercise: exercise,
            sets: sets
        )
    }
}

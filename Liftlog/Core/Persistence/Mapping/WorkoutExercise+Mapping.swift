//
//  WorkoutExercise+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

extension WorkoutExercise {
    func toDomain() throws -> WorkoutExerciseModel {
        guard let id = id else {
            throw RepositoryError.invalidData(
                description: AppLocalization.missingRecordID
            )
        }

        let exercise =
            try exercise?.toDomain()
            ?? ExerciseModel(
                id: UUID(),
                name: "",
                description: description,
                type: .reps,
                muscleGroup: nil
            )
        let sets =
            try (sets as? Set<ExerciseSet>)?
            .map { try $0.toDomain() }
            .sorted { $0.order < $1.order } ?? []

        return WorkoutExerciseModel(
            id: id,
            order: Int(order),
            exercise: exercise,
            sets: sets
        )
    }
}

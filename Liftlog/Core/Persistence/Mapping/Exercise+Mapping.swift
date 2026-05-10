//
//  Exercise+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

extension Exercise {
    func toDomain() throws -> ExerciseModel {
        guard let id = id else {
            throw RepositoryError.invalidData(
                description: AppLocalization.missingRecordID
            )
        }

        return ExerciseModel(
            id: id,
            name: name ?? "",
            description: exerciseDescription,
            type: ExerciseType(rawValue: Int(type)) ?? .reps,
            muscleGroup: MuscleGroup(rawValue: Int(muscleGroup))
        )
    }
}

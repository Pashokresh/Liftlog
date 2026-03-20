//
//  Exercise+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

extension Exercise {

    func toDomain() -> ExerciseModel {
        return ExerciseModel(
            id: id ?? UUID(),
            name: name ?? "",
            description: exerciseDescription,
            type: ExerciseType(rawValue: Int(type)) ?? .reps
        )
    }
}

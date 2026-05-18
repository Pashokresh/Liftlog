//
//  ExerciseSet+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData
import Foundation

extension ExerciseSet {
    func toDomain() throws -> ExerciseSetModel {
        guard let id = id else {
            throw RepositoryError.invalidData(
                description: AppLocalization.missingRecordID
            )
        }

        return ExerciseSetModel(
            id: id,
            order: Int(order),
            note: note,
            // SetType is discriminated by duration because CoreData stores both fields on the
            // same entity. A duration > 0 unambiguously identifies a timed set; otherwise the
            // set is treated as weighted even if reps and weight are also zero (empty draft set).
            type: duration > 0
                ? .timed(duration: duration)
                : .weighted(reps: Int(reps), weight: weight),
            isWarmup: isWarmup
        )
    }
}

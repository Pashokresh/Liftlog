//
//  Workout+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData
import Foundation

extension Workout {
    func toDomain() throws -> WorkoutModel {
        guard let id = id else {
            throw RepositoryError.invalidData(
                description: AppLocalization.missingRecordID
            )
        }

        let tags = try (tags as? Set<Tag>)?.map { try $0.toDomain() } ?? []
        let exercises =
            try (exercises as? Set<WorkoutExercise>)?
            .map { try $0.toDomain() }
            .sorted { $0.order < $1.order } ?? []

        return WorkoutModel(
            id: id,
            name: name ?? "",
            date: date ?? Date.now,
            notes: notes,
            tags: tags,
            exercises: exercises
        )
    }
}

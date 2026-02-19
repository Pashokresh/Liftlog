//
//  Workout+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation
import CoreData

extension Workout {
    
    func toDomain() -> WorkoutModel {
        let tags = (tags as? Set<Tag>)?.map { $0.toDomain() } ?? []
        let exercises = (exercises as? Set<Exercise>)?
            .map { $0.toDomain() }
            .sorted { $0.name < $1.name } ?? []
        
        return WorkoutModel(
            id: id ?? UUID(),
            name: name ?? "",
            date: date ?? Date.now,
            notes: notes,
            tags: tags,
            exercises: exercises
        )
    }
}

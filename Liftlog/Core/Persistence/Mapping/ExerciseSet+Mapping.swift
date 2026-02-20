//
//  ExerciseSet+Mapping.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData
import Foundation

extension ExerciseSet {
    
    func toDomain() -> ExerciseSetModel {
        ExerciseSetModel(
            id: id ?? UUID(),
            order: Int(order),
            note: note,
            type: duration > 0 ?
                .timed(duration: duration) :
                    .weighted(reps: Int(reps), weight: weight)
        )
    }
}

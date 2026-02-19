//
//  WorkoutModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

struct WorkoutModel: Identifiable {
    let id: UUID
    let name: String
    let date: Date
    let notes: String?
    let tags: [TagModel]
    let exercises: [ExerciseModel]
}

//
//  WorkoutModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

struct WorkoutModel: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let date: Date
    let notes: String?
    var tags: [TagModel]
    var exercises: [WorkoutExerciseModel]
}

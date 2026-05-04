//
//  ExerciseHistorySectionModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import Foundation

struct ExerciseHistorySectionModel: Identifiable {
    let id: UUID
    let date: Date
    let workoutName: String
    var sets: [ExerciseSetModel]
}

//
//  MockData.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

extension ExerciseModel {
    static let mock = ExerciseModel(
        id: UUID(),
        name: "Bench Press",
        description: "Classic chest exercise"
    )
    
    static let mocks = [
        ExerciseModel(id: UUID(), name: "Bench Press", description: "Chest exercise"),
        ExerciseModel(id: UUID(), name: "Squat", description: "Leg exercise"),
        ExerciseModel(id: UUID(), name: "Deadlift", description: nil),
        ExerciseModel(id: UUID(), name: "Pull Up", description: "Back exercise"),
        ExerciseModel(id: UUID(), name: "Plank", description: "Core exercise")
    ]
}

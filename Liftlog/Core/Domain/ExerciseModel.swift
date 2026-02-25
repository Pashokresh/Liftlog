//
//  ExerciseModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

struct ExerciseModel: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let description: String?
    var workoutExercises: [WorkoutExerciseModel]
}

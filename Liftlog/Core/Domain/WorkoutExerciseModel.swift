//
//  WorkoutExerciseModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

struct WorkoutExerciseModel: Identifiable {
    let id: UUID
    let order: Int
    let workout: WorkoutModel
    let exercise: ExerciseModel
    let sets: [ExerciseSetModel]
}

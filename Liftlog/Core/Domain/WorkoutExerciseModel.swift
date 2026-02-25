//
//  WorkoutExerciseModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

struct WorkoutExerciseModel: Identifiable, Equatable, Hashable {
    let id: UUID
    var order: Int
    let workout: WorkoutModel
    let exercise: ExerciseModel
    var sets: [ExerciseSetModel]
}

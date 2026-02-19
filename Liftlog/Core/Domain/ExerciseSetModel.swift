//
//  ExerciseSetModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

enum SetType {
    case weighted(reps: Int, weight: Double)
    case timed(duration: Double)
}

struct ExerciseSetModel: Identifiable {
    let id: UUID
    let order: Int
    let type: SetType
}

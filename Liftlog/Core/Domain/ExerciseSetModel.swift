//
//  ExerciseSetModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

enum SetType: Equatable, Hashable {
    case weighted(reps: Int, weight: Double)
    case timed(duration: Double)
}

struct ExerciseSetModel: Identifiable, Equatable, Hashable {
    let id: UUID
    var order: Int
    let note: String?
    let type: SetType
}

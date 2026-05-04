//
//  ExerciseProgressEntry.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 30.04.26.
//

import Foundation

struct ExerciseProgressEntry: Identifiable, Sendable {
    let id: UUID
    let date: Date

    // for weighted exercises
    let maxWeight: Double
    let totalVolume: Double

    // for timed exercises
    let maxDuration: Double

    let workoutName: String
}

//
//  ExerciseProgressEntry.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 30.04.26.
//

import Foundation

/// One aggregated data point per workout session for a single exercise.
///
/// Only the fields relevant to the exercise type carry meaningful values:
/// - `.reps` exercises: `maxWeight` (kg) and `totalVolume` (kg × reps across all working sets)
/// - `.time` exercises: `maxDuration` (seconds)
///
/// The irrelevant fields default to `0`. Warmup sets are excluded from all calculations.
struct ExerciseProgressEntry: Identifiable, Sendable {
    let id: UUID
    let date: Date
    let maxWeight: Double
    let totalVolume: Double
    let maxDuration: Double
    let workoutName: String
}

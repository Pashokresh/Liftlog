//
//  ExerciseSetModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

/// Discriminates the two exercise modalities. Weight is stored in kilograms; duration in seconds.
///
/// The mapping layer derives the case from CoreData by checking whether `duration > 0`,
/// so a set must never store both a non-zero duration and non-zero reps simultaneously.
enum SetType: Equatable, Hashable {
    case weighted(reps: Int, weight: Double)
    case timed(duration: Double)
}

struct ExerciseSetModel: Identifiable, Equatable, Hashable {
    let id: UUID
    var order: Int
    var note: String?
    var type: SetType
    /// Warmup sets are excluded from all progress calculations and chart data.
    var isWarmup: Bool
}

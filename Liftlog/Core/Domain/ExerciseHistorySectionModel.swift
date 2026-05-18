//
//  ExerciseHistorySectionModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import Foundation

/// Groups all sets of a given exercise performed in a single past workout session.
///
/// Used in the set-logging screen to show previous sessions as reference.
/// The current session is excluded — see `ExerciseRepositoryProtocol.fetchHistory`.
struct ExerciseHistorySectionModel: Identifiable {
    let id: UUID
    let date: Date
    let workoutName: String
    var sets: [ExerciseSetModel]
}

//
//  ExerciseRepositoryProtocol.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation
import CoreData

protocol ExerciseRepositoryProtocol: AnyObject {
    func fetchAll() async throws -> [ExerciseModel]

    /// Returns past workout sessions that contain this exercise, grouped by workout.
    ///
    /// - Parameter exerciseID: The exercise to look up history for.
    /// - Parameter workoutExerciseID: The `WorkoutExercise` record to exclude — pass the
    ///   current session's ID so the user only sees *previous* sessions, not the one they're
    ///   actively logging.
    func fetchHistory(for exerciseID: UUID, excluding workoutExerciseID: UUID) async throws -> [ExerciseHistorySectionModel]

    func create(name: String, description: String?, type: ExerciseType, muscleGroup: MuscleGroup?) async throws -> ExerciseModel

    func update(_ model: ExerciseModel) async throws

    func delete(_ id: UUID) async throws

    /// Returns one aggregated entry per workout session within the given date range.
    ///
    /// Warmup sets are excluded from all calculations.
    /// For weighted exercises: `maxWeight` and `totalVolume` are populated; `maxDuration` is 0.
    /// For timed exercises: `maxDuration` is populated; `maxWeight` and `totalVolume` are 0.
    ///
    /// - Parameter exerciseID: The exercise to aggregate progress for.
    /// - Parameter startDate: Lower bound (inclusive). Pass `Date.distantPast` to fetch all time.
    func fetchProgress(for exerciseID: UUID, from startDate: Date) async throws -> [ExerciseProgressEntry]
}

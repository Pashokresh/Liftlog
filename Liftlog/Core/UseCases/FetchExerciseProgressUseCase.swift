//
//  FetchExerciseProgressUseCase.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Foundation

protocol FetchExerciseProgressUseCaseProtocol {
    /// Fetches and aggregates progress entries for an exercise within the given period.
    ///
    /// Warmup sets are excluded from all calculations. Sessions where all working sets
    /// produce zero metrics are also excluded (e.g. a session logged with 0 weight/reps).
    ///
    /// - Throws: `DomainError.exerciseNotFound` if the exercise no longer exists in the store.
    func execute(for exercise: ExerciseModel, period: Period) async throws
        -> [ExerciseProgressEntry]
}

final class FetchExerciseProgressUseCase: FetchExerciseProgressUseCaseProtocol {
    private let exerciseRepository: ExerciseRepositoryProtocol

    init(exerciseRepository: ExerciseRepositoryProtocol) {
        self.exerciseRepository = exerciseRepository
    }

    func execute(for exercise: ExerciseModel, period: Period) async throws
        -> [ExerciseProgressEntry] {
        do {
            let sessions = try await exerciseRepository.fetchProgress(
                for: exercise.id,
                from: period.startDate
            )
            return sessions.compactMap { aggregate($0, for: exercise) }
        } catch RepositoryError.notFound {
            throw DomainError.exerciseNotFound
        } catch {
            throw DomainError.invalidInput(description: error.localizedDescription)
        }
    }

    // MARK: - Private

    private func aggregate(
        _ session: ExerciseHistorySectionModel,
        for exercise: ExerciseModel
    ) -> ExerciseProgressEntry? {
        let workingSets = session.sets.filter { !$0.isWarmup }
        guard !workingSets.isEmpty else { return nil }

        switch exercise.type {
        case .reps:
            let weighted = workingSets.compactMap { set -> (reps: Int, weight: Double)? in
                guard case .weighted(let reps, let weight) = set.type else { return nil }
                return (reps, weight)
            }
            guard !weighted.isEmpty else { return nil }

            let maxWeight = weighted.map(\.weight).max() ?? 0
            let totalVolume = weighted.reduce(0.0) { $0 + $1.weight * Double($1.reps) }
            guard maxWeight > 0 || totalVolume > 0 else { return nil }

            return ExerciseProgressEntry(
                id: session.id,
                date: session.date,
                maxWeight: maxWeight,
                totalVolume: totalVolume,
                maxDuration: 0,
                workoutName: session.workoutName
            )

        case .time:
            let durations = workingSets.compactMap { set -> Double? in
                guard case .timed(let duration) = set.type else { return nil }
                return duration
            }
            guard !durations.isEmpty else { return nil }

            let maxDuration = durations.max() ?? 0
            guard maxDuration > 0 else { return nil }

            return ExerciseProgressEntry(
                id: session.id,
                date: session.date,
                maxWeight: 0,
                totalVolume: 0,
                maxDuration: maxDuration,
                workoutName: session.workoutName
            )
        }
    }
}

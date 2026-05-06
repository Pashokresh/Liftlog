//
//  FetchExerciseProgressUseCase.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Foundation

protocol FetchExerciseProgressUseCaseProtocol {
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
            let entries = try await exerciseRepository.fetchProgress(
                for: exercise.id,
                from: period.startDate
            )
            return entries.filter { entry in
                switch exercise.type {
                case .reps:
                    return entry.maxWeight > 0 || entry.totalVolume > 0
                case .time:
                    return entry.maxDuration > 0
                }
            }
        } catch RepositoryError.notFound {
            throw DomainError.exerciseNotFound
        } catch {
            throw DomainError.invalidInput(
                description: error.localizedDescription
            )
        }
    }
}

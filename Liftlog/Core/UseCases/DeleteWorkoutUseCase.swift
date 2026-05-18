//
//  DeleteWorkoutUseCase.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Foundation

protocol DeleteWorkoutUseCaseProtocol {
    /// Deletes a workout, translating infrastructure errors into domain errors.
    ///
    /// - Throws: `DomainError.workoutNotFound` if the workout no longer exists.
    func execute(workoutId: UUID) async throws
}

final class DeleteWorkoutUseCase: DeleteWorkoutUseCaseProtocol {
    private let workoutRepository: WorkoutRepositoryProtocol

    init(workoutRepository: WorkoutRepositoryProtocol) {
        self.workoutRepository = workoutRepository
    }

    func execute(workoutId: UUID) async throws {
        do {
            try await workoutRepository.delete(workoutId)
        } catch RepositoryError.notFound {
            throw DomainError.workoutNotFound
        } catch {
            throw DomainError.invalidInput(description: error.localizedDescription)
        }
    }
}

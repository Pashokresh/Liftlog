//
//  ManageExerciseUseCase.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 16.05.26.
//

import Foundation

protocol ManageExerciseUseCaseProtocol {
    func create(_ exercise: ExerciseModel) async throws -> ExerciseModel
    func update(_ exercise: ExerciseModel) async throws -> ExerciseModel
    func delete(_ exercise: ExerciseModel) async throws
}

final class ManageExerciseUseCase: ManageExerciseUseCaseProtocol {
    private let repository: ExerciseRepositoryProtocol

    init(repository: ExerciseRepositoryProtocol) {
        self.repository = repository
    }

    func create(_ exercise: ExerciseModel) async throws -> ExerciseModel {
        guard !exercise.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DomainError.invalidInput(description: AppLocalization.emptyName)
        }

        do {
            let exercise = try await repository.create(
                name: exercise.name,
                description: exercise.description,
                type: exercise.type,
                muscleGroup: exercise.muscleGroup
            )
            return exercise
        } catch {
            throw DomainError.invalidInput(description: error.localizedDescription)
        }
    }

    func update(_ exercise: ExerciseModel) async throws -> ExerciseModel {
        guard !exercise.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw DomainError.invalidInput(description: AppLocalization.emptyName)
        }

        do {
            try await repository.update(exercise)
            return exercise
        } catch RepositoryError.notFound {
            throw DomainError.exerciseNotFound
        } catch {
            throw DomainError.invalidInput(description: error.localizedDescription)
        }
    }

    func delete(_ exercise: ExerciseModel) async throws {
        do {
            try await repository.delete(exercise.id)
        } catch RepositoryError.notFound {
            throw DomainError.workoutNotFound
        } catch {
            throw DomainError.invalidInput(description: error.localizedDescription)
        }
    }
}

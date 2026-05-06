//
//  ManageWorkoutTagUseCase.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Foundation

protocol ManageWorkoutTagsUseCaseProtocol {
    func updateTags(_ tags: [TagModel], for workout: WorkoutModel) async throws -> WorkoutModel
    func createTag(name: String) async throws -> TagModel
}

final class ManageWorkoutTagsUseCase: ManageWorkoutTagsUseCaseProtocol {
    private let workoutRepository: WorkoutRepositoryProtocol
    private let tagRepository: TagRepositoryProtocol

    init(
        workoutRepository: WorkoutRepositoryProtocol,
        tagRepository: TagRepositoryProtocol
    ) {
        self.workoutRepository = workoutRepository
        self.tagRepository = tagRepository
    }

    func updateTags(_ tags: [TagModel], for workout: WorkoutModel) async throws -> WorkoutModel {
        var updatedWorkout = workout
        updatedWorkout.tags = tags

        do {
            try await workoutRepository.update(updatedWorkout)
            return updatedWorkout
        } catch RepositoryError.notFound {
            throw DomainError.workoutNotFound
        } catch {
            throw DomainError.invalidInput(description: error.localizedDescription)
        }
    }

    func createTag(name: String) async throws -> TagModel {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else {
            throw DomainError.invalidInput(description: AppLocalization.name)
        }

        do {
            return try await tagRepository.create(name: trimmed)
        } catch {
            throw DomainError.invalidInput(description: error.localizedDescription)
        }
    }
}

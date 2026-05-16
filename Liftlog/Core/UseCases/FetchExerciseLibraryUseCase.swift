//
//  FetchExerciseLibraryUseCase.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 16.05.26.
//

import Foundation

protocol FetchExerciseLibraryUseCaseProtocol {
    func execute()async throws -> [ExerciseModel]
}

final class FetchExerciseLibraryUseCase: FetchExerciseLibraryUseCaseProtocol {
    private let repository: ExerciseRepositoryProtocol

    init(repository: ExerciseRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [ExerciseModel] {
        do {
            return try await repository.fetchAll()
        } catch RepositoryError.notFound {
            throw DomainError.exerciseNotFound
        } catch {
            throw DomainError.invalidInput(description: error.localizedDescription)
        }
    }
}

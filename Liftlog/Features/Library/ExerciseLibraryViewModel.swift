//
//  ExerciseLibraryViewModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

@Observable
@MainActor
final class ExerciseLibraryViewModel {
    private(set) var exercises: [ExerciseModel] = []
    private(set) var error: Error?
    
    private let repository: ExerciseRepositoryProtocol
    
    init(repository: ExerciseRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadExercises() {
        Task {
            do {
                exercises = try await repository.fetchAll()
            } catch {
                self.error = error
            }
        }
    }
    
    func createExercise(name: String, type: ExerciseType, description: String?) {
        Task {
            do {
                let exercise = try await repository.create(name: name, description: description, type: type)
                exercises.append(exercise)
            } catch {
                self.error = error
            }
        }
    }
    
    func deleteExercise(_ id: UUID) {
        Task {
            do {
                try await repository.delete(id)
                exercises.removeAll { $0.id == id }
            } catch {
                self.error = error
            }
        }
    }
    
    func nullifyError() {
        self.error = nil
    }
}

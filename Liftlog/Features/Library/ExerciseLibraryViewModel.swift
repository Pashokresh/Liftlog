//
//  ExerciseLibraryViewModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

@Observable
final class ExerciseLibraryViewModel {
    private(set) var exercises: [ExerciseModel] = []
    var error: Error?
    
    private let repository: ExerciseRepositoryProtocol
    
    init(repository: ExerciseRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadExercises() {
        self.error = nil
        
        do {
            exercises = try repository.fetchAll()
        } catch {
            self.error = error
        }
    }
    
    func createExercise(name: String, description: String?) {
        do {
            let exercise = try repository.create(name: name, description: description)
            exercises.append(exercise)
        } catch {
            self.error = error
        }
    }
    
    func deleteExercise(_ id: UUID) {
        do {
            try repository.delete(id)
            exercises.removeAll { $0.id == id }
        } catch {
            self.error = error
        }
    }
}

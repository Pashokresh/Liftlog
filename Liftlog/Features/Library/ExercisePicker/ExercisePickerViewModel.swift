//
//  ExercisePickerViewModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 21.04.26.
//

import Foundation
import Observation

@Observable
@MainActor
final class ExercisePickerViewModel {
    private(set) var exercises: [ExerciseModel] = .init()
    private(set) var error: Error? = nil
    var selectedExercises: OrderedSet<ExerciseModel> = .init()

    private var repository: ExerciseRepositoryProtocol

    var searchText: String = ""

    var filteredExercises: [ExerciseModel] {
        guard !searchText.isEmpty else { return self.exercises }

        return exercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    init(repository: ExerciseRepositoryProtocol) {
        self.repository = repository
    }

    func toggle(_ exercise: ExerciseModel) {
        if selectedExercises.contains(exercise) {
            selectedExercises.remove(exercise)
        } else {
            selectedExercises.insert(exercise)
        }
    }

    func selectedOrder(_ exercise: ExerciseModel) -> Int? {
        if selectedExercises.contains(exercise) {
            return (selectedExercises.firstIndex(of: exercise) ?? 0) + 1
        }
        
        return nil
    }

    func loadExercises() async {
        do {
            exercises = try await repository.fetchAll()
        } catch {}
    }

    func createAndSelectExercise(_ exercise: ExerciseModel) async {
        do {
            let created = try await repository.create(
                name: exercise.name,
                description: exercise.description,
                type: exercise.type
            )
            exercises.append(created)
            selectedExercises.insert(created)
        } catch {
            self.error = error
        }
    }
    
    func clearError() {
        Task { @MainActor in
            self.error = nil
        }
    }
}

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

    func isSelected(_ exercise: ExerciseModel) -> Bool {
        selectedExercises.contains(exercise)
    }

    func loadExercises() async {
        do {
            exercises = try await repository.fetchAll()
        } catch {}
    }
}

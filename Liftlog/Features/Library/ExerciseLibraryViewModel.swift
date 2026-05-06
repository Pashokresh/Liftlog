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
    private var loadTask: Task<Void, Error>?

    var editingExercise: ExerciseModel?

    var searchText = ""

    // MARK: - Computed Properties

    var filteredExercises: [ExerciseModel] {
        guard !searchText.isEmpty else { return exercises }
        return exercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var exercisesByMuscleGroup: [MuscleGroupSection] {
        filteredExercises.groupedByMuscle()
    }

    // MARK: Init and Clean Up

    init(repository: ExerciseRepositoryProtocol) {
        self.repository = repository
    }

    isolated deinit {
        cleanUp()
    }

    private func cleanUp() {
        loadTask?.cancel()
    }

    // MARK: - Sync Methods

    func onApper() {
        loadTask?.cancel()

        loadTask = Task {
            await self.loadExercises()
        }
    }

    func createExercise(_ exercise: ExerciseModel) {
        Task {[weak self] in
            guard let self else { return }
            await self.createExercise(
                name: exercise.name,
                type: exercise.type,
                description: exercise.description,
                muscleGroup: exercise.muscleGroup
            )
        }
    }

    func updateExercise(_ exercise: ExerciseModel) {
        Task {[weak self] in
            guard let self else { return }
            await self.updateExercise(exercise)
        }
    }

    func deleteExercise(_ exercise: ExerciseModel) {
        Task { [weak self] in
            guard let self else { return }
            await deleteExercise(exercise.id)
        }
    }

    func nullifyError() {
        self.error = nil
    }

    // MARK: - Async Methods

    func loadExercises() async {
        do {
            exercises = try await repository.fetchAll()
        } catch {
            self.error = error
        }
    }

    func createExercise(name: String, type: ExerciseType, description: String?, muscleGroup: MuscleGroup?)
        async {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        do {
            let exercise = try await repository.create(
                name: name,
                description: description,
                type: type,
                muscleGroup: muscleGroup
            )
            exercises.append(exercise)
        } catch {
            self.error = error
        }
    }

    func updateExercise(_ exercise: ExerciseModel) async {
        do {
            try await repository.update(exercise)
            guard
                let index = exercises.firstIndex(where: {
                    $0.id == exercise.id
                })
            else { return }
            exercises[index] = exercise
        } catch {
            self.error = error
        }
    }

    func deleteExercise(_ id: UUID) async {
        do {
            try await repository.delete(id)
            exercises.removeAll { $0.id == id }
        } catch {
            self.error = error
        }
    }
}

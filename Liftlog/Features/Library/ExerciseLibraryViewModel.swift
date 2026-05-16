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
    private(set) var isLoading = false
    private(set) var error: Error?

    private let fetchExerciseLibraryUseCase: FetchExerciseLibraryUseCaseProtocol
    private let manageExerciseUseCase: ManageExerciseUseCaseProtocol
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

    init(
        fetchExerciseLibraryUseCase: FetchExerciseLibraryUseCaseProtocol,
        manageExerciseUseCase: ManageExerciseUseCaseProtocol
    ) {
        self.fetchExerciseLibraryUseCase = fetchExerciseLibraryUseCase
        self.manageExerciseUseCase = manageExerciseUseCase
    }

    isolated deinit {
        cleanUp()
    }

    private func cleanUp() {
        loadTask?.cancel()
    }

    // MARK: - Sync Methods

    func onAppear() {
        loadTask?.cancel()

        loadTask = Task {
            await self.loadExercises()
        }
    }

    func createExercise(_ exercise: ExerciseModel) {
        Task { [weak self] in
            guard let self else { return }
            await self.createExercise(exercise)
        }
    }

    func updateExercise(_ exercise: ExerciseModel) {
        Task { [weak self] in
            guard let self else { return }
            await self.updateExercise(exercise)
        }
    }

    func deleteExercise(_ exercise: ExerciseModel) {
        Task { [weak self] in
            guard let self else { return }
            await deleteExercise(exercise)
        }
    }

    func nullifyError() {
        self.error = nil
    }

    // MARK: - Async Methods

    func loadExercises() async {
        isLoading = true
        defer { isLoading = false }
        do {
            exercises = try await fetchExerciseLibraryUseCase.execute()
        } catch {
            self.error = error
        }
    }

    func createExercise(
        _ exercise: ExerciseModel
    ) async {
        do {
            let exercise = try await manageExerciseUseCase.create(exercise)
            exercises.append(exercise)
        } catch {
            self.error = error
        }
    }

    func updateExercise(_ exercise: ExerciseModel) async {
        do {
            _ = try await manageExerciseUseCase.update(exercise)
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

    func deleteExercise(_ exercise: ExerciseModel) async {
        do {
            try await manageExerciseUseCase.delete(exercise)
            exercises.removeAll { $0.id == exercise.id }
        } catch {
            self.error = error
        }
    }
}

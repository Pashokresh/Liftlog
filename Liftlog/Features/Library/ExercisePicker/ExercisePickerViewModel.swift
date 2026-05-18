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
    private(set) var isLoading = false
    private(set) var error: Error?
    var selectedExercises: OrderedSet<ExerciseModel> = .init()

    private let fetchExerciseLibraryUseCase: FetchExerciseLibraryUseCaseProtocol
    private let manageExerciseUseCase: ManageExerciseUseCaseProtocol
    private var loadTask: Task<Void, Never>?

    var searchText: String = ""

    // MARK: - Computed Properties

    var filteredExercises: [ExerciseModel] {
        guard !searchText.isEmpty else { return self.exercises }

        return exercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var exercisesByMuscleGroup: [MuscleGroupSection] {
        filteredExercises.groupedByMuscle()
    }

    // MARK: - Init and Clean Up

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

    // MARK: Sync methods

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

    func onApper() {
        loadTask?.cancel()

        loadTask = Task {
            await self.loadExercises()
        }
    }

    func createAndSelect(exercise: ExerciseModel) {
        Task {
            await createAndSelectExercise(exercise)
        }
    }

    func clearError() {
        Task { @MainActor in
            self.error = nil
        }
    }

    // MARK: Async methods

    func loadExercises() async {
        isLoading = true
        defer { isLoading = false }
        do {
            exercises = try await fetchExerciseLibraryUseCase.execute()
        } catch {
            self.error = error
        }
    }

    func createAndSelectExercise(_ exercise: ExerciseModel) async {
        do {
            let created = try await manageExerciseUseCase.create(exercise)
            exercises.append(created)
            selectedExercises.insert(created)
        } catch {
            self.error = error
        }
    }
}

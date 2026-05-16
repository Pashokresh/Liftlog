//
//  ExercisePickerViewModelTests.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 16.05.26.
//

import Testing
@testable import Liftlog
import Foundation

@Suite("ExercisePickerViewModel")
@MainActor
struct ExercisePickerViewModelTests {
    var repository: MockExerciseRepository
    var viewModel: ExercisePickerViewModel

    init() {
        repository = MockExerciseRepository()
        viewModel = ExercisePickerViewModel(
            fetchExerciseLibraryUseCase: FetchExerciseLibraryUseCase(repository: repository),
            manageExerciseUseCase: ManageExerciseUseCase(repository: repository)
        )
    }

    // MARK: - Load

    @Test("loadExercises fills exercises list")
    func loadExercises() async {
        await viewModel.loadExercises()
        #expect(viewModel.exercises.count == ExerciseModel.mocks.count)
    }

    @Test("isLoading is false after load completes")
    func isLoadingFalseAfterLoad() async {
        await viewModel.loadExercises()
        #expect(!viewModel.isLoading)
    }

    @Test("repository error propagates to error property")
    func repositoryErrorPropagates() async {
        repository.shouldThrow = true
        await viewModel.loadExercises()
        #expect(viewModel.error != nil)
    }

    // MARK: - Filter

    @Test("filteredExercises returns all when searchText is empty")
    func filteredExercisesAllWhenEmpty() async {
        await viewModel.loadExercises()
        #expect(viewModel.filteredExercises.count == viewModel.exercises.count)
    }

    @Test("filteredExercises filters by name case-insensitively")
    func filteredExercisesSearch() async {
        await viewModel.loadExercises()
        viewModel.searchText = "bench"
        #expect(viewModel.filteredExercises.allSatisfy {
            $0.name.localizedCaseInsensitiveContains("bench")
        })
        #expect(!viewModel.filteredExercises.isEmpty)
    }

    @Test("filteredExercises returns empty for non-matching query")
    func filteredExercisesNoMatch() async {
        await viewModel.loadExercises()
        viewModel.searchText = "zzz_no_match"
        #expect(viewModel.filteredExercises.isEmpty)
    }

    // MARK: - Toggle

    @Test("toggle selects an exercise")
    func toggleSelects() async {
        await viewModel.loadExercises()
        let exercise = viewModel.exercises[0]
        viewModel.toggle(exercise)
        #expect(viewModel.selectedExercises.contains(exercise))
    }

    @Test("toggle deselects an already-selected exercise")
    func toggleDeselects() async {
        await viewModel.loadExercises()
        let exercise = viewModel.exercises[0]
        viewModel.toggle(exercise)
        viewModel.toggle(exercise)
        #expect(!viewModel.selectedExercises.contains(exercise))
    }

    @Test("toggling multiple exercises preserves all selections")
    func toggleMultiple() async {
        await viewModel.loadExercises()
        let first = viewModel.exercises[0]
        let second = viewModel.exercises[1]
        viewModel.toggle(first)
        viewModel.toggle(second)
        #expect(viewModel.selectedExercises.count == 2)
        #expect(viewModel.selectedExercises.contains(first))
        #expect(viewModel.selectedExercises.contains(second))
    }

    // MARK: - Selected Order

    @Test("selectedOrder returns nil for unselected exercise")
    func selectedOrderNilForUnselected() async {
        await viewModel.loadExercises()
        #expect(viewModel.selectedOrder(viewModel.exercises[0]) == nil)
    }

    @Test("selectedOrder returns 1 for the first selected exercise")
    func selectedOrderFirstIsOne() async {
        await viewModel.loadExercises()
        let exercise = viewModel.exercises[0]
        viewModel.toggle(exercise)
        #expect(viewModel.selectedOrder(exercise) == 1)
    }

    @Test("selectedOrder reflects insertion order")
    func selectedOrderReflectsInsertionOrder() async {
        await viewModel.loadExercises()
        let first = viewModel.exercises[0]
        let second = viewModel.exercises[1]
        let third = viewModel.exercises[2]
        viewModel.toggle(first)
        viewModel.toggle(second)
        viewModel.toggle(third)
        #expect(viewModel.selectedOrder(first) == 1)
        #expect(viewModel.selectedOrder(second) == 2)
        #expect(viewModel.selectedOrder(third) == 3)
    }

    @Test("selectedOrder updates after deselecting an earlier exercise")
    func selectedOrderUpdatesAfterDeselect() async {
        await viewModel.loadExercises()
        let first = viewModel.exercises[0]
        let second = viewModel.exercises[1]
        viewModel.toggle(first)
        viewModel.toggle(second)
        viewModel.toggle(first)
        #expect(viewModel.selectedOrder(first) == nil)
        #expect(viewModel.selectedOrder(second) == 1)
    }

    // MARK: - Create and Select

    @Test("createAndSelectExercise appends exercise and auto-selects it")
    func createAndSelectExercise() async {
        await viewModel.loadExercises()
        let countBefore = viewModel.exercises.count
        await viewModel.createAndSelectExercise(.mock)
        #expect(viewModel.exercises.count == countBefore + 1)
        #expect(viewModel.selectedExercises.count == 1)
    }

    @Test("createAndSelectExercise with empty name sets error and does not add")
    func createAndSelectEmptyName() async {
        await viewModel.loadExercises()
        let countBefore = viewModel.exercises.count
        let empty = ExerciseModel(id: UUID(), name: "", description: nil, type: .reps, muscleGroup: nil)
        await viewModel.createAndSelectExercise(empty)
        #expect(viewModel.exercises.count == countBefore)
        #expect(viewModel.selectedExercises.isEmpty)
        #expect(viewModel.error != nil)
    }

    @Test("repository error in createAndSelectExercise propagates to error")
    func createAndSelectRepositoryError() async {
        repository.shouldThrow = true
        await viewModel.createAndSelectExercise(.mock)
        #expect(viewModel.error != nil)
        #expect(viewModel.selectedExercises.isEmpty)
    }

    // MARK: - Clear Error

    @Test("clearError sets error to nil")
    func clearError() async {
        repository.shouldThrow = true
        await viewModel.loadExercises()
        #expect(viewModel.error != nil)
        viewModel.clearError()
        await Task.yield()
        #expect(viewModel.error == nil)
    }
}

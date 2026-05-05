//
//  ExerciseLibraryViewModelTest.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 24.03.26.
//

import Testing
@testable import Liftlog

@Suite("ExerciseLibraryViewModel")
@MainActor
struct ExerciseLibraryViewModelTest {
    var repository: MockExerciseRepository
    var viewModel: ExerciseLibraryViewModel

    init() {
        repository = .mock
        viewModel = .init(repository: repository)
    }

    @Test("loadExercises fills the list")
    func loadExercises() async {
        await viewModel.loadExercises()
        #expect(viewModel.exercises.count == ExerciseModel.mocks.count)
    }

    @Test("createExercise adds a new exercise into array")
    func createExercise() async {
        let name = "New Exercise"

        await viewModel.loadExercises()
        let countBefore = viewModel.exercises.count

        await viewModel.createExercise(name: name, type: .reps, description: nil, muscleGroup: .chest)

        #expect(countBefore + 1 == viewModel.exercises.count)
        #expect(viewModel.exercises.last?.name == name)
    }

    @Test("deleteExercise removes an exercise from array")
    func deleteExercise() async {
        await viewModel.loadExercises()
        let first = viewModel.exercises[0]
        await viewModel.deleteExercise(first.id)
        #expect(!viewModel.exercises.contains { $0.id == first.id })
    }

    @Test("createExercise doesn't let add exercise with empty name")
    func createExerciseWithEmptyName() async {
        await viewModel.loadExercises()
        let countBefore = viewModel.exercises.count

        await viewModel.createExercise(name: "", type: .reps, description: nil, muscleGroup: .chest)

        #expect(countBefore == viewModel.exercises.count)
    }

    @Test("Repository error get's into VM's error")
    func repositoryErrorPropagates() async {
        repository.shouldThrow = true
        await viewModel.loadExercises()
        #expect(viewModel.error != nil)
    }

    @Test("nullifyError sets error to nil")
    func nullifyError() async {
        repository.shouldThrow = true
        await viewModel.loadExercises()
        #expect(viewModel.error != nil)

        viewModel.nullifyError()
        #expect(viewModel.error == nil)
    }
}

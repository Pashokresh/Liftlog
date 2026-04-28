//
//  WorkoutDetailViewModelTests.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 10.03.26.
//

import Foundation
import Testing

@testable import Liftlog

@Suite("WorkoutDetailViewModel")
@MainActor
struct WorkoutDetailViewModelTests {
    var repository: MockWorkoutRepository
    var viewModel: WorkoutDetailViewModel

    init() {
        repository = MockWorkoutRepository()
        viewModel = WorkoutDetailViewModel(
            workout: WorkoutModel.mock,
            repository: repository
        )
    }

    @Test("Impossible to add one exercise twice")
    func preventsDuplicateExercises() async {
        await viewModel.addExercise(ExerciseModel.mock)
        await viewModel.addExercise(ExerciseModel.mock)

        #expect(viewModel.workout.exercises.count == 1)
        #expect(viewModel.error != nil)
    }

    @Test("addExercise adds exercise")
    func addExercise() async {
        await viewModel.addExercise(ExerciseModel.mock)

        #expect(viewModel.workout.exercises.count == 1)
        #expect(viewModel.error == nil)
    }

    @Test("deleteExercise deletes exercise")
    func deleteExercise() async throws {
        await viewModel.addExercise(ExerciseModel.mock)
        let id = try #require(viewModel.workout.exercises.first?.id)

        await viewModel.deleteExercise(id)
        #expect(viewModel.workout.exercises.isEmpty)
    }

    @Test("moveExercise changes order")
    func moveExercise() async {
        let exercises = [
            ExerciseModel(id: UUID(), name: "A", description: nil, type: .reps),
            ExerciseModel(id: UUID(), name: "B", description: nil, type: .reps),
            ExerciseModel(id: UUID(), name: "C", description: nil, type: .reps)
        ]

        for exercise in exercises {
            await viewModel.addExercise(exercise)
        }

        await viewModel.moveExercise(fromSource: IndexSet(integer: 0), to: 2)

        #expect(viewModel.workout.exercises[0].exercise.name == "B")
        #expect(viewModel.workout.exercises[1].exercise.name == "A")
    }

    @Test("Repository error gets into ViewModel.error")
    func repositoryErrorPropagates() async {
        repository.shouldThrow = true
        await viewModel.addExercise(ExerciseModel.mock)
        #expect(viewModel.error != nil)
    }
}

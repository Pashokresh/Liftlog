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
    let repository: MockWorkoutRepository
    let viewModel: WorkoutDetailViewModel
    let workoutID: UUID

    init() {
        // Create unique IDs for this test instance
        workoutID = UUID()

        // Create a fresh repository for each test
        repository = MockWorkoutRepository()

        // Create a fresh workout for each test with unique ID
        let freshWorkout = WorkoutModel(
            id: workoutID,
            name: "New Training",
            date: Date.now,
            notes: "Training I need to repeat every week",
            tags: [TagModel.mock],
            exercises: []
        )

        // Add workout to repository so fetch() works
        repository.addWorkoutDirectly(freshWorkout)

        viewModel = WorkoutDetailViewModel(
            workout: freshWorkout,
            repository: repository
        )
    }

    @Test("Impossible to add one exercise twice")
    func preventsDuplicateExercises() async {
        await viewModel.addExercises([ExerciseModel.mock])
        await viewModel.addExercises([ExerciseModel.mock])

        #expect(viewModel.workout.exercises.count == 1)
        #expect(viewModel.error != nil)
    }

    @Test("addExercises adds exercise")
    func addExercises() async {
        await viewModel.addExercises([ExerciseModel.mock])

        #expect(viewModel.workout.exercises.count == 1)
        #expect(viewModel.error == nil)
    }

    @Test("addExercises adds multiple exercises")
    func addMultipleExercises() async {
        let exercises = [
            ExerciseModel(id: UUID(), name: "Exercise 1", description: nil, type: .reps, muscleGroup: .chest),
            ExerciseModel(id: UUID(), name: "Exercise 2", description: nil, type: .reps, muscleGroup: .chest),
            ExerciseModel(id: UUID(), name: "Exercise 3", description: nil, type: .reps, muscleGroup: .chest)
        ]

        await viewModel.addExercises(exercises)

        #expect(viewModel.workout.exercises.count == 3)
        #expect(viewModel.error == nil)
    }

    @Test("deleteExercise deletes exercise")
    func deleteExercise() async throws {
        await viewModel.addExercises([ExerciseModel.mock])
        let id = try #require(viewModel.workout.exercises.first?.id)

        await viewModel.deleteExercise(id)
        #expect(viewModel.workout.exercises.isEmpty)
    }

    @Test("moveExercise changes order")
    func moveExercise() async {
        let exercises = [
            ExerciseModel(id: UUID(), name: "A", description: nil, type: .reps, muscleGroup: .chest),
            ExerciseModel(id: UUID(), name: "B", description: nil, type: .reps, muscleGroup: .chest),
            ExerciseModel(id: UUID(), name: "C", description: nil, type: .reps, muscleGroup: .chest)
        ]

        await viewModel.addExercises(exercises)

        await viewModel.moveExercise(fromSource: IndexSet(integer: 0), to: 2)

        #expect(viewModel.workout.exercises[0].exercise.name == "B")
        #expect(viewModel.workout.exercises[1].exercise.name == "A")
    }

    @Test("Repository error gets into ViewModel.error")
    func repositoryErrorPropagates() async {
        repository.shouldThrow = true
        await viewModel.addExercises([ExerciseModel.mock])
        #expect(viewModel.error != nil)
    }

    @Test("addSet adds set to exercise")
    func addSet() async throws {
        await viewModel.addExercises([ExerciseModel.mock])
        let workoutExerciseID = try #require(viewModel.workout.exercises.first?.id)

        let set = ExerciseSetModel(
            id: UUID(),
            order: 0,
            note: nil,
            type: .weighted(reps: 10, weight: 50),
            isWarmup: false
        )

        await viewModel.addSet(set, to: workoutExerciseID)

        let addedSet = try #require(viewModel.workout.exercises.first?.sets.first)
        #expect(addedSet.id == set.id)
        #expect(viewModel.error == nil)
    }

    @Test("deleteSet removes set from exercise")
    func deleteSet() async throws {
        await viewModel.addExercises([ExerciseModel.mock])
        let workoutExerciseID = try #require(viewModel.workout.exercises.first?.id)

        let set = ExerciseSetModel(
            id: UUID(),
            order: 0,
            note: nil,
            type: .weighted(reps: 10, weight: 50),
            isWarmup: false
        )

        await viewModel.addSet(set, to: workoutExerciseID)
        #expect(viewModel.workout.exercises.first?.sets.count == 1)

        await viewModel.deleteSet(set.id, from: workoutExerciseID)
        #expect(viewModel.workout.exercises.first?.sets.isEmpty == true)
        #expect(viewModel.error == nil)
    }

    @Test("reloadWorkout updates workout data")
    func reloadWorkout() async {
        await viewModel.reloadWorkout()
        #expect(viewModel.error == nil)
    }

    @Test("nullifyError clears error")
    func nullifyError() async {
        repository.shouldThrow = true
        await viewModel.addExercises([ExerciseModel.mock])
        #expect(viewModel.error != nil)

        viewModel.nullifyError()
        #expect(viewModel.error == nil)
    }
}

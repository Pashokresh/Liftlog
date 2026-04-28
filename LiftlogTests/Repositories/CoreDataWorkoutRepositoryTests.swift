//
//  CoreDataWorkoutRepositoryTests.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 31.03.26.
//

import CoreData
import Testing

@testable import Liftlog

@Suite("CoreDataWorkoutRepositoryTests", .serialized)
@MainActor
struct CoreDataWorkoutRepositoryTests {
    var workoutRepository: CoreDataWorkoutRepository
    var exerciseRepository: CoreDataExerciseRepository

    init() {
        let context = PersistenceController(inMemory: true).container
            .viewContext
        workoutRepository = CoreDataWorkoutRepository(context: context)
        exerciseRepository = CoreDataExerciseRepository(context: context)
    }

    @Test("`create` adds a new workout")
    func createWorkout() async throws {
        let workout = try await workoutRepository.create(.mock)
        let all = try await workoutRepository.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.id == workout.id)
    }

    @Test("`delete` deletes workout")
    func deleteWorkout() async throws {
        let createdWorkout = try await workoutRepository.create(.mock)
        var all = try await workoutRepository.fetchAll()
        #expect(all.count == 1)

        try await workoutRepository.delete(createdWorkout.id)
        all = try await workoutRepository.fetchAll()
        #expect(all.isEmpty)
    }

    @Test("`addExercises` adds exercises to workout")
    func addExercises() async throws {
        let workout = try await workoutRepository.create(.mock)
        let exercise = try await exerciseRepository.create(
            name: "Squat",
            description: nil,
            type: .reps
        )

        let workoutExercise = WorkoutExerciseModel(
            id: UUID(),
            order: 0,
            exercise: exercise,
            sets: []
        )

        try await workoutRepository.addExercises(
            [workoutExercise],
            to: workout.id
        )

        let updated = try await workoutRepository.fetch(workout.id)
        #expect(updated.exercises.count == 1)
        #expect(updated.exercises.first?.exercise.id == exercise.id)
    }

    @Test("`addExercises` adds multiple exercises to workout")
    func addMultipleExercises() async throws {
        let workout = try await workoutRepository.create(.mock)
        let exercise1 = try await exerciseRepository.create(
            name: "Squat",
            description: nil,
            type: .reps
        )
        let exercise2 = try await exerciseRepository.create(
            name: "Bench Press",
            description: nil,
            type: .reps
        )
        let exercise3 = try await exerciseRepository.create(
            name: "Deadlift",
            description: nil,
            type: .reps
        )

        let workoutExercises = [
            WorkoutExerciseModel(
                id: UUID(),
                order: 0,
                exercise: exercise1,
                sets: []
            ),
            WorkoutExerciseModel(
                id: UUID(),
                order: 1,
                exercise: exercise2,
                sets: []
            ),
            WorkoutExerciseModel(
                id: UUID(),
                order: 2,
                exercise: exercise3,
                sets: []
            ),
        ]

        try await workoutRepository.addExercises(
            workoutExercises,
            to: workout.id
        )

        let updated = try await workoutRepository.fetch(workout.id)
        #expect(updated.exercises.count == 3)
        #expect(updated.exercises[0].exercise.id == exercise1.id)
        #expect(updated.exercises[1].exercise.id == exercise2.id)
        #expect(updated.exercises[2].exercise.id == exercise3.id)
    }

    @Test("`updateExercise` updates exercise order")
    func updateExercise() async throws {
        let workout = try await workoutRepository.create(.mock)
        let exercise = try await exerciseRepository.create(
            name: "Squat",
            description: nil,
            type: .reps
        )

        var workoutExercise = WorkoutExerciseModel(
            id: UUID(),
            order: 0,
            exercise: exercise,
            sets: []
        )

        try await workoutRepository.addExercises(
            [workoutExercise],
            to: workout.id
        )

        workoutExercise.order = 5
        try await workoutRepository.updateExercise(
            workoutExercise,
            in: workout.id
        )

        let updated = try await workoutRepository.fetch(workout.id)
        #expect(updated.exercises.first?.order == 5)
    }

    @Test("`deleteExercise` removes exercise from workout")
    func deleteExercise() async throws {
        let workout = try await workoutRepository.create(.mock)
        let exercise = try await exerciseRepository.create(
            name: "Squat",
            description: nil,
            type: .reps
        )

        let workoutExercise = WorkoutExerciseModel(
            id: UUID(),
            order: 0,
            exercise: exercise,
            sets: []
        )

        try await workoutRepository.addExercises(
            [workoutExercise],
            to: workout.id
        )
        var updated = try await workoutRepository.fetch(workout.id)
        #expect(updated.exercises.count == 1)

        try await workoutRepository.deleteExercise(workoutExercise.id)
        updated = try await workoutRepository.fetch(workout.id)
        #expect(updated.exercises.isEmpty)
    }

    @Test("`addSet` adds set to exercise")
    func addSet() async throws {
        let workout = try await workoutRepository.create(.mock)
        let exercise = try await exerciseRepository.create(
            name: "Squat",
            description: nil,
            type: .reps
        )

        let workoutExercise = WorkoutExerciseModel(
            id: UUID(),
            order: 0,
            exercise: exercise,
            sets: []
        )

        try await workoutRepository.addExercises(
            [workoutExercise],
            to: workout.id
        )

        let set = ExerciseSetModel(
            id: UUID(),
            order: 0,
            note: nil,
            type: .weighted(reps: 10, weight: 100)
        )

        try await workoutRepository.addSet(set, to: workoutExercise.id)

        let updated = try await workoutRepository.fetch(workout.id)
        #expect(updated.exercises.first?.sets.count == 1)
        #expect(updated.exercises.first?.sets.first?.id == set.id)
    }

    @Test("`updateSet` updates set data")
    func updateSet() async throws {
        let workout = try await workoutRepository.create(.mock)
        let exercise = try await exerciseRepository.create(
            name: "Squat",
            description: nil,
            type: .reps
        )

        let workoutExercise = WorkoutExerciseModel(
            id: UUID(),
            order: 0,
            exercise: exercise,
            sets: []
        )

        try await workoutRepository.addExercises(
            [workoutExercise],
            to: workout.id
        )

        var set = ExerciseSetModel(
            id: UUID(),
            order: 0,
            note: nil,
            type: .weighted(reps: 10, weight: 100)
        )

        try await workoutRepository.addSet(set, to: workoutExercise.id)

        set.type = .weighted(reps: 12, weight: 120)
        set.note = "Heavy set"
        try await workoutRepository.updateSet(set)

        let updated = try await workoutRepository.fetch(workout.id)
        let updatedSet = try #require(updated.exercises.first?.sets.first)

        if case .weighted(let reps, let weight) = updatedSet.type {
            #expect(reps == 12)
            #expect(weight == 120)
        }
        #expect(updatedSet.note == "Heavy set")
    }

    @Test("`deleteSet` removes set from exercise")
    func deleteSet() async throws {
        let workout = try await workoutRepository.create(.mock)
        let exercise = try await exerciseRepository.create(
            name: "Squat",
            description: nil,
            type: .reps
        )

        let workoutExercise = WorkoutExerciseModel(
            id: UUID(),
            order: 0,
            exercise: exercise,
            sets: []
        )

        try await workoutRepository.addExercises(
            [workoutExercise],
            to: workout.id
        )

        let set = ExerciseSetModel(
            id: UUID(),
            order: 0,
            note: nil,
            type: .weighted(reps: 10, weight: 100)
        )

        try await workoutRepository.addSet(set, to: workoutExercise.id)
        var updated = try await workoutRepository.fetch(workout.id)
        #expect(updated.exercises.first?.sets.count == 1)

        try await workoutRepository.deleteSet(set.id)
        updated = try await workoutRepository.fetch(workout.id)
        #expect(updated.exercises.first?.sets.isEmpty == true)
    }

    @Test("`update` updates workout with tags")
    func updateWorkoutWithTags() async throws {
        let workout = try await workoutRepository.create(.mock)

        var updatedWorkout = workout
        updatedWorkout.name = "Updated Workout"
        updatedWorkout.notes = "New notes"

        try await workoutRepository.update(updatedWorkout)

        let fetched = try await workoutRepository.fetch(workout.id)
        #expect(fetched.name == "Updated Workout")
        #expect(fetched.notes == "New notes")
    }
}

//
//  CoreDataWorkoutRepositoryTests.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 31.03.26.
//

import Testing
import CoreData
@testable import Liftlog

@Suite("CoreDataWorkoutRepositoryTests")
@MainActor
struct CoreDataWorkoutRepositoryTests {
    var workoutRepository: CoreDataWorkoutRepository
    var exerciseRepository: CoreDataExerciseRepository

    init() {
        let context = PersistenceController(inMemory: true).container.viewContext
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

    @Test("`addExercise` adds exercise to workout")
    func addExercise() async throws {
        let workout = try await workoutRepository.create(.mock)
        let exercise = try await exerciseRepository.create(name: "Squat", description: nil, type: .reps)

        let workoutExercise = WorkoutExerciseModel(
            id: UUID(),
            order: 0,
            exercise: exercise,
            sets: []
        )

        try await workoutRepository.addExercise(workoutExercise, to: workout.id)

        let updated = try await workoutRepository.fetch(workout.id)
        #expect(updated.exercises.count == 1)
        #expect(updated.exercises.first?.exercise.id == exercise.id)
    }
}

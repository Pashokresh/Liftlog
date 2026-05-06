//
//  CoreDataExerciseRepositoryTests.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 24.03.26.
//

import Testing
import CoreData
@testable import Liftlog

@Suite("CoreDataExerciseRepository", .serialized)
@MainActor
struct CoreDataExerciseRepositoryTests {
    var repository: CoreDataExerciseRepository

    init() {
        let context = PersistenceController(inMemory: true).container.viewContext
        repository = .init(context: context)
    }

    @Test("create adds an exercise to the database")
    func createExercise() async throws {
        let name = "Squat"

        let exercise = try await repository.create(name: name, description: "Leg exercise", type: .reps, muscleGroup: .legs)

        let all = try await repository.fetchAll()
        #expect(all.count == 1)
        #expect(all.first?.name == name)
        #expect(all.first?.id == exercise.id)
    }

    @Test("fetchAll returns all saved exercises")
    func fetchAll() async throws {
        _ = try await repository.create(name: "Squad", description: "Leg exercise", type: .reps, muscleGroup: .legs)
        _ = try await repository.create(name: "Bench Press", description: nil, type: .reps, muscleGroup: .chest)
        _ = try await repository.create(name: "Plank", description: nil, type: .time, muscleGroup: .core)

        let all = try await repository.fetchAll()
        #expect(all.count == 3)
    }

    @Test("delete deletes exercise from database")
    func deleteExercise() async throws {
        let exercise = try await repository.create(name: "Bench Press", description: nil, type: .reps, muscleGroup: .chest)

        try await repository.delete(exercise.id)

        let all = try await repository.fetchAll()
        #expect(all.isEmpty)
    }

    @Test("update updates exercise")
    func updateExercise() async throws {
        let newName = "Incline Bench Press"
        let newDescription = "Updated"

        let exercise = try await repository.create(name: "Bench Press", description: nil, type: .reps, muscleGroup: .chest)

        let updated = ExerciseModel(
            id: exercise.id,
            name: newName,
            description: newDescription,
            type: .reps,
            muscleGroup: .chest
        )

        try await repository.update(updated)
        let all = try await repository.fetchAll()
        #expect(all.first?.name == newName)
        #expect(all.first?.description == newDescription)
    }

    @Test("delete non-existent exercise doesn't throw an error")
    func deleteNonExistent() async throws {
        await #expect(throws: RepositoryError.self) {
            try await repository.delete(UUID())
        }
    }
}

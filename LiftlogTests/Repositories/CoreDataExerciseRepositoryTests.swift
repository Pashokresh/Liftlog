//
//  CoreDataExerciseRepositoryTests.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 24.03.26.
//

import Testing
import CoreData
@testable import Liftlog

@Suite("CoreDataExerciseRepository")
struct CoreDataExerciseRepositoryTests {
    
    var repository: CoreDataExerciseRepository
    
    init() {
        let context = PersistenceController(inMemory: true).container.viewContext
        repository = .init(context: context)
    }

    @Test("create adds an exercise to the database")
    func createExercise() async throws {
        let name = "Squat"
        
        let exercise = try await repository.create(name: name, description: "Leg exercise", type: .reps)
        
        let all = try await repository.fetchAll()
        #expect(all.count == 1)
        #expect(await all.first?.name == name)
        #expect(await all.first?.id == exercise.id)
    }
    
    @Test("fetchAll returns all saved exercises")
    func fetchAll() async throws {
        _ = try await repository.create(name: "Squad", description: "Leg exercise", type: .reps)
        _ = try await repository.create(name: "Bench Press", description: nil, type: .reps)
        _ = try await repository.create(name: "Plank", description: nil, type: .time)
        
        let all = try await repository.fetchAll()
        #expect(all.count == 3)
    }
    
    @Test("delete deletes exercise from database")
    func deleteExercise() async throws {
        let exercise = try await repository.create(name: "Bench Press", description: nil, type: .reps)
        
        try await repository.delete(await exercise.id)
        
        let all = try await repository.fetchAll()
        #expect(all.isEmpty)
    }
    
    @Test("update updates exercise")
    func updateExercise() async throws {
        let newName = "Incline Bench Press"
        let newDescription = "Updated"
        
        let exercise = try await repository.create(name: "Bench Press", description: nil, type: .reps)
        
        let updated = ExerciseModel(
            id: await exercise.id,
            name: newName,
            description: newDescription,
            type: .reps
        )
        
        try await repository.update(updated)
        let all = try await repository.fetchAll()
        #expect(await all.first?.name == newName)
        #expect(await all.first?.description == newDescription)
    }
    
    @Test("delete non-existent exercise doesn't throw an error")
    func deleteNonExistent() async throws {
        await #expect(throws: LiftlogError.self) {
            try await repository.delete(UUID())
        }
    }

}

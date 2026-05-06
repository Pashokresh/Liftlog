//
//  AddExercisesToWorkoutUseCaseTests.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Testing
import Foundation

@testable import Liftlog

@Suite("AddExercisesToWorkoutUseCase")
@MainActor
struct AddExercisesToWorkoutUseCaseTests {
    
    var useCase: AddExercisesToWorkoutUseCase
    var repository: WorkoutRepositoryProtocol
    
    init() {
        repository = MockWorkoutRepository()
        useCase = AddExercisesToWorkoutUseCase(workoutRepository: repository)
    }
    
    @Test("adds new exercises")
    func addsNewExercises() async throws {
        let exercises = [ExerciseModel.mock]
        let added = try await useCase.execute(
            exercises: exercises,
            workoutID: UUID(),
            currentExercises: []
        )
        #expect(added.count == 1)
    }
    
    @Test("throws error if there are duplicates")
    func throwsOnAllDuplicates() async throws {
        let exercise = ExerciseModel.mock
        let existing = WorkoutExerciseModel(
            id: UUID(),
            order: 0,
            exercise: exercise,
            sets: []
        )
        
        await #expect(throws: DomainError.duplicateExercise) {
            try await useCase.execute(
                exercises: [exercise],
                workoutID: UUID(),
                currentExercises: [existing]
            )
        }
    }
    
    @Test("skips duplicates and adds new ones")
    func skipsDuplicatesAddsNew() async throws {
        let existing = ExerciseModel(id: UUID(), name: "Squat", description: nil, type: .reps, muscleGroup: nil)
        let new = ExerciseModel(id: UUID(), name: "Bench", description: nil, type: .reps, muscleGroup: nil)
        
        let existingWorkoutExercise = WorkoutExerciseModel(
            id: UUID(),
            order: 0,
            exercise: existing,
            sets: []
        )
        
        let added = try await useCase.execute(
            exercises: [existing, new],
            workoutID: UUID(),
            currentExercises: [existingWorkoutExercise]
        )
        
        #expect(added.count == 1)
        #expect(added.first?.exercise.id == new.id)
    }
}

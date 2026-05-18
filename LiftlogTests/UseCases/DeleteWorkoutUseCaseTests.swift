//
//  DeleteWorkoutUseCaseTests.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Testing
import Foundation

@testable import Liftlog

@Suite("DeleteWorkoutUseCase")
@MainActor
struct DeleteWorkoutUseCaseTests {
    
    var useCase: DeleteWorkoutUseCase
    var repository: MockWorkoutRepository
    
    init() {
        repository = MockWorkoutRepository()
        useCase = DeleteWorkoutUseCase(workoutRepository: repository)
    }
    
    @Test("deletes workout")
    func deletesWorkout() async throws {
        let workout = WorkoutModel.mock
        repository.workouts = [workout]
        
        try await useCase.execute(workoutId: workout.id)
        
        #expect(repository.workouts.isEmpty)
    }
    
    @Test("throws workoutNotFound if workout does not exist")
    func throwsWhenNotFound() async throws {
        repository.shouldThrow = true
        
        await #expect(throws: DomainError.workoutNotFound) {
            try await useCase.execute(workoutId: UUID())
        }
    }
}

//
//  FetchExerciseProgressUseCaseTests.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Testing
import Foundation

@testable import Liftlog

@Suite("FetchExerciseProgressUseCase")
@MainActor
struct FetchExerciseProgressUseCaseTests {
    
    var useCase: FetchExerciseProgressUseCase
    var repository: MockExerciseRepository
    
    init() {
        repository = MockExerciseRepository()
        useCase = FetchExerciseProgressUseCase(exerciseRepository: repository)
    }
    
    @Test("returns entries for reps exercise with weight data")
    func returnsWeightedEntries() async throws {
        repository.progressEntries = ExerciseProgressEntry.mocks
        
        let entries = try await useCase.execute(
            for: ExerciseModel.mock,
            period: .threeMonths
        )
        
        #expect(!entries.isEmpty)
        #expect(entries.allSatisfy { $0.maxWeight > 0 || $0.totalVolume > 0 })
    }
    
    @Test("returns entries for timed exercise with duration data")
    func returnsTimedEntries() async throws {
        let timedExercise = ExerciseModel(
            id: UUID(),
            name: "Plank",
            description: nil,
            type: .time,
            muscleGroup: .core
        )
        repository.progressEntries = ExerciseProgressEntry.timedMocks
        
        let entries = try await useCase.execute(
            for: timedExercise,
            period: .threeMonths
        )
        
        #expect(!entries.isEmpty)
        #expect(entries.allSatisfy { $0.maxDuration > 0 })
    }
    
    @Test("filters out entries with no relevant data")
    func filtersEmptyEntries() async throws {
        let emptyEntry = ExerciseProgressEntry(
            id: UUID(),
            date: .now,
            maxWeight: 0,
            totalVolume: 0,
            maxDuration: 0,
            workoutName: "Empty"
        )
        repository.progressEntries = [emptyEntry]
        
        let entries = try await useCase.execute(
            for: ExerciseModel.mock,
            period: .threeMonths
        )
        
        #expect(entries.isEmpty)
    }
    
    @Test("throws exerciseNotFound when repository throws notFound")
    func throwsExerciseNotFound() async throws {
        repository.shouldThrow = true
        
        await #expect(throws: DomainError.exerciseNotFound) {
            try await useCase.execute(
                for: ExerciseModel.mock,
                period: .threeMonths
            )
        }
    }
    
    @Test("returns empty array when no entries in period")
    func returnsEmptyForNoPeriodData() async throws {
        repository.progressEntries = []
        
        let entries = try await useCase.execute(
            for: ExerciseModel.mock,
            period: .threeMonths
        )
        
        #expect(entries.isEmpty)
    }
}

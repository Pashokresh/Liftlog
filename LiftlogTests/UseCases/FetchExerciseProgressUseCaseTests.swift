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

    let repsExercise = ExerciseModel(
        id: UUID(), name: "Squat", description: nil, type: .reps, muscleGroup: .legs
    )
    let timedExercise = ExerciseModel(
        id: UUID(), name: "Plank", description: nil, type: .time, muscleGroup: .core
    )

    init() {
        repository = MockExerciseRepository()
        useCase = FetchExerciseProgressUseCase(exerciseRepository: repository)
    }

    // MARK: - Weighted exercises

    @Test("aggregates maxWeight and totalVolume from working sets")
    func aggregatesWeightedSets() async throws {
        repository.progressSessions = [
            session(sets: [
                .init(id: UUID(), order: 0, note: nil, type: .weighted(reps: 10, weight: 80), isWarmup: false),
                .init(id: UUID(), order: 1, note: nil, type: .weighted(reps: 8, weight: 100), isWarmup: false)
            ])
        ]

        let entries = try await useCase.execute(for: repsExercise, period: .all)

        let entry = try #require(entries.first)
        #expect(entries.count == 1)
        #expect(entry.maxWeight == 100)
        #expect(entry.totalVolume == 10 * 80 + 8 * 100) // 800 + 800 = 1600
    }

    @Test("excludes warmup sets from aggregation")
    func excludesWarmupSets() async throws {
        repository.progressSessions = [
            session(sets: [
                .init(id: UUID(), order: 0, note: nil, type: .weighted(reps: 10, weight: 40), isWarmup: true),
                .init(id: UUID(), order: 1, note: nil, type: .weighted(reps: 8, weight: 100), isWarmup: false)
            ])
        ]

        let entries = try await useCase.execute(for: repsExercise, period: .all)

        let entry = try #require(entries.first)
        #expect(entry.maxWeight == 100)
        // warmup (40kg × 10) must not be included in volume
        #expect(entry.totalVolume == 8 * 100)
    }

    @Test("filters out session consisting entirely of warmup sets")
    func filtersAllWarmupSession() async throws {
        repository.progressSessions = [
            session(sets: [
                .init(id: UUID(), order: 0, note: nil, type: .weighted(reps: 10, weight: 40), isWarmup: true)
            ])
        ]

        let entries = try await useCase.execute(for: repsExercise, period: .all)

        #expect(entries.isEmpty)
    }

    @Test("filters out session where all working sets have zero weight and reps")
    func filtersZeroWeightSession() async throws {
        repository.progressSessions = [
            session(sets: [
                .init(id: UUID(), order: 0, note: nil, type: .weighted(reps: 0, weight: 0), isWarmup: false)
            ])
        ]

        let entries = try await useCase.execute(for: repsExercise, period: .all)

        #expect(entries.isEmpty)
    }

    // MARK: - Timed exercises

    @Test("aggregates maxDuration from working sets")
    func aggregatesTimedSets() async throws {
        repository.progressSessions = [
            session(sets: [
                .init(id: UUID(), order: 0, note: nil, type: .timed(duration: 30), isWarmup: false),
                .init(id: UUID(), order: 1, note: nil, type: .timed(duration: 60), isWarmup: false)
            ])
        ]

        let entries = try await useCase.execute(for: timedExercise, period: .all)

        let entry = try #require(entries.first)
        #expect(entry.maxDuration == 60)
        #expect(entry.maxWeight == 0)
        #expect(entry.totalVolume == 0)
    }

    @Test("excludes warmup sets from timed aggregation")
    func excludesWarmupTimedSets() async throws {
        repository.progressSessions = [
            session(sets: [
                .init(id: UUID(), order: 0, note: nil, type: .timed(duration: 120), isWarmup: true),
                .init(id: UUID(), order: 1, note: nil, type: .timed(duration: 60), isWarmup: false)
            ])
        ]

        let entries = try await useCase.execute(for: timedExercise, period: .all)

        let entry = try #require(entries.first)
        #expect(entry.maxDuration == 60)
    }

    // MARK: - Error handling

    @Test("throws exerciseNotFound when repository throws notFound")
    func throwsExerciseNotFound() async throws {
        repository.shouldThrow = true

        await #expect(throws: DomainError.exerciseNotFound) {
            try await useCase.execute(for: repsExercise, period: .threeMonths)
        }
    }

    @Test("returns empty array when repository returns no sessions")
    func returnsEmptyWhenNoSessions() async throws {
        repository.progressSessions = []

        let entries = try await useCase.execute(for: repsExercise, period: .all)

        #expect(entries.isEmpty)
    }

    // MARK: - Helpers

    private func session(sets: [ExerciseSetModel]) -> ExerciseHistorySectionModel {
        ExerciseHistorySectionModel(
            id: UUID(),
            date: .now,
            workoutName: "Workout",
            sets: sets
        )
    }
}

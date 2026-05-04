//
//  MockExerciseRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

final class MockExerciseRepository: ExerciseRepositoryProtocol {
    private var exercises = ExerciseModel.mocks
    var shouldThrow = false

    func fetchAll() throws -> [ExerciseModel] {
        try checkThrow()

        return exercises
    }

    func fetchHistory(for exerciseID: UUID, excluding workoutExerciseID: UUID) async throws -> [ExerciseHistorySectionModel] {
        try checkThrow()

        let timeIntervalDay: TimeInterval = 86_400
        let dateYesterday = Date.now.addingTimeInterval(-timeIntervalDay)
        let dateDayBeforeYesterday = Date.now.addingTimeInterval(-timeIntervalDay * 2)

        return [
            ExerciseHistorySectionModel(
                id: UUID(),
                date: dateYesterday,
                workoutName: "Workout 2",
                sets: WorkoutExerciseModel.mock.sets),
            ExerciseHistorySectionModel(
                id: UUID(),
                date: dateDayBeforeYesterday,
                workoutName: "Workout 1",
                sets: [WorkoutExerciseModel.mock.sets.last ?? .mock])
        ]
    }

    func create(name: String, description: String?, type: ExerciseType) throws -> ExerciseModel {
        try checkThrow()

        let exercise = ExerciseModel(
            id: UUID(),
            name: name,
            description: description,
            type: type
        )

        exercises.append(exercise)

        return exercise
    }

    func update(_ model: ExerciseModel) throws {
        try checkThrow()

        guard let index = exercises.firstIndex(where: { $0.id == model.id }) else { return }
        exercises[index] = model
    }

    func delete(_ id: UUID) throws {
        try checkThrow()

        exercises.removeAll { $0.id == id }
    }

    func fetchProgress(for exerciseID: UUID, from startDate: Date) async throws -> [ExerciseProgressEntry] {
        try checkThrow()

        return ExerciseProgressEntry.mocks.filter { $0.date >= startDate }
    }

    private func checkThrow() throws {
        if shouldThrow {
            throw LiftlogError.failure(description: "Test error")
        }
    }

    static var mock: MockExerciseRepository {
        MockExerciseRepository()
    }
}

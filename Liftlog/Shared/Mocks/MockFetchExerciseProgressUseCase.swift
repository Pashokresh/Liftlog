//
//  MockFetchExerciseProgressUseCase.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

final class MockFetchExerciseProgressUseCase: FetchExerciseProgressUseCaseProtocol {
    var entries: [ExerciseProgressEntry] = ExerciseProgressEntry.mocks
    var shouldThrow = false

    func execute(for exercise: ExerciseModel, period: Period) async throws -> [ExerciseProgressEntry] {
        if shouldThrow { throw DomainError.exerciseNotFound }
        return entries.filter { $0.date >= period.startDate }
    }

    static var mock: MockFetchExerciseProgressUseCase { MockFetchExerciseProgressUseCase() }
    static var empty: MockFetchExerciseProgressUseCase {
        let mock = MockFetchExerciseProgressUseCase()
        mock.entries = []
        return mock
    }
}

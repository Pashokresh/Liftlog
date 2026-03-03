//
//  MockExerciseRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

final class MockExerciseRepository: ExerciseRepositoryProtocol {
    
    private var exercises = ExerciseModel.mocks
    
    func fetchAll() throws -> [ExerciseModel] {
        return exercises
    }
    
    func fetchHistory(for exerciseID: UUID) async throws -> [ExerciseHistorySection] {
        let timeIntervalDay: TimeInterval = 86_400
        let dateYesterday = Date.now.addingTimeInterval(-timeIntervalDay)
        let dateDayBeforeYesterday = Date.now.addingTimeInterval(-timeIntervalDay * 2)
        
        return [
            ExerciseHistorySection(
                id: UUID(),
                date: dateYesterday,
                workoutName: "Workout 2",
                sets: WorkoutExerciseModel.mock.sets),
            ExerciseHistorySection(
                id: UUID(),
                date: dateDayBeforeYesterday,
                workoutName: "Workout 1",
                sets: [WorkoutExerciseModel.mock.sets.last!])
        ]
    }
    
    func create(name: String, description: String?, type: ExerciseType) throws -> ExerciseModel {
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
        guard let index = exercises.firstIndex(where: { $0.id == model.id }) else { return }
        exercises[index] = model
    }
    
    func delete(_ id: UUID) throws {
        exercises.removeAll { $0.id == id }
    }
    
    
}

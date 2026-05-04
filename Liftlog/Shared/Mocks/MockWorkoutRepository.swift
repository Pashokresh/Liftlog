//
//  MockWorkoutRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.02.26.
//

import Foundation

final class MockWorkoutRepository: WorkoutRepositoryProtocol {
    var shouldThrow = false
    private var workouts: [WorkoutModel] = []

    init(workouts: [WorkoutModel] = []) {
        self.workouts = workouts
    }

    func fetchAll() async throws -> [WorkoutModel] {
        try checkThrow()
        return workouts
    }

    func fetch(_ id: UUID) async throws -> WorkoutModel {
        try checkThrow()

        guard let workout = workouts.first(where: { $0.id == id }) else {
            throw LiftlogError.failure(description: String(localized: "Workout not found"))
        }
        return workout
    }

    func create(_ workoutModel: WorkoutModel) async throws -> WorkoutModel {
        try checkThrow()

        workouts.append(workoutModel)
        return workoutModel
    }

    func update(_ model: WorkoutModel) async throws {
        try checkThrow()

        guard let index = getModelIndex(model.id) else { return }
        workouts[index] = model
    }

    func delete(_ id: UUID) async throws {
        try checkThrow()

        workouts.removeAll { $0.id == id }
    }

    func addExercises(_ exerciseModels: [WorkoutExerciseModel], to workoutID: UUID) async throws {
        try checkThrow()

        guard let index = getModelIndex(workoutID) else { return }
        workouts[index].exercises.append(contentsOf: exerciseModels)
    }

    func updateExercise(_ model: WorkoutExerciseModel, in workoutID: UUID) async throws {
        try checkThrow()

        guard let index = getModelIndex(workoutID),
        let workoutExerciseIndex = workouts[index].exercises.firstIndex(where: { $0.id == model.id }) else { return }

        workouts[index].exercises[workoutExerciseIndex] = model
    }

    func deleteExercise(_ id: UUID) async throws {
        try checkThrow()

        for index in workouts.indices {
            workouts[index].exercises.removeAll { $0.id == id }
        }
    }

    func addSet(_ setModel: ExerciseSetModel, to workoutExerciseID: UUID) async throws {
        try checkThrow()

        for workoutIndex in workouts.indices {
            guard let exerciseIndex = workouts[workoutIndex].exercises
                .firstIndex(where: { $0.id == workoutExerciseID }) else {
                continue
            }
            workouts[workoutIndex].exercises[exerciseIndex].sets.append(setModel)
            return
        }
    }

    func updateSet(_ model: ExerciseSetModel) async throws {
        try checkThrow()
    }

    func deleteSet(_ id: UUID) async throws {
        try checkThrow()

        for workoutIndex in workouts.indices {
            for exerciseIndex in workouts[workoutIndex].exercises.indices {
                workouts[workoutIndex].exercises[exerciseIndex].sets.removeAll { $0.id == id }
            }
        }
    }

    private func getModelIndex(_ id: UUID) -> Int? {
        workouts.firstIndex { $0.id == id }
    }

    private func checkThrow() throws {
        if shouldThrow {
            throw LiftlogError.failure(description: "Test error")
        }
    }

    // Test helper method to add workout directly without async
    func addWorkoutDirectly(_ workout: WorkoutModel) {
        workouts.append(workout)
    }
}

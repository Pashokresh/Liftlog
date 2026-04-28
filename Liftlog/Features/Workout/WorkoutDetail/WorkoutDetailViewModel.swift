//
//  WorkoutDetailViewModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class WorkoutDetailViewModel {
    private(set) var workout: WorkoutModel
    private(set) var error: Error?

    private let repository: WorkoutRepositoryProtocol

    init(workout: WorkoutModel, repository: WorkoutRepositoryProtocol) {
        self.workout = workout
        self.repository = repository
    }

    private var workoutExerciseIds: Set<UUID> {
        Set.init(workout.exercises.map(\.exercise.id))
    }

    func reloadWorkout() async {
        do {
            let updated = try await repository.fetch(workout.id)
            withAnimation(.easeInOut) {
                workout = updated
            }
        } catch {
            self.error = error
        }
    }

    func addExercises(_ exercises: [ExerciseModel]) async {
        var exercisesToAdd: [WorkoutExerciseModel] = []
        var currentWorkoutExerciseIds = workoutExerciseIds
        var errorToDisplay: Error?

        var exerciseOrder = (workout.exercises.last?.order ?? 0) + 1
        for exercise in exercises {
            if !currentWorkoutExerciseIds.contains(exercise.id) {
                let workoutExercise = WorkoutExerciseModel(
                    id: UUID(),
                    order: exerciseOrder,
                    exercise: exercise,
                    sets: []
                )
                exercisesToAdd.append(workoutExercise)
                currentWorkoutExerciseIds.insert(exercise.id)  // Fixed: use exercise.id
                exerciseOrder += 1
            } else {
                errorToDisplay = LiftlogError.failure(
                    description: AppLocalization.exerciseAlreadyAdded
                )
            }
        }

        guard !exercisesToAdd.isEmpty else {
            if let errorToDisplay {
                self.error = errorToDisplay
            }
            return
        }

        do {
            try await repository.addExercises(exercisesToAdd, to: workout.id)
            workout.exercises.append(contentsOf: exercisesToAdd)
        } catch {
            self.error = error
        }
    }

    func deleteExercise(_ id: UUID) async {
        do {
            try await repository.deleteExercise(id)
            withAnimation {
                workout.exercises.removeAll { $0.id == id }
            }
        } catch {
            self.error = error
        }
    }

    func moveExercise(fromSource: IndexSet, to destination: Int) async {
        workout.exercises.move(fromOffsets: fromSource, toOffset: destination)

        await withThrowingTaskGroup { taskGroup in
            for (index, exercise) in workout.exercises.enumerated() {
                var updated = exercise
                updated.order = index

                taskGroup.addTask {
                    try await self.repository.updateExercise(
                        updated,
                        in: self.workout.id
                    )
                }

                while !taskGroup.isEmpty {
                    do {
                        try await taskGroup.next()
                    } catch {
                        self.error = error
                        taskGroup.cancelAll()
                    }
                }
            }
        }
    }

    func addSet(_ set: ExerciseSetModel, to workoutExerciseID: UUID) async {
        do {
            try await repository.addSet(set, to: workoutExerciseID)
            withAnimation {
                guard
                    let index = workout.exercises.firstIndex(where: {
                        $0.id == workoutExerciseID
                    })
                else { return }
                workout.exercises[index].sets.append(set)
            }
        } catch {
            self.error = error
        }
    }

    func deleteSet(_ id: UUID, from workoutExerciseID: UUID) async {
        do {
            try await repository.deleteSet(id)
            withAnimation {
                guard
                    let index = workout.exercises.firstIndex(where: {
                        $0.id == workoutExerciseID
                    })
                else { return }
                workout.exercises[index].sets.removeAll { $0.id == id }
            }
        } catch {
            self.error = error
        }
    }

    func nullifyError() {
        error = nil
    }
}

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
    private let addExercisesUseCase: AddExercisesToWorkoutUseCaseProtocol

    private var loadTask: Task<Void, Never>?

    init(workout: WorkoutModel, repository: WorkoutRepositoryProtocol, addExercisesUseCase: AddExercisesToWorkoutUseCaseProtocol) {
        self.workout = workout
        self.repository = repository
        self.addExercisesUseCase = addExercisesUseCase
    }

    isolated deinit {
        cleanUp()
    }

    func cleanUp() {
        loadTask?.cancel()
    }

    private var workoutExerciseIds: Set<UUID> {
        Set.init(workout.exercises.map(\.exercise.id))
    }

    func onAppear() {
        loadTask?.cancel()

        loadTask = Task {
            await reloadWorkout()
        }
    }

    func addExercises(_ exercises: [ExerciseModel]) {
        Task { [weak self] in
            guard let self else { return }

            await addExercises(exercises)
        }
    }

    func deleteExercise(_ id: UUID) {
        Task { [weak self] in
            guard let self else { return }

            await deleteExercise(id)
        }
    }

    func moveExercise(fromSource: IndexSet, to destination: Int) {
        Task { [weak self] in
            guard let self else { return }

            await moveExercise(fromSource: fromSource, to: destination)
        }
    }

    func addSet(_ set: ExerciseSetModel, to workoutExerciseID: UUID) {
        Task { [weak self] in
            guard let self else { return }

            await addSet(set, to: workoutExerciseID)
        }
    }

    func deleteSet(_ set: UUID, from workoutExerciseID: UUID) {
        Task { [weak self] in
            guard let self else { return }

            await deleteSet(set, from: workoutExerciseID)
        }
    }

    func nullifyError() {
        error = nil
    }

    // MARK: Async Methods

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
        do {
            let added = try await addExercisesUseCase.execute(
                exercises: exercises,
                workoutID: workout.id,
                currentExercises: workout.exercises
            )

            withAnimation {
                workout.exercises.append(contentsOf: added)
            }
        } catch DomainError.duplicateExercise {
            error = DomainError.duplicateExercise
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
}

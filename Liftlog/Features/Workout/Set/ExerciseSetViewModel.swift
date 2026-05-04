//
//  ExerciseSetViewModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 02.03.26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class ExerciseSetViewModel {
    private(set) var workoutExercise: WorkoutExerciseModel
    private(set) var history: [ExerciseHistorySectionModel] = .init()
    private(set) var error: Error?
    var setToEdit: ExerciseSetModel?

    var warmupSets: [ExerciseSetModel] {
        workoutExercise.sets.filter { $0.isWarmup }
    }

    var workingSets: [ExerciseSetModel] {
        workoutExercise.sets.filter { !$0.isWarmup }
    }

    private let workoutRepository: WorkoutRepositoryProtocol
    private let exerciseRepository: ExerciseRepositoryProtocol

    init(
        workoutExercise: WorkoutExerciseModel,
        workoutRepository: WorkoutRepositoryProtocol,
        exerciseRepository: ExerciseRepositoryProtocol
    ) {
        self.workoutExercise = workoutExercise
        self.workoutRepository = workoutRepository
        self.exerciseRepository = exerciseRepository
    }

    func loadHistory() async {
        do {
            history = try await exerciseRepository.fetchHistory(
                for: workoutExercise.exercise.id,
                excluding: workoutExercise.id
            )
        } catch {
            self.error = error
        }
    }

    func addSet(set: ExerciseSetModel) async {
        var setWithOrder = set
        setWithOrder.order = workoutExercise.sets.lazy.map(\.order).max() ?? 0 + 1

        do {
            try await workoutRepository.addSet(
                setWithOrder,
                to: workoutExercise.id
            )
            withAnimation {
                workoutExercise.sets.append(setWithOrder)
            }
        } catch {
            self.error = error
        }
    }

    func copySet(_ set: ExerciseSetModel) async {
        let copiedSet = ExerciseSetModel(
            id: UUID(),
            order: workoutExercise.sets.count,
            note: set.note,
            type: set.type,
            isWarmup: set.isWarmup
        )

        await addSet(set: copiedSet)
    }

    func deleteSet(_ id: UUID) async {
        do {
            try await workoutRepository.deleteSet(id)

            withAnimation {
                workoutExercise.sets.removeAll { $0.id == id }
            }
        } catch {
            self.error = error
        }
    }

    func updateSet(_ set: ExerciseSetModel) async {
        do {
            try await workoutRepository.updateSet(set)
            guard
                let index = workoutExercise.sets.firstIndex(where: {
                    $0.id == set.id
                })
            else {
                self.error = LiftlogError.failure(
                    description: AppLocalization.setWasNotFound
                )
                return
            }
            workoutExercise.sets[index] = set
        } catch {
            self.error = error
        }
    }

    func nullifyError() {
        error = nil
    }
}

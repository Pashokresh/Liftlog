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
    private(set) var isLoadingHistory = false
    private(set) var error: Error?
    var setToEdit: ExerciseSetModel?

    var warmupSets: [ExerciseSetModel] {
        workoutExercise.sets.filter { $0.isWarmup }
    }

    var workingSets: [ExerciseSetModel] {
        workoutExercise.sets.filter { !$0.isWarmup }
    }

    private let setRepository: WorkoutSetRepositoryProtocol
    private let exerciseRepository: ExerciseRepositoryProtocol
    private var loadTask: Task<Void, Never>?

    init(
        workoutExercise: WorkoutExerciseModel,
        setRepository: WorkoutSetRepositoryProtocol,
        exerciseRepository: ExerciseRepositoryProtocol
    ) {
        self.workoutExercise = workoutExercise
        self.setRepository = setRepository
        self.exerciseRepository = exerciseRepository
    }

    func addSet(set: ExerciseSetModel) {
        Task { [weak self] in
            guard let self else { return }

            await addSet(set: set)
        }
    }

    func copySet(_ set: ExerciseSetModel) {
        let copiedSet = ExerciseSetModel(
            id: UUID(),
            order: workoutExercise.sets.count,
            note: set.note,
            type: set.type,
            isWarmup: set.isWarmup
        )

        addSet(set: copiedSet)
    }

    func deleteSet(_ set: ExerciseSetModel) {
        Task { [weak self] in
            guard let self else { return }

            await deleteSet(set.id)
        }
    }

    func updateSet(_ set: ExerciseSetModel) {
        Task { [weak self] in
            guard let self else { return }

            await updateSet(set)
        }
    }

    func nullifyError() {
        error = nil
    }

    func loadHistory() async {
        isLoadingHistory = true
        defer { isLoadingHistory = false }
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
            try await setRepository.addSet(
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

    func deleteSet(_ id: UUID) async {
        do {
            try await setRepository.deleteSet(id)

            withAnimation {
                workoutExercise.sets.removeAll { $0.id == id }
            }
        } catch {
            self.error = error
        }
    }

    func updateSet(_ set: ExerciseSetModel) async {
        do {
            try await setRepository.updateSet(set)
            guard
                let index = workoutExercise.sets.firstIndex(where: {
                    $0.id == set.id
                })
            else {
                self.error = DomainError.setNotFound
                return
            }
            workoutExercise.sets[index] = set
        } catch {
            self.error = error
        }
    }
}

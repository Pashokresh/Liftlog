//
//  WorkoutListViewModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 23.02.26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class WorkoutListViewModel {
    private(set) var workouts: [WorkoutModel] = []
    private(set) var error: Error?

    private var repository: WorkoutRepositoryProtocol

    var editingWorkout: WorkoutModel?

    init(repository: WorkoutRepositoryProtocol) {
        self.repository = repository
    }

    func loadWorkouts() {
        Task {
            do {
                workouts = try await repository.fetchAll()
            } catch {
                self.error = error
            }
        }
    }

    func deleteWorkout(_ id: UUID) {
        Task {
            do {
                try await repository.delete(id)

                withAnimation {
                    workouts.removeAll { $0.id == id }
                }
            } catch {
                self.error = error
            }
        }
    }

    func createWorkout(name: String, date: Date, notes: String?) {
        Task {
            let model = WorkoutModel(
                id: UUID(),
                name: name,
                date: date,
                notes: notes,
                tags: [],
                exercises: [],
            )

            do {
                let createdModel = try await repository.create(model)

                withAnimation {
                    workouts.append(createdModel)
                }
            } catch {
                self.error = error
            }
        }
    }

    func updateWorkout(_ updatedWorkout: WorkoutModel) {
        Task {
            do {
                try await repository.update(updatedWorkout)
                guard
                    let index = workouts.firstIndex(where: {
                        $0.id == updatedWorkout.id
                    })
                else { return }
                workouts[index] = updatedWorkout
            } catch {
                self.error = error
            }
        }
    }

    func nullifyError() {
        error = nil
    }
}

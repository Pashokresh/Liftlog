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
    private(set) var availableTags: [TagModel] = []
    private(set) var error: Error?
    var selectedTagIDs: Set<UUID> = .init()

    var editingWorkout: WorkoutModel?

    private var workoutRepository: WorkoutRepositoryProtocol
    private var tagRepository: TagRepositoryProtocol

    init(workoutRepository: WorkoutRepositoryProtocol, tagRepository: TagRepositoryProtocol) {
        self.workoutRepository = workoutRepository
        self.tagRepository = tagRepository
    }

    // MARK: - Workout

    var filteredWorkouts: [WorkoutModel] {
        guard !selectedTagIDs.isEmpty else { return workouts }
        return workouts.filter { workout in
            workout.tags.contains { selectedTagIDs.contains($0.id) }
        }
    }

    func loadWorkouts() async {
        do {
            workouts = try await workoutRepository.fetchAll()
        } catch {
            self.error = error
        }
    }

    func deleteWorkout(_ id: UUID) {
        Task {
            do {
                try await workoutRepository.delete(id)

                withAnimation {
                    workouts.removeAll { $0.id == id }
                }
            } catch {
                self.error = error
            }
        }
    }

    func createWorkout(_ model: WorkoutModel) {
        Task {
            do {
                let createdModel = try await workoutRepository.create(model)

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
                try await workoutRepository.update(updatedWorkout)
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

    // MARK: - Work with Tags

    func loadTags() async {
        do {
            availableTags = try await tagRepository.fetchAll()
        } catch {
            self.error = error
        }
    }

    func toggleTag(_ tag: TagModel) {
        if isTagSelected(tag) {
            selectedTagIDs.remove(tag.id)
        } else {
            selectedTagIDs.insert(tag.id)
        }
    }

    func isTagSelected(_ tag: TagModel) -> Bool {
        selectedTagIDs.contains(tag.id)
    }

    // MARK: - Work with errors

    func nullifyError() {
        error = nil
    }
}

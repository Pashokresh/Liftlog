//
//  AddEditWorkoutViewModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 09.03.26.
//

import Foundation
import SwiftUI

@Observable
@MainActor
final class AddEditWorkoutViewModel {
    var name: String
    var date: Date
    var notes: String
    var selectedTagIDs: Set<UUID> = .init()
    var newTagName: String = ""

    private(set) var availableTags: [TagModel] = []
    private(set) var error: Error?

    private let workout: WorkoutModel?
    private let tagRepository: TagRepositoryProtocol
    private let manageTagsUseCase: ManageWorkoutTagsUseCaseProtocol

    var isEditing: Bool { workout != nil }

    var isValid: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    var selectedTags: [TagModel] { availableTags.filter { selectedTagIDs.contains($0.id) } }

    var unselectedTags: [TagModel] { availableTags.filter { !selectedTagIDs.contains($0.id) } }

    init(tagRepository: TagRepositoryProtocol, manageTagUseCase: ManageWorkoutTagsUseCaseProtocol, workout: WorkoutModel? = nil) {
        self.tagRepository = tagRepository
        self.manageTagsUseCase = manageTagUseCase
        self.workout = workout

        self.name = workout?.name ?? ""
        self.date = workout?.date ?? Date.now
        self.notes = workout?.notes ?? ""
        workout?.tags.forEach { self.selectedTagIDs.insert($0.id) }
    }

    func createTag() {
        Task { [weak self] in
            guard let self else { return }
            await createTag()
        }
    }

    func toggleTag(_ tag: TagModel) {
        if selectedTagIDs.contains(tag.id) {
            selectedTagIDs.remove(tag.id)
        } else {
            selectedTagIDs.insert(tag.id)
        }
    }

    func makeWorkout() -> WorkoutModel {
        WorkoutModel(
            id: workout?.id ?? UUID(),
            name: name,
            date: date,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil : notes,
            tags: availableTags.filter { selectedTagIDs.contains($0.id) },
            exercises: workout?.exercises ?? []
        )
    }

    func nullifyError() {
        self.error = nil
    }

    // MARK: Async Methods

    func loadTags() async {
        do {
            availableTags = try await self.tagRepository.fetchAll()
        } catch {
            self.error = error
        }
    }

    func createTag() async {
        do {
            let tag = try await manageTagsUseCase.createTag(name: newTagName)
            availableTags.append(tag)
            selectedTagIDs.insert(tag.id)
            newTagName = ""
        } catch {
            self.error = error
        }
    }
}

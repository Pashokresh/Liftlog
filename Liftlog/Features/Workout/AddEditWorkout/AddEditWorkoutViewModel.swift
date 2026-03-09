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
    var selectedTags: [TagModel]
    var newTagName: String = ""
    
    private(set) var availableTags: [TagModel] = []
    private(set) var error: Error?
    
    private let workout: WorkoutModel?
    private let tagRepository: TagRepositoryProtocol
    
    
    var isEditing: Bool { workout != nil }
    
    var isValid: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    init(tagRepository: TagRepositoryProtocol, workout: WorkoutModel? = nil) {
        self.tagRepository = tagRepository
        self.workout = workout
            
        self.name = workout?.name ?? ""
        self.date = workout?.date ?? Date.now
        self.notes = workout?.notes ?? ""
        self.selectedTags = workout?.tags ?? []
    }
    
    func loadTags() async {
        do {
            availableTags = try await self.tagRepository.fetchAll()
        } catch {
            self.error = error
        }
    }
    
    func createTag() async {
        let trimmedTag = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTag.isEmpty else { return }
        
        do {
            let tag = try await tagRepository.create(name: trimmedTag)
            availableTags.append(tag)
            selectedTags.append(tag)
            newTagName = ""
        } catch {
            self.error = error
        }
    }
    
    func toggleTag(_ tag: TagModel) {
        if selectedTags.contains(where: { $0.id == tag.id }) {
            selectedTags.removeAll(where: { $0.id == tag.id })
        } else {
            selectedTags.append(tag)
        }
    }
    
    func makeWorkout() -> WorkoutModel {
        WorkoutModel(
            id: workout?.id ?? UUID(),
            name: name,
            date: date,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil : notes,
            tags: selectedTags,
            exercises: workout?.exercises ?? []
        )
    }
    
    func nullifyError() {
        self.error = nil
    }
}

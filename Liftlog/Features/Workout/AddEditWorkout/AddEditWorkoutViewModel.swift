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
    
    
    var isEditing: Bool { workout != nil }
    
    var isValid: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    
    var selectedTags: [TagModel] { availableTags.filter { selectedTagIDs.contains($0.id) } }
    
    var unselectedTags: [TagModel] { availableTags.filter { !selectedTagIDs.contains($0.id) }  }
    
    init(tagRepository: TagRepositoryProtocol, workout: WorkoutModel? = nil) {
        self.tagRepository = tagRepository
        self.workout = workout
            
        self.name = workout?.name ?? ""
        self.date = workout?.date ?? Date.now
        self.notes = workout?.notes ?? ""
        workout?.tags.forEach { self.selectedTagIDs.insert($0.id) }
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
            selectedTagIDs.insert(tag.id)
            newTagName = ""
        } catch {
            self.error = error
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
}

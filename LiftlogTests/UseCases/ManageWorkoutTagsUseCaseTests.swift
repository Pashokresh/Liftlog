//
//  ManageWorkoutTagsUseCaseTests.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Testing

@testable import Liftlog

@Suite("ManageWorkoutTagsUseCase")
@MainActor
struct ManageWorkoutTagsUseCaseTests {
    
    var useCase: ManageWorkoutTagsUseCase
    var workoutRepository: MockWorkoutRepository
    var tagRepository: MockTagRepository
    
    init() {
        workoutRepository = MockWorkoutRepository()
        tagRepository = MockTagRepository()
        useCase = ManageWorkoutTagsUseCase(
            workoutRepository: workoutRepository,
            tagRepository: tagRepository
        )
    }
    
    @Test("createTag creates Tag with the given name")
    func createsTag() async throws {
        let tag = try await useCase.createTag(name: "Heavy")
        #expect(tag.name == "Heavy")
    }
    
    @Test("createTag throws error on empty name")
    func throwsOnEmptyName() async throws {
        await #expect(throws: DomainError.self) {
            try await useCase.createTag(name: "   ")
        }
    }
    
    @Test("updateTags updates tags of the given workout")
    func updatesTags() async throws {
        let workout = WorkoutModel.mock
        workoutRepository.workouts = [workout]
        
        let newTags = [TagModel.mock]
        let updated = try await useCase.updateTags(newTags, for: workout)
        
        #expect(updated.tags.count == 1)
        #expect(updated.tags.first?.id == TagModel.mock.id)
    }
}

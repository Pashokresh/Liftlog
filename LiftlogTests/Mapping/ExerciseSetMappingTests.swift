//
//  ExerciseSetMappingTests.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 31.03.26.
//

import Testing
import CoreData
@testable import Liftlog

@Suite("ExerciseSet Mapping")
struct ExerciseSetMappingTests {
    
    var context: NSManagedObjectContext
    
    init() {
        context = PersistenceController(inMemory: true).container.viewContext
    }

    @Test("toDomain returns weighted for reps > 0")
    func mapsToWeighted() async throws {
        let set = ExerciseSet(context: context)
        set.id = UUID()
        set.order = 0
        set.reps = 10
        set.weight = 50.0
        set.duration = 0.0
        
        let domain = set.toDomain()
        
        if case .weighted(let reps, let weight) = await domain.type {
            #expect(reps == 10)
            #expect(weight == 50.0)
        } else {
            Issue.record("Weighted type expected")
        }
    }
    
    @Test("toDomain returns timed for duration > 0")
    func mapsToTimed() async throws {
        let set = ExerciseSet(context: context)
        set.id = UUID()
        set.order = 0
        set.reps = 0
        set.weight = 0.0
        set.duration = 30.0
        
        let domain = set.toDomain()
        
        if case .timed(let duration) = await domain.type {
            #expect(duration == 30.0)
        } else {
            Issue.record("Timed type expected")
        }
    }
    
    @Test("toDomain keeps notes")
    func mapsNotes() throws {
        let set = ExerciseSet(context: context)
        set.id = UUID()
        set.order = 0
        set.reps = 0
        set.weight = 0.0
        set.duration = 0.0
        set.note = "Heavy set"
        
        let domain = set.toDomain()
        
        #expect(domain.note == "Heavy set")
    }
    
    @Test("toDomain with nil ID generates new one")
    func mapsNilId() async throws {
        let set = ExerciseSet(context: context)
        set.order = 0
        set.reps = 0
        set.weight = 0.0
        set.duration = 0.0
        
        let domain = set.toDomain()
        
        #expect(await domain.id != UUID())
    }
}

//
//  CompositionRootTests.swift
//  LiftlogTests
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Testing
@testable import Liftlog

@Suite("CompositionRoot")
@MainActor
struct CompositionRootTests {
    @Test("makeAppDependencies wires a complete dependency graph")
    func makeAppDependencies() {
        let controller = PersistenceController(inMemory: true)
        let dependencies = CompositionRoot.makeAppDependencies(persistenceController: controller)
        let factory = ViewModelFactory(dependencies: dependencies)

        _ = factory.makeWorkoutListViewModel()
        _ = factory.makeWorkoutDetailViewModel(WorkoutModel.mock)
        _ = factory.makeExerciseLibraryViewModel()
        _ = factory.makeExercisePickerViewModel()
        _ = factory.makeExerciseSetViewModel(workoutExercise: WorkoutExerciseModel.mock)
        _ = factory.makeAddEditWorkoutViewModel()
        _ = factory.makeExerciseProgressViewModel(exercise: ExerciseModel.mock)
    }
}

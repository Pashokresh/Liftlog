//
//  CompositionRoot.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData
import Foundation

/// Wires concrete CoreData implementations to protocol-typed `AppDependencies`.
///
/// This is the only place in the app that imports concrete repository classes.
/// Everything above this layer depends on protocols only.
enum CompositionRoot {
    static func makeAppDependencies(
        persistenceController: PersistenceController = .shared
    ) -> AppDependencies {
        let context = persistenceController.container.viewContext

        let exerciseRepository = CoreDataExerciseRepository(context: context)
        let tagRepository = CoreDataTagRepository(context: context)
        let workoutRepository = CoreDataWorkoutRepository(context: context)

        return AppDependencies(
            exerciseRepository: exerciseRepository,
            workoutRepository: workoutRepository,
            workoutExerciseRepository: workoutRepository,
            workoutSetRepository: workoutRepository,
            tagRepository: tagRepository
        )
    }
}

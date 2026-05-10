//
//  MockDependencies.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.02.26.
//

import Foundation

extension AppDependencies {
    static var mock: AppDependencies {
        let mockWorkoutRepository = MockWorkoutRepository()
        return AppDependencies(
            exerciseRepository: MockExerciseRepository(),
            workoutRepository: mockWorkoutRepository,
            workoutExerciseRepository: mockWorkoutRepository,
            workoutSetRepository: mockWorkoutRepository,
            tagRepository: MockTagRepository()
        )
    }
}

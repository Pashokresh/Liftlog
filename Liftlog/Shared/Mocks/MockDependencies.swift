//
//  MockDependencies.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.02.26.
//

import Foundation

extension AppDependencies {
    
    static let mock = AppDependencies(
            exerciseRepository: MockExerciseRepository(),
            workoutRepository: MockWorkoutRepository(),
            tagRepository: MockTagRepository()
        )
}

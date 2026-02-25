//
//  ViewModelFactory.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import Foundation

@Observable
final class ViewModelFactory {
    
    private let dependencies: AppDependencies
    
    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }
    
    func makeWorkoutListViewModel() -> WorkoutListViewModel {
        WorkoutListViewModel(repository: dependencies.workoutRepository)
    }
    
    func makeExerciseLibraryViewModel() -> ExerciseLibraryViewModel {
        ExerciseLibraryViewModel(repository: dependencies.exerciseRepository)
    }
    
    func makeWorkoutDetailViewModel(_ workout: WorkoutModel) -> WorkoutDetailViewModel {
        WorkoutDetailViewModel(workout: workout, repository: dependencies.workoutRepository)
    }
}

extension ViewModelFactory {
    static let mock = ViewModelFactory(dependencies: AppDependencies.mock)
}

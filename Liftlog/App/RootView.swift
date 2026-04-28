//
//  ContentView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData
import SwiftUI

struct RootView: View {
    @Environment(ViewModelFactory.self)
    private var factory

    @State var navigationManager = NavigationManager()

    var body: some View {
        NavigationStack(
            path: $navigationManager.path
        ) {
            WorkoutListView(
                viewModel: factory.makeWorkoutListViewModel()
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .exerciseLibrary:
                    ExerciseLibraryView(
                        viewModel: factory.makeExerciseLibraryViewModel()
                    )
                case .workoutDetailView(let workout):
                    WorkoutDetailView(
                        viewModel:
                            factory.makeWorkoutDetailViewModel(
                                workout
                            )
                    )
                case .exerciseSet(let workoutExercise):
                    ExerciseSetListView(
                        viewModel: factory.makeExerciseSetViewModel(
                            workoutExercise: workoutExercise
                        )
                    )
                }
            }
        }
        .environment(navigationManager)
    }
}

#Preview {
    RootView()
        .environment(
            ViewModelFactory(
                dependencies: .mock
            )
        )
}

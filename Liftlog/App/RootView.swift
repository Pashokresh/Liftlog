//
//  ContentView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import SwiftUI
import CoreData

struct RootView: View {
    @Environment(ViewModelFactory.self) private var factory
    @State private var navigationManager = NavigationManager()

    var body: some View {
        
        NavigationStack(path: $navigationManager.path, root: {
            WorkoutListView(viewModel: factory.makeWorkoutListViewModel())
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .workoutDetailView(workoutId: let workoutID):
                        WorkoutDetailView(viewModel: factory.makeWorkoutDetailViewModel(), workoutID: workoutID)
                    case .exerciseLibrary:
                        ExerciseLibraryView(viewModel: factory.makeExerciseLibraryViewModel())
                    }
                }
        })
    }
}


#Preview {
    RootView()
        .environment(AppDependencies.mock)
}

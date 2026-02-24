//
//  ContentView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(AppDependencies.self) private var dependencies

    var body: some View {
        TabView {
            Tab(String(localized: "Workouts"), systemImage: "figure.strengthtraining.traditional") {
                WorkoutListView(
                    viewModel: WorkoutListViewModel(
                        repository: dependencies.workoutRepository
                    )
                )
            }
            Tab(String(localized: "Exercises"), systemImage: "list.bullet.rectangle") {
                ExerciseLibraryView(
                    viewModel: ExerciseLibraryViewModel(
                        repository: dependencies.exerciseRepository
                    )
                )
            }
        }
    }
}


#Preview {
    ContentView()
        .environment(AppDependencies.mock)
}

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
        ExerciseLibraryView(viewModel: ExerciseLibraryViewModel(repository: dependencies.exerciseRepository))
    }
}


#Preview {
    ContentView()
        .environment(AppDependencies.mock)
}

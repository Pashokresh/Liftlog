//
//  ExerciseSetView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 02.03.26.
//

import SwiftUI

struct ExerciseSetView: View {
    
    @State var viewModel: ExerciseSetViewModel
    
    init(viewModel: ExerciseSetViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.history) { workoutExercise in
                Section(header: Text("")) {
                    
                }
            }
        }
    }
}

#Preview {
    ExerciseSetView(
        viewModel: ExerciseSetViewModel(
            workoutExercise: WorkoutExerciseModel.mock, workoutRepository: MockWorkoutRepository(), exerciseRepository: MockExerciseRepository()
        )
    )
}

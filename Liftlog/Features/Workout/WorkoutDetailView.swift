//
//  WorkoutDetailView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import SwiftUI

struct WorkoutDetailView: View {
    
    @State private var viewModel: WorkoutDetailViewModel
    @State private var isAddingExercise = false
        
    init(viewModel: WorkoutDetailViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        List {
            ForEach(viewModel.workout.exercises) { exercise in
                Text(exercise.exercise.name)
            }
        }
        .navigationTitle(viewModel.workout.name)
        .navigationSubtitle(viewModel.workout.date.formatted(date: .abbreviated,time: .omitted))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                
            }
            ToolbarItem(placement: .topBarTrailing) {
                EditButton()
            }
            
            ToolbarItem(placement: .bottomBar) {
                Button {
                    isAddingExercise = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text(String(localized: "Add Exercise"))
                    }
                }
                .buttonStyle(.glassProminent)
            }
        }
        .overlay {
            if viewModel.workout.exercises.isEmpty {
                ContentUnavailableView(
                    String(localized: "No Exercises yet"),
                    systemImage: "figure.strengthtraining.traditional",
                    description: Text(String(localized: "Start by adding exercises here")
                    )
                )
            }
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutDetailView(
            viewModel: WorkoutDetailViewModel(
                workout: WorkoutModel.mock,
                repository: MockWorkoutRepository()
            ))
    }
}

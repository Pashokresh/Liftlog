//
//  WorkoutDetailView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import SwiftUI

struct WorkoutDetailView: View {
    
    @State private var viewModel: WorkoutDetailViewModel
    private var workoutID: UUID
    
    init(viewModel: WorkoutDetailViewModel, workoutID: UUID) {
        _viewModel = .init(initialValue: viewModel)
        self.workoutID = workoutID
    }
    
    var body: some View {
        
    }
}

#Preview {
    WorkoutDetailView(
        viewModel: WorkoutDetailViewModel(
            repository: MockWorkoutRepository()
        ),
        workoutID: WorkoutModel.mock.id)
}

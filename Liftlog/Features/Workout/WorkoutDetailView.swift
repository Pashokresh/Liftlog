//
//  WorkoutDetailView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import SwiftUI

struct WorkoutDetailView: View {
    
    @State var workout: WorkoutModel
    
    init(workout: WorkoutModel) {
        self.workout = workout
    }
    
    var body: some View {
        NavigationStack {
            
        }
    }
}

#Preview {
    WorkoutDetailView(workout: WorkoutModel.mock)
}

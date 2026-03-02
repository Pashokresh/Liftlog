//
//  WorkoutDetailRow.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 02.03.26.
//

import SwiftUI

struct WorkoutDetailRow: View {
    
    let workoutExercise: WorkoutExerciseModel
    
    private var isComplete: Bool {
        !workoutExercise.sets.isEmpty
    }
    
    var body: some View {
        HStack {
            Image(
                systemName: isComplete ?  "checkmark.circle.fill" : "circle")
            .font(.title2)
            .animation(.easeInOut) {
                $0
                    .foregroundStyle(isComplete ? .green : .gray)
                    .rotationEffect(.degrees(isComplete ? 360 : 270))
            }
            Text(workoutExercise.exercise.name)
                .font(.title2)
        }
    }
}

#Preview {
    WorkoutDetailRow(workoutExercise: WorkoutExerciseModel.mock)
}

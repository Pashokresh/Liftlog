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
        HStack(spacing: 8) {
            Image(
                systemName: isComplete
                ? Images.checkmarkCircle : Images.emptyCircle
            )
            .font(.title2)
            .animation(.easeInOut) {
                $0
                    .foregroundStyle(isComplete ? .accent : .gray)
                    .rotationEffect(.degrees(isComplete ? 360 : 270))
            }
            Text(workoutExercise.exercise.name)
                .font(.title3)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
    }
}

#Preview {
    WorkoutDetailRow(workoutExercise: WorkoutExerciseModel.mock)
}

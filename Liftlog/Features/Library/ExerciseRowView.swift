//
//  ExerciseRowView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import SwiftUI

struct ExerciseRowView: View {
    let exercise: ExerciseModel
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: exercise.type.systemImage)
                .font(.title)
                .foregroundStyle(.accent)
            
            VStack(alignment: .leading) {
                Text(exercise.name)
                    .font(.title2)
                    .foregroundStyle(.primary)
                if let description = exercise.description, !description.isEmpty {
                    Text(exercise.description!)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
            }
        }
    }
}

#Preview {
    ExerciseRowView(exercise: ExerciseModel.mock)
}

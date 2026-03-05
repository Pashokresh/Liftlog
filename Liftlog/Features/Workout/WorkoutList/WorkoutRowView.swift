//
//  WorkoutRowView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 23.02.26.
//

import SwiftUI

struct WorkoutRowView: View {

    let workout: WorkoutModel

    private var formattedDate: String {
        workout.date.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(workout.name)
                .font(.headline)
            HStack {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !workout.tags.isEmpty {
                    Text("·")
                    Text(
                        workout.tags
                            .map { $0.name }
                            .joined(separator: " ")
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WorkoutRowView(workout: WorkoutModel.mock)
}

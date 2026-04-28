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
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.name)
                .font(.title2)
            HStack {
                Text(formattedDate)
                    .font(.body)
                    .foregroundStyle(.secondary)
                if !workout.tags.isEmpty {
                    Text("·")
                    HStack {
                        ForEach(workout.tags, id: \.id) {
                            Text($0.name)
                                .font(.body)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.accentColor.opacity(0.8))
                                .foregroundStyle(.white)
                                .clipShape(.capsule)
                        }
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    WorkoutRowView(workout: WorkoutModel.mock)
}

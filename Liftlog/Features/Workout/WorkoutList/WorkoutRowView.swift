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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(workout.name)
                    .font(.headline)

                Text("·")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                if !workout.tags.isEmpty {
                    HStack {
                        ForEach(workout.tags, id: \.id) {
                            Text($0.name)
                                .font(.callout)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.8))
                                .foregroundStyle(.white)
                                .clipShape(.capsule)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
}

#Preview {
    WorkoutRowView(workout: WorkoutModel.mock)
}

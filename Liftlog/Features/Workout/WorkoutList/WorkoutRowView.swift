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
                    HStack {
                        ForEach(workout.tags, id: \.id) {
                            Text($0.name)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.8))
                                .foregroundStyle(.white)
                                .clipShape(.capsule)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WorkoutRowView(workout: WorkoutModel.mock)
}

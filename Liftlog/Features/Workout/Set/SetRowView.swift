//
//  SetRowView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import SwiftUI

struct SetRowView: View {
    let setItem: ExerciseSetModel
    let number: Int?
    let copySet: () -> Void

    @ViewBuilder private var notes: some View {
        if let note = setItem.note, !note.isEmpty {
            Text(note)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
    }

    private var setInfo: some View {
        switch setItem.type {
        case .timed(let duration):
            Text(formattedDuration(duration))
                .font(.title3)
        case let .weighted(reps, weight):
            Text("\(reps) x \(formattedWeight(weight))")
                .font(.title3)
        }
    }

    var body: some View {
        HStack {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Group {
                    if setItem.isWarmup {
                        Image(systemName: "flame")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(number?.description ?? "")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 32, alignment: .center)

                VStack(alignment: .leading, spacing: 4) {
                    setInfo
                    notes
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                copySet()
            } label: {
                Image(systemName: Images.copy)
                    .foregroundStyle(.accent)
            }
            .buttonStyle(.plain)
        }
        .padding(4)
    }

    private func formattedWeight(_ weight: Double) -> String {
        let formatter = MassFormatter()
        formatter.unitStyle = .medium
        formatter.isForPersonMassUse = true

        return formatter.string(fromKilograms: weight)
    }
}

#Preview {
    VStack {
        SetRowView(setItem: ExerciseSetModel.mocks[1], number: 1) {}
        SetRowView(setItem: ExerciseSetModel.mocks[0], number: nil) {}
    }
}

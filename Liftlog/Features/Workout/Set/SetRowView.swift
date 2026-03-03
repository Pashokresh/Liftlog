//
//  SetRowView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import SwiftUI

struct SetRowView: View {
    
    let set: ExerciseSetModel
    
    @ViewBuilder
    private var notes: some View {
        if let note = set.note, !note.isEmpty {
            Text(note)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var setInfo: some View {
        switch set.type {
        case .timed(let duration):
            Text(formattedDuration(duration))
                .font(.title3)
        case .weighted(reps: let reps, weight: let weight):
            Text("\(reps) x \(formattedWeight(weight))")
                .font(.title3)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            setInfo
            
            notes
        }
        .padding(.horizontal)
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
        SetRowView(set: ExerciseSetModel.mocks[1])
        SetRowView(set: ExerciseSetModel.mocks[0])
    }
}

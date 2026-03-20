//
//  AddEditSetView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import SwiftUI

struct AddEditSetView: View {

    let exerciseType: ExerciseType
    let existingSet: ExerciseSetModel?
    let onSave: (ExerciseSetModel) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var reps: Int
    @State private var weight: Double
    @State private var duration: Double
    @State private var note: String

    private var isEditing: Bool { existingSet != nil }

    init(
        exerciseType: ExerciseType,
        existingSet: ExerciseSetModel?,
        onSave: @escaping (ExerciseSetModel) -> Void
    ) {
        self.exerciseType = exerciseType
        self.existingSet = existingSet
        self.onSave = onSave

        switch existingSet?.type {
        case .weighted(let r, let w):
            _reps = .init(initialValue: Int(r))
            _weight = .init(initialValue: w)
            _duration = .init(initialValue: 0)
        case .timed(let d):
            _reps = .init(initialValue: 10)
            _weight = .init(initialValue: 0)
            _duration = .init(initialValue: d)
        case .none:
            _reps = .init(initialValue: 10)
            _weight = .init(initialValue: 0)
            _duration = .init(initialValue: 0)
        }

        _note = .init(initialValue: existingSet?.note ?? "")
    }

    var repSection: some View {
        Section(String(localized: "Reps and Weight")) {
            WeightInputView(reps: $reps, weight: $weight)
                .frame(maxHeight: 180)
        }
    }

    var durationSection: some View {
        Section(String(localized: "Duration")) {
            DurationInputView(duration: $duration)
                .frame(maxHeight: 180)
        }
    }

    var noteSection: some View {
        Section(String(localized: "Notes")) {
            TextField(
                String(localized: "Optional"),
                text: $note,
                axis: .vertical
            )
            .lineLimit(1...3)
            .padding()
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                switch exerciseType {
                case .time:
                    durationSection
                case .reps:
                    repSection
                }

                noteSection
            }
            .navigationTitle(
                isEditing
                    ? String(localized: "Edit Set")
                    : String(localized: "Add Set")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    AdaptiveCancelButton {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    AdaptiveConfirmButton {
                        onSave(makeSet())
                        dismiss()
                    }
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private func makeSet() -> ExerciseSetModel {
        ExerciseSetModel(
            id: existingSet?.id ?? UUID(),
            order: existingSet?.order ?? 0,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil : note,
            type: exerciseType == .reps
                ? .weighted(reps: reps, weight: weight)
                : .timed(duration: duration)
        )
    }
}

#Preview {
    AddEditSetView(
        exerciseType: .time,
        existingSet: nil,
        onSave: { _ in }
    )
}

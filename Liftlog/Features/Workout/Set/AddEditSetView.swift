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

    @Environment(\.dismiss)
    private var dismiss

    @State private var reps: Int
    @State private var weight: Double
    @State private var duration: Double
    @State private var note: String
    @State private var isWarmup: Bool

    @FocusState private var notesFocused: Bool

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
        case let .weighted(rep, weight):
            _reps = .init(initialValue: Int(rep))
            _weight = .init(initialValue: weight)
            _duration = .init(initialValue: 0)
        case .timed(let duration):
            _reps = .init(initialValue: 10)
            _weight = .init(initialValue: 0)
            _duration = .init(initialValue: duration)
        case .none:
            _reps = .init(initialValue: 10)
            _weight = .init(initialValue: 0)
            _duration = .init(initialValue: 0)
        }

        _note = .init(initialValue: existingSet?.note ?? "")
        _isWarmup = .init(initialValue: existingSet?.isWarmup ?? false)
    }

    var repSection: some View {
        Section(AppLocalization.repsAndWeight) {
            WeightInputView(reps: $reps, weight: $weight)
                .frame(maxHeight: 180)
        }
    }

    var durationSection: some View {
        Section(AppLocalization.duration) {
            DurationInputView(duration: $duration)
                .frame(maxHeight: 180)
        }
    }

    var warmupSection: some View {
        Section {
            Toggle(isOn: $isWarmup) {
                Text(AppLocalization.isWarmUp)
            }
            .tint(.accent)
        }
    }

    var noteSection: some View {
        Section(AppLocalization.notes) {
            TextField(
                AppLocalization.optional,
                text: $note,
                axis: .vertical
            )
            .lineLimit(1...3)
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .topLeading)
        }
        .onTapGesture {
            notesFocused = true
        }
    }

    @ToolbarContentBuilder private var addEditToolbarContent: some ToolbarContent {
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

    private var navTitle: String {
        isEditing
            ? AppLocalization.editSet
            : AppLocalization.addSet
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

                warmupSection

                noteSection
            }
            .contentMargins(.horizontal, 8, for: .scrollContent)
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { addEditToolbarContent }
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
                : .timed(duration: duration),
            isWarmup: isWarmup
        )
    }
}

#Preview {
    AddEditSetView(
        exerciseType: .reps,
        existingSet: nil
    ) { _ in }
}

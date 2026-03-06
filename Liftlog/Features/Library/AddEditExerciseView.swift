//
//  AddEditExerciseView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.02.26.
//

import SwiftUI

struct AddEditExerciseView: View {

    let onSave: (ExerciseModel) -> Void
    let exercise: ExerciseModel?

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var type: ExerciseType = .reps

    init(
        exercise: ExerciseModel? = nil,
        onSave: @escaping (ExerciseModel) -> Void
    ) {
        self.onSave = onSave
        self.exercise = exercise

        guard let exercise = exercise else { return }

        _name = .init(initialValue: exercise.name)
        _description = .init(initialValue: exercise.description ?? "")
        _type = .init(initialValue: type)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        String(localized: "Name"),
                        text: $name
                    )
                    Picker(String(localized: "Exercise type"), selection: $type)
                    {
                        ForEach(ExerciseType.allCases, id: \.id) {
                            Text(String(describing: $0))
                        }
                    }
                    .pickerStyle(.menu)
                    TextField(
                        String(localized: "Description (optional)"),
                        text: $description,
                        axis: .vertical
                    )
                    .lineLimit(3...6)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(
                exercise != nil
                    ? String(localized: "Edit Exercise")
                    : String(localized: "Add Exercise")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    id: "new.exercise.cancel",
                    placement: .topBarLeading
                ) {
                    AdaptiveCancelButton {
                        dismiss()
                    }
                }

                ToolbarItem(id: "new.exercise.save", placement: .topBarTrailing)
                {
                    AdaptiveConfirmButton {
                        onSave(makeExercise())
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private func makeExercise() -> ExerciseModel {
        ExerciseModel(
            id: exercise?.id ?? UUID(),
            name: name,
            description: description.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty ? nil : description,
            type: type
        )
    }
}

#Preview {
    AddEditExerciseView(
        exercise: ExerciseModel.mock
    ) { _ in }
}

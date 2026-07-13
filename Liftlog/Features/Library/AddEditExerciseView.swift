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

    @Environment(\.dismiss)
    private var dismiss

    @State private var name = ""
    @State private var description = ""
    @State private var type: ExerciseType = .reps
    @State private var muscleGroup: MuscleGroup?

    init(
        exercise: ExerciseModel? = nil,
        onSave: @escaping (ExerciseModel) -> Void
    ) {
        self.onSave = onSave
        self.exercise = exercise

        guard let exercise = exercise else { return }

        _name = .init(initialValue: exercise.name)
        _description = .init(initialValue: exercise.description ?? "")
        _type = .init(initialValue: exercise.type)
        _muscleGroup = .init(initialValue: exercise.muscleGroup)
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            formContent
                .scrollDismissesKeyboard(.interactively)
                .contentMargins(.horizontal, 8, for: .scrollContent)
                .navigationTitle(navTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar { addEditToolbarContent }
        }
    }

    private var formContent: some View {
        Form {
            Section {
                TextField(
                    AppLocalization.ExerciseLibrary.name,
                    text: $name
                )

                Picker(AppLocalization.ExerciseLibrary.exerciseType, selection: $type) {
                    ForEach(ExerciseType.allCases, id: \.id) {
                        Text(String(describing: $0))
                    }
                }
                .pickerStyle(.menu)

                Picker(
                    AppLocalization.ExerciseLibrary.muscleGroup,
                    selection: $muscleGroup
                ) {
                    Text(AppLocalization.ExerciseLibrary.notSpecified)
                        .tag(Optional<MuscleGroup>.none)

                    ForEach(MuscleGroup.allCases) { group in
                        Text(group.localizedName)
                            .tag(Optional(group))
                    }
                }
                .pickerStyle(.menu)

                TextField(
                    AppLocalization.ExerciseLibrary.descriptionOptional,
                    text: $description,
                    axis: .vertical
                )
                .lineLimit(3...6)
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
            type: type,
            muscleGroup: muscleGroup
        )
    }

    private var navTitle: String {
        exercise != nil
        ? AppLocalization.ExerciseLibrary.editExercise
        : AppLocalization.ExerciseLibrary.addExercise
    }

    @ToolbarContentBuilder private var addEditToolbarContent:
        some ToolbarContent {
        ToolbarItem(
            id: "new.exercise.cancel",
            placement: .topBarLeading
        ) {
            AdaptiveCancelButton {
                dismiss()
            }
        }

        ToolbarItem(id: "new.exercise.save", placement: .topBarTrailing) {
            AdaptiveConfirmButton {
                onSave(makeExercise())
                dismiss()
            }
            .disabled(!isValid)
        }
    }
}

#Preview {
    AddEditExerciseView(
        exercise: ExerciseModel.mock
    ) { _ in }
}

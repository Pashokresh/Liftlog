//
//  CreateEditWorkoutView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 23.02.26.
//

import SwiftUI

struct CreateEditWorkoutView: View {

    let onSave: (WorkoutModel) -> Void
    let workout: WorkoutModel?

    @Environment(\.dismiss) private var dismiss
    @State var name = ""
    @State var date = Date.now
    @State var notes = ""

    init(workout: WorkoutModel? = nil, onSave: @escaping (WorkoutModel) -> Void)
    {
        self.onSave = onSave
        self.workout = workout

        guard let workout = workout else { return }
        _name = .init(initialValue: workout.name)
        _date = .init(initialValue: workout.date)
        _notes = .init(initialValue: workout.notes ?? "")
    }

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Workout Name"), text: $name)
                    DatePicker(
                        String(localized: "Date"),
                        selection: $date,
                        displayedComponents: .date
                    )
                    TextField(
                        String(localized: "Notes (optional)"),
                        text: $notes,
                        axis: .vertical
                    )
                    .lineLimit(1...3)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(
                workout != nil
                    ? String(localized: "Edit Workout")
                    : String(localized: "Create Workout")
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(
                    id: "create.workout.cancel",
                    placement: .topBarLeading
                ) {
                    if #available(iOS 26.0, *) {
                        Button(role: .cancel) {
                            dismiss()
                        }
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text(String(localized: "Cancel"))
                        }
                    }
                }

                ToolbarItem(
                    id: "create.workout.create",
                    placement: .topBarTrailing
                ) {
                    if #available(iOS 26.0, *) {
                        Button(role: .confirm) {
                            onSave(makeWorkout())
                            dismiss()
                        }
                        .disabled(!isValid)
                    } else {
                        Button {
                            onSave(makeWorkout())
                            dismiss()
                        } label: {
                            Text(String(localized: "Save"))
                        }
                        .disabled(!isValid)                    }
                }
            }
        }
    }

    private func makeWorkout() -> WorkoutModel {
        WorkoutModel(
            id: workout?.id ?? UUID(),
            name: name,
            date: date,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil : notes,
            tags: workout?.tags ?? [],
            exercises: workout?.exercises ?? []
        )
    }
}

#Preview {
    CreateEditWorkoutView(
        workout: WorkoutModel.mock,
        onSave: { _ in }
    )
}

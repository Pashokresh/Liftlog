//
//  AddExerciseView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.02.26.
//

import SwiftUI

struct AddExerciseView: View {
    
    let onSave: (String, ExerciseType, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var type: ExerciseType = .reps
    
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
                    Picker(String(localized: "Exercise type"), selection: $type) {
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
            }
            .navigationTitle(String(localized: "New Exercise"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(id: "new.exercise.cancel", placement: .topBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(id: "new.exercise.save", placement: .topBarTrailing) {
                    Button(role: .confirm) {
                        onSave(
                            name,
                            type,
                            description
                                .trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                            nil : description
                        )
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

#Preview {
    AddExerciseView(onSave: { _, _, _ in })
}

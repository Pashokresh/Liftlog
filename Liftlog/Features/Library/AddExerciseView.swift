//
//  AddExerciseView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.02.26.
//

import SwiftUI

struct AddExerciseView: View {
    
    let onSave: (String, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    
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
    AddExerciseView(onSave: { _, _ in })
}

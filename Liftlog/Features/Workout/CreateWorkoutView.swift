//
//  CreateWorkoutView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 23.02.26.
//

import SwiftUI

struct CreateWorkoutView: View {
    
    let onSave: (String, Date, String?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State var name = ""
    @State var date = Date.now
    @State var notes = ""
    
    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "Workout Name"), text: $name)
                    DatePicker(String(localized: "Date"), selection: $date, displayedComponents: .date)
                    TextField(String(localized: "Notes (optional)"), text: $notes, axis: .vertical)
                        .lineLimit(1...3)
                }
            }
            .navigationTitle(String(localized: "New Workout"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(id: "create.workout.cancel", placement: .topBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(id: "create.workout.create", placement: .topBarTrailing) {
                    Button(role: .confirm) {
                        onSave(name, date, notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil: notes)
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }
}

#Preview {
    CreateWorkoutView(onSave: { _, _, _ in })
}

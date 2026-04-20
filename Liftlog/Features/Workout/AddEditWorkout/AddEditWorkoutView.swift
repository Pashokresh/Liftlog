//
//  AddEditWorkoutView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 23.02.26.
//

import SwiftUI

struct AddEditWorkoutView: View {

    let onSave: (WorkoutModel) -> Void
    let viewModel: AddEditWorkoutViewModel

    @Environment(\.dismiss) private var dismiss

    init(
        viewModel: AddEditWorkoutViewModel,
        onSave: @escaping (WorkoutModel) -> Void
    ) {
        self.onSave = onSave
        self.viewModel = viewModel
    }
    
    private var workoutDetailsSection: some View {
        Section {
            TextField(
                String(localized: "Workout Name"),
                text: Binding.init(
                    get: {
                        viewModel.name
                    },
                    set: { viewModel.name = $0 }
                )
            )
            DatePicker(
                String(localized: "Date"),
                selection: Binding.init(
                    get: {
                        viewModel.date
                    },
                    set: { viewModel.date = $0 }
                ),
                displayedComponents: .date
            )
            TextField(
                String(localized: "Notes (optional)"),
                text: Binding.init(
                    get: {
                        viewModel.notes
                    },
                    set: { viewModel.notes = $0 }
                ),
                axis: .vertical
            )
            .lineLimit(1...3)
        }
    }
    
    @ViewBuilder
    private var selectedTags: some View {
        if !viewModel.selectedTagIDs.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(
                        viewModel.selectedTags,
                        id: \.self
                    ) { tag in
                        TagChipView(
                            tag: tag,
                            isSelected: true,
                            onTap: { viewModel.toggleTag(tag) }
                        )
                        .padding(4)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var unselectedTags: some View {
        if !viewModel.unselectedTags.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.unselectedTags, id: \.self) {
                        tag in
                        TagChipView(
                            tag: tag,
                            isSelected: false,
                            onTap: { viewModel.toggleTag(tag) }
                        )
                        .padding(4)
                    }
                }
            }
        }
    }
    
    private var tagCreation: some View {
        HStack {
            TextField(
                String(localized: "New tag"),
                text:
                    Binding.init(
                        get: { viewModel.newTagName },
                        set: { viewModel.newTagName = $0 }
                    )
            )
            Button {
                Task { await viewModel.createTag() }
            } label: {
                Image(systemName: Images.plusCircle)
            }
            .disabled(
                viewModel.newTagName.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
            .buttonStyle(.plain)
        }
    }
    
    private var navTitle: String {
        viewModel.isEditing
            ? String(localized: "Edit Workout")
            : String(localized: "Create Workout")
    }
    
    @ToolbarContentBuilder
    private var addEditToolbarContent: some ToolbarContent {
        ToolbarItem(
            id: "create.workout.cancel",
            placement: .topBarLeading
        ) {
            AdaptiveCancelButton {
                dismiss()
            }
        }

        ToolbarItem(
            id: "create.workout.create",
            placement: .topBarTrailing
        ) {
            AdaptiveConfirmButton {
                onSave(viewModel.makeWorkout())
                dismiss()
            }
            .disabled(!viewModel.isValid)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                workoutDetailsSection

                Section(String(localized: "Tags")) {
                    selectedTags

                    unselectedTags

                    tagCreation
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { addEditToolbarContent }
            .task {
                await viewModel.loadTags()
            }
        }
    }
}

#Preview {
    AddEditWorkoutView(
        viewModel: AddEditWorkoutViewModel(
            tagRepository: MockTagRepository(),
            workout: WorkoutModel.mock
        ),
        onSave: { _ in }
    )
}

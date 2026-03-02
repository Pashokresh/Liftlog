//
//  ExerciseLibraryView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import SwiftUI

struct ExerciseLibraryView: View {
    @State private var viewModel: ExerciseLibraryViewModel
    let onSelect: ((ExerciseModel) -> Void)?
    
    @State private var isAddingExercise = false
    @State private var searchText = ""
        
    init(viewModel: ExerciseLibraryViewModel, onSelect: ((ExerciseModel) -> Void)?) {
        _viewModel = .init(
            initialValue: viewModel
        )
        
        self.onSelect = onSelect
    }
    
    private var filteredExercises: [ExerciseModel] {
        guard !searchText.isEmpty else { return viewModel.exercises }
        return viewModel.exercises.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var navigationContent: some View {
        List {
            ForEach(filteredExercises) { exercise in
                ExerciseRowView(exercise: exercise)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onSelect?(exercise)
                    }
            }
            .onDelete { indexSet in
                indexSet.forEach {
                    viewModel.deleteExercise(filteredExercises[$0].id)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: filteredExercises.map { $0.id })
        .environment(\.defaultMinListRowHeight, 80)
        .overlay {
            if filteredExercises.isEmpty {
                if !searchText.isEmpty {
                    ContentUnavailableView.search
                } else {
                    ContentUnavailableView(
                        String(
                            localized: "No exercises in the library yet."
                        ),
                        systemImage: "dumbbell",
                        description: Text(
                            String(localized: "Tap \"+\" to add a new one.")
                        )
                    )
                    .font(.title)
                }
            }
        }
        .navigationLinkIndicatorVisibility(.hidden)
        .navigationTitle(String(
            localized: "Exercise Library"
        ))
    // TODO: Fix white navigation bar background on search
        .toolbar {
            ToolbarItem(id: "exercise.library.add.new", placement: .automatic) {
                Button {
                    isAddingExercise = true
                } label: {
                    Image(systemName: "plus")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                .buttonStyle(.glassProminent)
            }
        }
        .searchable(text: $searchText,
                    prompt: String(
                        localized: "Search Exercise"
                    )
        )
        .sheet(isPresented: $isAddingExercise) {
                AddExerciseView {
                    viewModel.createExercise(
                        name: $0,
                        type: $1,
                        description: $2
                    )
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .alert(String(localized: "Error"),
                   isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.nullifyError() } }
                   )
            ) {
                Button("OK") { viewModel.nullifyError() }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
            .onAppear {
                viewModel.loadExercises()
            }
    }
    
    var body: some View {
        if onSelect != nil {
            NavigationStack {
                navigationContent
            }
        } else {
            navigationContent
        }
    }
}

#Preview {
    ExerciseLibraryView(
        viewModel: ExerciseLibraryViewModel(
            repository: MockExerciseRepository()
        ),
        onSelect: { _ in }
    )
}

//
//  ExerciseLibraryView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import SwiftUI

struct ExerciseLibraryView: View {
    @State private var viewModel: ExerciseLibraryViewModel
    @State private var isAddingExercise = false
    @State private var searchText = ""
    @State private var isSearching = false
        
    init(viewModel: ExerciseLibraryViewModel) {
        _viewModel = .init(
            initialValue: viewModel
        )
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
                if isSearching {
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
        .toolbar {
            ToolbarItem(id: "exercise.library.search", placement: .automatic) {
                Button {
                    withAnimation {
                        isSearching = true
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.headline)
                }
                .glassEffect(.identity)
            }
            
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
            
    }
    
    var body: some View {
        Group {
            if isSearching {
                navigationContent
                    .searchable(text: $searchText,
                                isPresented: $isSearching,
                                prompt: String(
                                    localized: "Search Exercise"
                                )
                    )
                    .onSubmit(of: .search) {
                        withAnimation {
                            isSearching = false
                        }
                    }
            } else {
                navigationContent
            }
        }
        .onChange(of: isSearching,{ wasSearching, nowSearching in
            if wasSearching && !nowSearching {
                searchText = ""
            }
        })
        .sheet(isPresented: $isAddingExercise) {
            AddExerciseView {
                viewModel.createExercise(
                    name: $0,
                    description: $1
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
}

#Preview {
    NavigationStack {
        ExerciseLibraryView(
            viewModel: ExerciseLibraryViewModel(
                repository: MockExerciseRepository()
            )
        )
    }
}

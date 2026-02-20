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
        _viewModel = .init(initialValue: viewModel)
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
            NavigationStack {
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
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .alert(String(localized: "Error"),
               isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
               )
        ) {
            Button("OK") { viewModel.error = nil }
        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
        .onAppear {
            viewModel.loadExercises()
        }
    }
}

#Preview {
    ExerciseLibraryView(viewModel: ExerciseLibraryViewModel(repository: MockExerciseRepository()))
}

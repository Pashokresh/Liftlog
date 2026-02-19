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
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredExercises) {
                    Text($0.name)
                }
                .onDelete { indexSet in
                    indexSet.forEach {
                        viewModel.deleteExercise(filteredExercises[$0].id)
                    }
                }
            }
            .searchable(text: $searchText)
            .environment(\.defaultMinListRowHeight, 80)
            .navigationLinkIndicatorVisibility(.hidden)
            .navigationTitle(String(localized: "Exercise Library"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                       isAddingExercise = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                    .glassEffect(.regular.tint(.green).interactive())
                    .clipShape(.circle)
                    
                }
            }
            .sheet(isPresented: $isAddingExercise) {
                EmptyView()
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
        }
        
        .onAppear {
            viewModel.loadExercises()
        }
    }
}

#Preview {
    ExerciseLibraryView(viewModel: ExerciseLibraryViewModel(repository: MockExerciseRepository()))
}

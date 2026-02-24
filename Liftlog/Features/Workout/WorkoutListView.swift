//
//  WorkoutListView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 23.02.26.
//

import SwiftUI

struct WorkoutListView: View {
    @State private var viewModel: WorkoutListViewModel
    @State private var isCreatingWorkout = false
    
    init(viewModel: WorkoutListViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.workouts) {
                    WorkoutRowView(workout: $0)
                }
                .onDelete { indexSet in
                    indexSet.forEach {
                        viewModel.deleteWorkout(viewModel.workouts[$0].id)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.workouts)
            .environment(\.defaultMinListRowHeight, 80)
            .navigationTitle(
                Text(
                    String(localized: "Workouts")
                )
            )
            .overlay {
                if viewModel.workouts.isEmpty {
                    ContentUnavailableView(String(localized: "No workouts yet"),
                                           systemImage: "dumbbell",
                                           description: Text(
                                            String(localized: "Create a new workout to get started.")
                                           )
                    )
                }
            }
            .toolbar {
                ToolbarItem(id: "workout.list.add",
                            placement: .topBarTrailing)
                {
                    Button(role: .confirm) {
                        isCreatingWorkout = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    .buttonStyle(.glassProminent)
                }
            }
            .sheet(isPresented: $isCreatingWorkout) {
                CreateWorkoutView(onSave: { name, date, notes in
                    viewModel.createWorkout(name: name, date: date, notes: notes)
                })
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }
            .alert(
                isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { if !$0 { viewModel.nullifyError() } }
                )
            ) {
                Alert(
                    title: Text(String(localized: "Error")),
                    message: Text(viewModel.error!.localizedDescription),
                    dismissButton: .default(Text(String(localized: "OK")))
                )
            }
            .onAppear {
                viewModel.loadWorkouts()
            }
        }
    }
}

#Preview {
    WorkoutListView(
        viewModel: WorkoutListViewModel(
            repository: MockWorkoutRepository()
        )
    )
}

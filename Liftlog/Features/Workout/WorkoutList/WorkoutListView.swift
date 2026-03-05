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
    
    @Environment(NavigationManager.self) var navigationManager

    init(viewModel: WorkoutListViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(viewModel.workouts) { workout in
                NavigationLink(value: Route.workoutDetailView(workout)) {
                    WorkoutRowView(workout: workout)
                }
                .swipeActions {
                    SwipeDeleteButton {
                        viewModel.deleteWorkout(workout.id)
                    }
                    
                    SwipeEditButton {
                        viewModel.editingWorkout = workout
                    }
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
                UnavailableContentView(
                    title: String(localized: "No workouts yet"),
                    message: String(
                        localized: "Create a new workout to get started."
                    )
                )
            }
        }
        .toolbar {
            ToolbarItem(
                id: "workout.list.add",
                placement: .topBarTrailing
            ) {
                AddTopBarButton {
                    isCreatingWorkout = true
                }
            }
            ToolbarItem(
                id: "exercise.library.add",
                placement: .topBarLeading
            ) {
                Button {
                    navigationManager.push(Route.exerciseLibrary)
                } label: {
                    Image(systemName:
                            Images.figureStrengthTraining
                    )
                }
            }
        }
        .sheet(isPresented: $isCreatingWorkout) {
            CreateEditWorkoutView(
                onSave: { workout in
                    viewModel.createWorkout(
                        name: workout.name,
                        date: workout.date,
                        notes: workout.notes
                    )
                },
            )
            .presentationDetents([.medium])
        }
        .sheet(item: $viewModel.editingWorkout) {
            CreateEditWorkoutView(workout: $0) { updatedWorkout in
                viewModel.updateWorkout(updatedWorkout)
            }
            .presentationDetents([.medium])
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

#Preview {
    NavigationStack {
        WorkoutListView(
            viewModel: WorkoutListViewModel(
                repository: MockWorkoutRepository()
            )
        )
    }.environment(NavigationManager())
}

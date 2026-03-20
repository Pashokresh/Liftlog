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
    @Environment(ViewModelFactory.self) var viewModelFactory

    init(viewModel: WorkoutListViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }

    var body: some View {
        List {
            ForEach(viewModel.filteredWorkouts) { workout in
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
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if viewModel.filteredWorkouts.isEmpty {
                if viewModel.workouts.isEmpty {
                    UnavailableContentView(
                        title: String(localized: "No workouts yet"),
                        message: String(
                            localized: "Create a new workout to get started."
                        )
                    )
                } else {
                    ContentUnavailableView.search
                }
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
                    Image(
                        systemName:
                            Images.bookPages
                    )
                }
            }
        }
        .safeAreaInset(edge: .top) {
            if !viewModel.availableTags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.availableTags) { tag in
                            let isSelected = viewModel.isTagSelected(tag)
                            TagSortButton(isSelected: isSelected, tag: tag) {
                                withAnimation {
                                    viewModel.toggleTag(tag)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(.bar)
            }
        }
        .sheet(isPresented: $isCreatingWorkout) {
            AddEditWorkoutView(
                viewModel: viewModelFactory.makeAddEditWorkoutViewModel(),
                onSave: { workout in
                    viewModel.createWorkout(workout)
                    updateTagsList()
                },
            )
            .presentationDetents([.large])
        }
        .sheet(item: $viewModel.editingWorkout) { workout in
            AddEditWorkoutView(
                viewModel: viewModelFactory.makeAddEditWorkoutViewModel(
                    workout: workout
                )
            ) { updatedWorkout in
                viewModel.updateWorkout(updatedWorkout)
                updateTagsList()
            }
            .presentationDetents([.large])
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
            updateTagsList()
            
            Task {
                await viewModel.loadWorkouts()
            }
        }
    }
    
    private func updateTagsList() {
        Task {
            await viewModel.loadTags()
        }
    }
}

#Preview {
    NavigationStack {
        WorkoutListView(
            viewModel: WorkoutListViewModel(
                workoutRepository: MockWorkoutRepository(),
                tagRepository: MockTagRepository()
            )
        )
    }
    .environment(NavigationManager())
    .environment(ViewModelFactory(dependencies: AppDependencies.mock))
}

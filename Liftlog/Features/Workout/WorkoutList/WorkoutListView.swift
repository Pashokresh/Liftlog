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
    @State private var workoutToDelete: WorkoutModel?

    @Environment(NavigationManager.self)
    var navigationManager

    @Environment(ViewModelFactory.self)
    var viewModelFactory

    init(viewModel: WorkoutListViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }

    @ViewBuilder private var emptyState: some View {
        if viewModel.filteredWorkouts.isEmpty {
            if viewModel.workouts.isEmpty {
                UnavailableContentView(
                    title: AppLocalization.noWorkoutsYet,
                    message: AppLocalization.createNewWorkoutToGetStarted
                )
            } else {
                ContentUnavailableView.search
            }
        }
    }

    @ToolbarContentBuilder private var toolbarContent: some ToolbarContent {
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

    @ViewBuilder private var tagsPanel: some View {
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

    @ViewBuilder private var addWorkoutSheet: some View {
        AddEditWorkoutView(
            viewModel: viewModelFactory.makeAddEditWorkoutViewModel()
        ) { workout in
            viewModel.createWorkout(workout)
        }
        .presentationDetents([.large])
    }

    private func editWorkoutSheet(_ workout: WorkoutModel) -> some View {
        AddEditWorkoutView(
            viewModel: viewModelFactory.makeAddEditWorkoutViewModel(
                workout: workout
            )
        ) { updatedWorkout in
            viewModel.updateWorkout(updatedWorkout)
        }
        .presentationDetents([.large])
    }

    var body: some View {
        List {
            ForEach(viewModel.filteredWorkouts) { workout in
                NavigationLink(value: Route.workoutDetailView(workout)) {
                    WorkoutRowView(workout: workout)
                }
                .swipeActions {
                    SwipeDeleteButton {
                        workoutToDelete = workout
                    }

                    SwipeEditButton {
                        viewModel.editingWorkout = workout
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.workouts)
        .environment(\.defaultMinListRowHeight, 80)
        .navigationTitle(Text(AppLocalization.workouts))
        .navigationBarTitleDisplayMode(.inline)
        .overlay { emptyState }
        .toolbar { toolbarContent }
        .safeAreaInset(edge: .top) { tagsPanel }
        .deleteConfirmation(
            item: $workoutToDelete
        ) { viewModel.deleteWorkout($0.id) }
        .sheet(isPresented: $isCreatingWorkout) { addWorkoutSheet }
        .sheet(item: $viewModel.editingWorkout) { editWorkoutSheet($0) }
        .alert(
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.nullifyError() } }
            )
        ) {
            Alert(
                title: Text(AppLocalization.error),
                message: Text(viewModel.error?.localizedDescription ?? ""),
                dismissButton: .default(Text(AppLocalization.okay))
            )
        }
        .onChange(
            of: isCreatingWorkout
        ) { _, isPresented in
            if !isPresented {
                updateTags()
            }
        }
        .onChange(
            of: viewModel.editingWorkout
        ) { _, workout in
            if workout == nil {
                updateTags()
            }
        }
        .task {
            await viewModel.loadWorkouts()
            await viewModel.loadTags()
        }
    }

    private func updateTags() {
        Task { await viewModel.loadTags() }
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
    .environment(ViewModelFactory(dependencies: .mock))
}

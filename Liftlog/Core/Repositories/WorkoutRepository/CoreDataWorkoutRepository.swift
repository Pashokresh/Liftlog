//
//  CoreDataWorkoutRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData
import Foundation

final class CoreDataWorkoutRepository: WorkoutRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [WorkoutModel] {
        try await context.perform {
            let request = Workout.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "date", ascending: false)
            ]

            return try self.context.fetch(request).map { $0.toDomain() }
        }
    }

    func fetch(_ id: UUID) async throws -> WorkoutModel {
        try await context.perform {
            let request = try fetchRequest(for: Workout.self, with: [id])

            guard let workout = try self.context.fetch(request).first else {
                throw LiftlogError.failure(
                    description: AppLocalization.workoutNotFound
                )
            }

            return workout.toDomain()
        }
    }

    func create(_ workoutModel: WorkoutModel) async throws -> WorkoutModel {
        try await context.perform {
            let workout = Workout(context: self.context)

            workout.id = workoutModel.id
            workout.name = workoutModel.name
            workout.date = workoutModel.date
            workout.notes = workoutModel.notes

            if !workoutModel.tags.isEmpty {
                let tagsToAddRequest = try fetchRequest(
                    for: Tag.self,
                    with: workoutModel.tags.map { $0.id }
                )
                let tagsToAdd = try self.context.fetch(tagsToAddRequest)

                tagsToAdd.forEach {
                    workout.addToTags($0)
                }
            }

            try self.context.save()

            return workout.toDomain()
        }
    }

    func update(_ model: WorkoutModel) async throws {
        try await context.perform {
            let workout = try self.fetchWorkout(model.id)

            workout.name = model.name
            workout.date = model.date
            workout.notes = model.notes

            /// * Updating Tags *

            let newTagIDs = Set(model.tags.map(\.id))
            let currentTags = (workout.tags as? Set<Tag>) ?? []
            let currentTagIds = Set(currentTags.map { $0.id })

            /// * Removing old ones *
            currentTags
                .filter { !newTagIDs.contains($0.id ?? UUID()) }
                .forEach { workout.removeFromTags($0) }

            /// * Adding new ones *
            let tagsToAddIDs = model.tags
                .filter { !currentTagIds.contains($0.id) }
                .map(\.id)

            let tagsToAddRequest = try fetchRequest(
                for: Tag.self,
                with: tagsToAddIDs
            )
            let tagsToAdd = try self.context.fetch(tagsToAddRequest)
            tagsToAdd.forEach { workout.addToTags($0) }

            try self.context.save()
        }
    }

    func delete(_ id: UUID) async throws {
        try await context.perform {
            let workout = try self.fetchWorkout(id)

            self.context.delete(workout)
            try self.context.save()
        }
    }

    func addExercises(
        _ exerciseModels: [WorkoutExerciseModel],
        to workoutID: UUID
    )
        async throws {
        try await context.perform {
            let workout = try self.fetchWorkout(workoutID)
            let exerciseIds = exerciseModels.map { $0.exercise.id }

            let exercises = try self.context.fetch(
                fetchRequest(for: Exercise.self, with: exerciseIds)
            )

            guard exercises.count == exerciseIds.count else {
                throw LiftlogError.failure(
                    description: AppLocalization.exerciseWasNotFound
                )
            }

            let exerciseMap = Dictionary(
                uniqueKeysWithValues: exercises.map { ($0.id, $0) }
            )

            for exerciseModel in exerciseModels {
                guard let exercise = exerciseMap[exerciseModel.exercise.id]
                else {
                    throw LiftlogError.failure(
                        description: AppLocalization.exerciseWasNotFound
                    )
                }
                let workoutExercise = WorkoutExercise(context: self.context)
                workoutExercise.id = exerciseModel.id
                workoutExercise.order = Int16(exerciseModel.order)
                workoutExercise.workout = workout
                workoutExercise.exercise = exercise
            }

            try self.context.save()
        }
    }

    func updateExercise(_ model: WorkoutExerciseModel, in workoutID: UUID)
        async throws {
        try await context.perform {
            let request = try fetchRequest(
                for: WorkoutExercise.self,
                with: [model.id]
            )

            guard let workoutExercise = try self.context.fetch(request).first
            else {
                throw LiftlogError.noData(
                    description: String("Exercise was not found")
                )
            }

            workoutExercise.order = Int16(model.order)

            try self.context.save()
        }
    }

    func deleteExercise(_ id: UUID) async throws {
        try await context.perform {
            let request = try fetchRequest(
                for: WorkoutExercise.self,
                with: [id]
            )

            guard let workoutExercise = try self.context.fetch(request).first
            else {
                throw LiftlogError.noData(
                    description: AppLocalization.setWasNotFound
                )
            }

            self.context.delete(workoutExercise)
            try self.context.save()
        }
    }

    func addSet(_ setModel: ExerciseSetModel, to workoutExerciseID: UUID)
        async throws {
        try await context.perform {
            let request = try fetchRequest(
                for: WorkoutExercise.self,
                with: [workoutExerciseID]
            )

            guard let workoutExercise = try self.context.fetch(request).first
            else {
                throw LiftlogError.noData(
                    description: AppLocalization.setWasNotFound
                )
            }

            let set = ExerciseSet(context: self.context)
            set.id = setModel.id
            set.order = Int16(setModel.order)
            set.note = setModel.note
            set.workoutExercise = workoutExercise

            switch setModel.type {
            case let .weighted(reps, weight):
                set.reps = Int16(reps)
                set.weight = weight
            case .timed(let duration):
                set.duration = duration
            }

            try self.context.save()
        }
    }

    func updateSet(_ model: ExerciseSetModel) async throws {
        try await context.perform {
            let request = try fetchRequest(for: ExerciseSet.self, with: [model.id])

            guard let set = try self.context.fetch(request).first else {
                throw LiftlogError.noData(
                    description: AppLocalization.setWasNotFound
                )
            }

            set.id = model.id
            set.order = Int16(model.order)
            set.note = model.note

            switch model.type {
            case let .weighted(reps, weight):
                set.reps = Int16(reps)
                set.weight = weight
            case .timed(let duration):
                set.duration = duration
            }

            try self.context.save()
        }
    }

    func deleteSet(_ id: UUID) async throws {
        try await context.perform {
            let request = try fetchRequest(for: ExerciseSet.self, with: [id])

            guard let set = try self.context.fetch(request).first else {
                throw LiftlogError.noData(
                    description: AppLocalization.setWasNotFound
                )
            }

            self.context.delete(set)
            try self.context.save()
        }
    }
}

extension CoreDataWorkoutRepository {
    func fetchWorkout(_ id: UUID) throws -> Workout {
        let request = try fetchRequest(for: Workout.self, with: [id])

        guard let workout = try context.fetch(request).first else {
            throw LiftlogError.noData(
                description: AppLocalization.setWasNotFound
            )
        }

        return workout
    }
}

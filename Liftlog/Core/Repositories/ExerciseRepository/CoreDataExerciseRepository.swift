//
//  CoreDataExerciseRepository.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import CoreData
import Foundation

final class CoreDataExerciseRepository: ExerciseRepositoryProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() async throws -> [ExerciseModel] {
        try await context.perform {
            let request = Exercise.fetchRequest()
            request.sortDescriptors = [
                NSSortDescriptor(key: "name", ascending: true)
            ]

            return try self.context.fetchOrThrow(request).map { try $0.toDomain() }
        }
    }

    func fetchHistory(for exerciseID: UUID, excluding workoutExerciseID: UUID)
        async throws
        -> [ExerciseHistorySectionModel] {
        try await context.perform {
            let request = WorkoutExercise.fetchRequest()
            request.predicate = NSPredicate(
                format: "exercise.id == %@ AND id != %@",
                exerciseID as CVarArg,
                workoutExerciseID as CVarArg
            )
            request.sortDescriptors = [
                NSSortDescriptor(key: "workout.date", ascending: false)
            ]

            return try self.context.fetchOrThrow(request).map {
                ExerciseHistorySectionModel(
                    id: $0.id ?? UUID(),
                    date: $0.workout?.date ?? Date.now,
                    workoutName: $0.workout?.name ?? "Workout",
                    sets: try ($0.sets as? Set<ExerciseSet>)?
                        .sorted { $0.order < $1.order }
                        .map { try $0.toDomain() } ?? []
                )
            }
        }
    }

    func create(name: String, description: String?, type: ExerciseType, muscleGroup: MuscleGroup?)
        async throws -> ExerciseModel {
        try await context.perform {
            let exercise = Exercise(context: self.context)
            exercise.id = UUID()
            exercise.name = name
            exercise.type = Int32(type.rawValue)
            exercise.exerciseDescription = description
            exercise.muscleGroup = Int32(muscleGroup?.rawValue ?? -1)

            try self.context.saveOrThrow()

            return try exercise.toDomain()
        }
    }

    func update(_ model: ExerciseModel) async throws {
        try await context.perform {
            let exercise = try self.fetchExercise(model.id)

            exercise.name = model.name
            exercise.type = Int32(model.type.rawValue)
            exercise.exerciseDescription = model.description
            exercise.muscleGroup = Int32(model.muscleGroup?.rawValue ?? -1)

            try self.context.saveOrThrow()
        }
    }

    func delete(_ id: UUID) async throws {
        try await context.perform {
            let exercise = try self.fetchExercise(id)

            self.context.delete(exercise)
            try self.context.saveOrThrow()
        }
    }

    func fetchProgress(for exerciseID: UUID, from startDate: Date) async throws
    -> [ExerciseHistorySectionModel] {
        try await context.perform {
            let request: NSFetchRequest<WorkoutExercise> = WorkoutExercise.fetchRequest()
            request.predicate = NSPredicate(
                format: "exercise.id == %@ AND workout.date >= %@",
                exerciseID as CVarArg,
                startDate as CVarArg
            )
            request.sortDescriptors = [
                NSSortDescriptor(key: "workout.date", ascending: true)
            ]

            return try self.context.fetchOrThrow(request).map { workoutExercise in
                guard let id = workoutExercise.id else {
                    throw RepositoryError.invalidData(
                        description: AppLocalization.missingRecordID
                    )
                }
                return ExerciseHistorySectionModel(
                    id: id,
                    date: workoutExercise.workout?.date ?? .now,
                    workoutName: workoutExercise.workout?.name ?? "",
                    sets: try (workoutExercise.sets as? Set<ExerciseSet>)?
                        .sorted { $0.order < $1.order }
                        .map { try $0.toDomain() } ?? []
                )
            }
        }
    }

    func restore(_ model: ExerciseModel) async throws {
        try await context.perform {
            // Пропускаем если уже существует
            let request = try fetchRequest(for: Exercise.self, with: [model.id])
            if (try? self.context.fetch(request).first) != nil {
                return
            }

            let exercise = Exercise(context: self.context)
            exercise.id = model.id
            exercise.name = model.name
            exercise.type = Int32(model.type.rawValue)
            exercise.exerciseDescription = model.description
            exercise.muscleGroup = Int32(model.muscleGroup?.rawValue ?? -1)
            try self.context.saveOrThrow()
        }
    }
}

extension CoreDataExerciseRepository {
    func fetchExercise(_ id: UUID) throws -> Exercise {
        let request = try fetchRequest(for: Exercise.self, with: [id])

        guard let exercise = try context.fetch(request).first else {
            throw RepositoryError.notFound(entity: "Exercise")
        }

        return exercise
    }
}

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

            return try self.context.fetch(request).map { $0.toDomain() }
        }
    }

    func fetchHistory(for exerciseID: UUID, excluding workoutExerciseID: UUID) async throws
        -> [ExerciseHistorySection] {
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

            return try self.context.fetch(request).map {
                ExerciseHistorySection(
                    id: $0.id ?? UUID(),
                    date: $0.workout?.date ?? Date.now,
                    workoutName: $0.workout?.name ?? "Workout",
                    sets: ($0.sets as? Set<ExerciseSet>)?
                        .sorted { $0.order < $1.order }
                        .map { $0.toDomain() } ?? []
                )
            }
        }
    }

    func create(name: String, description: String?, type: ExerciseType)
        async throws -> ExerciseModel {
        try await context.perform {
            let exercise = Exercise(context: self.context)
            exercise.id = UUID()
            exercise.name = name
            exercise.type = Int16(type.rawValue)
            exercise.exerciseDescription = description

            try self.context.save()

            return exercise.toDomain()
        }
    }

    func update(_ model: ExerciseModel) async throws {
        try await context.perform {
            let exercise = try self.fetchExercise(model.id)

            exercise.name = model.name
            exercise.type = Int16(model.type.rawValue)
            exercise.exerciseDescription = model.description

            try self.context.save()
        }
    }

    func delete(_ id: UUID) async throws {
        try await context.perform {
            let exercise = try self.fetchExercise(id)

            self.context.delete(exercise)
            try self.context.save()
        }
    }
}

extension CoreDataExerciseRepository {
    func fetchExercise(_ id: UUID) throws -> Exercise {
        let request = try fetchRequest(for: Exercise.self, with: [id])

        guard let exercise = try context.fetch(request).first else {
            throw LiftlogError.noData(
                description: AppLocalization.exerciseWasNotFound
            )
        }

        return exercise
    }
}

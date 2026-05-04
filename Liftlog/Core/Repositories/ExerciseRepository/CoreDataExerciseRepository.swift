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

            return try self.context.fetch(request).map {
                ExerciseHistorySectionModel(
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

    func create(name: String, description: String?, type: ExerciseType, muscleGroup: ExerciseModel.MuscleGroup?)
        async throws -> ExerciseModel {
        try await context.perform {
            let exercise = Exercise(context: self.context)
            exercise.id = UUID()
            exercise.name = name
            exercise.type = Int16(type.rawValue)
            exercise.exerciseDescription = description
            exercise.muscleGroup = Int16(muscleGroup?.rawValue ?? -1)

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
            exercise.muscleGroup = Int16(model.muscleGroup?.rawValue ?? -1)

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

    func fetchProgress(for exerciseID: UUID, from startDate: Date) async throws
    -> [ExerciseProgressEntry] {
        try await context.perform {
            let request: NSFetchRequest<WorkoutExercise> =
                WorkoutExercise.fetchRequest()
            request.predicate = NSPredicate(
                format: "exercise.id == %@ AND workout.date >= %@",
                exerciseID as CVarArg,
                startDate as CVarArg
            )
            request.sortDescriptors = [
                NSSortDescriptor(key: "workout.date", ascending: true)
            ]

            let workoutExercises: [WorkoutExercise] = try self.context.fetch(request)

            return workoutExercises.compactMap { workoutExercise -> ExerciseProgressEntry? in
                let sets = (workoutExercise.sets as? Set<ExerciseSet>) ?? []
                guard !sets.isEmpty else { return nil }

                let exerciseType =
                    ExerciseType(
                        rawValue: Int(workoutExercise.exercise?.type ?? 0)
                    ) ?? .reps

                switch exerciseType {
                case .reps:
                    let weightedSets = sets.filter {
                        $0.weight > 0 || $0.reps > 0
                    }
                    guard !weightedSets.isEmpty else { return nil }

                    let maxWeight = weightedSets.map { $0.weight }.max() ?? 0
                    let volume = weightedSets.reduce(0.0) {
                        $0 + ($1.weight * Double($1.reps))
                    }

                    return ExerciseProgressEntry(
                        id: workoutExercise.id ?? UUID(),
                        date: workoutExercise.workout?.date ?? .now,
                        maxWeight: maxWeight,
                        totalVolume: volume,
                        maxDuration: 0,
                        workoutName: workoutExercise.workout?.name ?? ""
                    )
                case .time:
                    let timedSets = sets.filter { $0.duration > 0 }
                    guard !timedSets.isEmpty else { return nil }

                    let maxDuration = timedSets.map { $0.duration }.max() ?? 0

                    return ExerciseProgressEntry(
                        id: workoutExercise.id ?? UUID(),
                        date: workoutExercise.workout?.date ?? .now,
                        maxWeight: 0,
                        totalVolume: 0,
                        maxDuration: maxDuration,
                        workoutName: workoutExercise.workout?.name ?? ""
                    )
                }
            }
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

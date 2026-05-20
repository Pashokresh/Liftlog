//
//  BackupViewModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.05.26.
//

import Observation
import Foundation

@Observable
@MainActor
final class BackupViewModel {
    private(set) var isExporting = false
    private(set) var isImporting = false
    var exportURL: URL?
    private(set) var error: Error?
    var importSuccess = false

    private let backupService: BackupService
    private let workoutRepository: CoreDataWorkoutRepository
    private let exerciseRepository: ExerciseRepositoryProtocol
    private let tagRepository: TagRepositoryProtocol

    init(
        backupService: BackupService,
        workoutRepository: CoreDataWorkoutRepository,
        exerciseRepository: ExerciseRepositoryProtocol,
        tagRepository: TagRepositoryProtocol
    ) {
        self.backupService = backupService
        self.workoutRepository = workoutRepository
        self.exerciseRepository = exerciseRepository
        self.tagRepository = tagRepository
    }

    func export() async {
        isExporting = true
        defer { isExporting = false }
        do {
            let workouts = try await workoutRepository.fetchAll()
            let exercises = try await exerciseRepository.fetchAll()
            exportURL = try backupService.export(workouts: workouts, exercises: exercises)
        } catch {
            self.error = error
        }
    }

    func importBackup(from url: URL) async {
        isImporting = true
        defer { isImporting = false }
        do {
            let backup = try backupService.importBackup(from: url)
            try await applyBackup(backup)
            importSuccess = true
        } catch {
            self.error = error
        }
    }

    func clearError() {
        error = nil
    }

    func clearExportURL() {
        exportURL = nil
    }

    // MARK: - Private

    private func applyBackup(_ backup: LiftlogBackup) async throws {
        print("📥 Applying backup v\(backup.version)")

        // 1. Восстанавливаем упражнения — пропускаем если уже существуют
        for exerciseBackup in backup.exercises {
            let model = ExerciseModel(
                id: exerciseBackup.id,
                name: exerciseBackup.name,
                description: exerciseBackup.description,
                type: ExerciseType(rawValue: exerciseBackup.type) ?? .reps,
                muscleGroup: exerciseBackup.muscleGroup.flatMap { MuscleGroup(rawValue: $0) }
            )
            do {
                try await exerciseRepository.restore(model)
                print("📥 Restored exercise: \(model.name)")
            } catch {
                print("📥 Skipped exercise \(model.name): \(error)")
            }
        }
        
        // 2. Восстанавливаем теги
        let allTags = backup.workouts.flatMap { $0.tags }
        let uniqueTags = Dictionary(grouping: allTags, by: \.id).compactMapValues(\.first)
        for tagBackup in uniqueTags.values {
            let model = TagModel(id: tagBackup.id, name: tagBackup.name)
            try await tagRepository.restore(model)
            print("📥 Restored tag: \(model.name)")
        }

        // 2.1. Восстанавливаем тренировки
        for workoutBackup in backup.workouts {
            // Пропускаем если уже существует
            if (try? await workoutRepository.fetch(workoutBackup.id)) != nil {
                print("📥 Skipped existing workout: \(workoutBackup.name)")
                continue
            }

            let tags = workoutBackup.tags.map { TagModel(id: $0.id, name: $0.name) }

            let workout = WorkoutModel(
                id: workoutBackup.id,
                name: workoutBackup.name,
                date: workoutBackup.date,
                notes: workoutBackup.notes,
                tags: tags,
                exercises: []
            )
            _ = try await workoutRepository.create(workout)
            print("📥 Created workout: \(workout.name)")

            // 3. Добавляем упражнения к тренировке
            let exerciseModels: [WorkoutExerciseModel] = workoutBackup.exercises.compactMap { weBackup in
                guard let exBackup = backup.exercises.first(where: { $0.id == weBackup.exerciseID }) else {
                    print("📥 Missing exercise \(weBackup.exerciseID) for workout \(workout.name)")
                    return nil
                }
                let exerciseModel = ExerciseModel(
                    id: exBackup.id,
                    name: exBackup.name,
                    description: exBackup.description,
                    type: ExerciseType(rawValue: exBackup.type) ?? .reps,
                    muscleGroup: exBackup.muscleGroup.flatMap { MuscleGroup(rawValue: $0) }
                )
                return WorkoutExerciseModel(
                    id: weBackup.id,
                    order: weBackup.order,
                    exercise: exerciseModel,
                    sets: []
                )
            }

            if !exerciseModels.isEmpty {
                try await workoutRepository.addExercises(exerciseModels, to: workout.id)
                print("📥 Added \(exerciseModels.count) exercises to \(workout.name)")
            }

            // 4. Добавляем сеты к каждому упражнению
            for weBackup in workoutBackup.exercises {
                for setBackup in weBackup.sets {
                    let setType: SetType
                    if let duration = setBackup.duration {
                        setType = .timed(duration: duration)
                    } else {
                        setType = .weighted(
                            reps: setBackup.reps ?? 0,
                            weight: setBackup.weight ?? 0
                        )
                    }
                    let set = ExerciseSetModel(
                        id: setBackup.id,
                        order: setBackup.order,
                        note: setBackup.note,
                        type: setType,
                        isWarmup: setBackup.isWarmup
                    )
                    try await workoutRepository.addSet(set, to: weBackup.id)
                }
                print("📥 Added \(weBackup.sets.count) sets to exercise \(weBackup.id)")
            }
        }
        print("📥 Backup applied successfully")
    }
}

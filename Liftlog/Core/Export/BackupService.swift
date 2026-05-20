//
//  BackupService.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.05.26.
//

import Foundation

final class BackupService {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func export(workouts: [WorkoutModel], exercises: [ExerciseModel]) throws -> URL {
        let backup = LiftlogBackup(
            version: 1,
            exportedAt: Date.now,
            exercises: exercises.map(\.toBackup),
            workouts: workouts.map(\.toBackup)
        )

        print("📦 Export: \(workouts.count) workouts, \(exercises.count) exercises")
        
        let data = try encoder.encode(backup)
        
        print("📦 Export JSON size: \(data.count) bytes")
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Export JSON:\n\(jsonString)")
        }

        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent("liftlog-backup-\(formattedDate()).json")

        try data.write(to: url)
        print("📦 Export saved to: \(url)")
        return url
    }

    func importBackup(from url: URL) throws -> LiftlogBackup {
        print("📥 Import from: \(url)")
        let data = try Data(contentsOf: url)
        print("📥 Import data size: \(data.count) bytes")
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Import JSON:\n\(jsonString)")
        }
        let backup = try decoder.decode(LiftlogBackup.self, from: data)
        print("📥 Import decoded: \(backup.workouts.count) workouts, \(backup.exercises.count) exercises")
        return backup
    }

    // MARK: - Private

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date.now)
    }
}

// MARK: - Domain → Backup mappings

private extension ExerciseModel {
    var toBackup: ExerciseBackup {
        ExerciseBackup(
            id: id,
            name: name,
            description: description,
            type: type.rawValue,
            muscleGroup: muscleGroup?.rawValue
        )
    }
}

private extension TagModel {
    var toBackup: TagBackup {
        TagBackup(id: id, name: name)
    }
}

private extension ExerciseSetModel {
    var toBackup: ExerciseSetBackup {
        switch type {
        case let .weighted(reps, weight):
            return ExerciseSetBackup(
                id: id,
                order: order,
                note: note,
                isWarmup: isWarmup,
                reps: reps,
                weight: weight,
                duration: nil
            )
        case .timed(let duration):
            return ExerciseSetBackup(
                id: id,
                order: order,
                note: note,
                isWarmup: isWarmup,
                reps: nil,
                weight: nil,
                duration: duration
            )
        }
    }
}

private extension WorkoutExerciseModel {
    var toBackup: WorkoutExerciseBackup {
        WorkoutExerciseBackup(
            id: id,
            order: order,
            exerciseID: exercise.id,
            sets: sets.map(\.toBackup)
        )
    }
}

private extension WorkoutModel {
    var toBackup: WorkoutBackup {
        WorkoutBackup(
            id: id,
            name: name,
            date: date,
            notes: notes,
            tags: tags.map(\.toBackup),
            exercises: exercises.map(\.toBackup)
        )
    }
}

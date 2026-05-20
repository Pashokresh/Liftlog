//
//  BackupModels.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 20.05.26.
//

import Foundation

struct LiftlogBackup: Codable {
    let version: Int
    let exportedAt: Date
    let exercises: [ExerciseBackup]
    let workouts: [WorkoutBackup]
}

struct ExerciseBackup: Codable {
    let id: UUID
    let name: String
    let description: String?
    let type: Int
    let muscleGroup: Int?
}

struct TagBackup: Codable {
    let id: UUID
    let name: String
}

struct ExerciseSetBackup: Codable {
    let id: UUID
    let order: Int
    let note: String?
    let isWarmup: Bool
    // SetType
    let reps: Int?
    let weight: Double?
    let duration: Double?
}

struct WorkoutExerciseBackup: Codable {
    let id: UUID
    let order: Int
    let exerciseID: UUID
    let sets: [ExerciseSetBackup]
}

struct WorkoutBackup: Codable {
    let id: UUID
    let name: String
    let date: Date
    let notes: String?
    let tags: [TagBackup]
    let exercises: [WorkoutExerciseBackup]
}

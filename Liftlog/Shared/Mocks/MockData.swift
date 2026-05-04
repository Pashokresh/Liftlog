//
//  MockData.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

extension ExerciseModel {
    static let mock = ExerciseModel(
        id: UUID(),
        name: "Bench Press",
        description: "Classic chest exercise",
        type: .reps,
        muscleGroup: .chest
    )

    static let mocks = [
        ExerciseModel(
            id: UUID(),
            name: "Bench Press",
            description: "Chest exercise",
            type: .time,
            muscleGroup: .chest
        ),
        ExerciseModel(
            id: UUID(),
            name: "Squat",
            description: "Leg exercise",
            type: .reps,
            muscleGroup: .legs
        ),
        ExerciseModel(
            id: UUID(),
            name: "Pull Up",
            description: "Back exercise",
            type: .reps,
            muscleGroup: .back
        ),
        ExerciseModel(
            id: UUID(),
            name: "Plank",
            description: "Core exercise",
            type: .reps,
            muscleGroup: .core
        )
    ]
}

extension ExerciseSetModel {
    static let mock = ExerciseSetModel(
        id: UUID(),
        order: 0,
        note: "Could make more reps",
        type: .weighted(reps: 10, weight: 50),
        isWarmup: false
    )

    static let mocks = [
        ExerciseSetModel(
            id: UUID(),
            order: 0,
            note: nil,
            type: .timed(duration: 60 * 30 + 15),
            isWarmup: true
        ),
        ExerciseSetModel(
            id: UUID(),
            order: 1,
            note: nil,
            type: .weighted(reps: 10, weight: 55),
            isWarmup: false
        ),
        ExerciseSetModel(
            id: UUID(),
            order: 2,
            note: "Got sweaty",
            type: .weighted(reps: 10, weight: 37.5),
            isWarmup: false
        ),
        ExerciseSetModel(
            id: UUID(),
            order: 3,
            note: "Done",
            type: .weighted(reps: 12, weight: 40.25),
            isWarmup: false
        )
    ]
}

extension TagModel {
    static let mock = TagModel(
        id: UUID(),
        name: "Heavy"
    )

    static let mocks = [
        TagModel(
            id: UUID(),
            name: "Heavy"
        ),
        TagModel(
            id: UUID(),
            name: "Moderate"
        ),
        TagModel(
            id: UUID(),
            name: "Lite"
        )
    ]
}

extension WorkoutModel {
    static let mock = WorkoutModel(
        id: UUID(),
        name: "New Training",
        date: Date.now,
        notes: "Training I need to repeat every week",
        tags: [TagModel.mock],
        exercises: []
    )

    static let mocks = [
        WorkoutModel(
            id: UUID(),
            name: "Training 1",
            date: Date.now,
            notes: "Training I need to repeat every week",
            tags: [TagModel.mock],
            exercises: []
        ),
        WorkoutModel(
            id: UUID(),
            name: "Training 2",
            date: Date.now,
            notes: "Training I need to repeat every week",
            tags: [TagModel.mocks[1]],
            exercises: []
        ),
        WorkoutModel(
            id: UUID(),
            name: "Training 3",
            date: Date.now,
            notes: "Training I need to repeat every week",
            tags: [TagModel.mocks[2]],
            exercises: []
        ),
        WorkoutModel(
            id: UUID(),
            name: "Training 4",
            date: Date.now,
            notes: "Training I can skip once in a while",
            tags: [TagModel.mocks[0]],
            exercises: []
        )
    ]
}

extension WorkoutExerciseModel {
    static let mock = WorkoutExerciseModel(
        id: UUID(),
        order: 0,
        exercise: ExerciseModel.mock,
        sets: ExerciseSetModel.mocks
    )

    static let mocks = [
        WorkoutExerciseModel(
            id: UUID(),
            order: 0,
            exercise: ExerciseModel.mock,
            sets: ExerciseSetModel.mocks
        ),
        WorkoutExerciseModel(
            id: UUID(),
            order: 1,
            exercise: ExerciseModel.mocks[1],
            sets: ExerciseSetModel.mocks
        ),
        WorkoutExerciseModel(
            id: UUID(),
            order: 2,
            exercise: ExerciseModel.mocks[2],
            sets: ExerciseSetModel.mocks
        )
    ]
}

extension ExerciseProgressEntry {
    static let mocks: [ExerciseProgressEntry] = {
        let calendar = Calendar.current
        let today = Date.now

        return [
            ExerciseProgressEntry(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -90, to: today)
                    ?? .now,
                maxWeight: 60.0,
                totalVolume: 1200.0,
                maxDuration: 0,
                workoutName: "First Training"
            ),
            ExerciseProgressEntry(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -76, to: today)
                    ?? .now,
                maxWeight: 62.5,
                totalVolume: 1375.0,
                maxDuration: 0,
                workoutName: "Push Day"
            ),
            ExerciseProgressEntry(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -62, to: today)
                    ?? .now,
                maxWeight: 62.5,
                totalVolume: 1500.0,
                maxDuration: 0,
                workoutName: "Push Day"
            ),
            ExerciseProgressEntry(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -48, to: today)
                    ?? .now,
                maxWeight: 65.0,
                totalVolume: 1560.0,
                maxDuration: 0,
                workoutName: "Heavy Day"
            ),
            ExerciseProgressEntry(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -34, to: today)
                    ?? .now,
                maxWeight: 65.0,
                totalVolume: 1625.0,
                maxDuration: 0,
                workoutName: "Push Day"
            ),
            ExerciseProgressEntry(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -27, to: today)
                    ?? .now,
                maxWeight: 67.5,
                totalVolume: 1687.5,
                maxDuration: 0,
                workoutName: "Heavy Day"
            ),
            ExerciseProgressEntry(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -20, to: today)
                    ?? .now,
                maxWeight: 67.5,
                totalVolume: 1800.0,
                maxDuration: 0,
                workoutName: "Push Day"
            ),
            ExerciseProgressEntry(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -13, to: today)
                    ?? .now,
                maxWeight: 70.0,
                totalVolume: 1750.0,
                maxDuration: 0,
                workoutName: "Heavy Day"
            ),
            ExerciseProgressEntry(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -6, to: today)
                    ?? .now,
                maxWeight: 70.0,
                totalVolume: 1960.0,
                maxDuration: 0,
                workoutName: "Push Day"
            ),
            ExerciseProgressEntry(
                id: UUID(),
                date: calendar.date(byAdding: .day, value: -1, to: today)
                    ?? .now,
                maxWeight: 72.5,
                totalVolume: 2030.0,
                maxDuration: 0,
                workoutName: "PR Day"
            )
        ]
    }()

    static let mock = mocks[0]
}

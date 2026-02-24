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
        workoutExercises: []
    )
    
    static let mocks = [
        ExerciseModel(id: UUID(), name: "Bench Press", description: "Chest exercise", workoutExercises: []),
        ExerciseModel(id: UUID(), name: "Squat", description: "Leg exercise", workoutExercises: []),
        ExerciseModel(id: UUID(), name: "Pull Up", description: "Back exercise", workoutExercises: []),
        ExerciseModel(id: UUID(), name: "Plank", description: "Core exercise",workoutExercises: [])
    ]
}

extension ExerciseSetModel {
    static let mock = ExerciseSetModel(
        id: UUID(),
        order: 0,
        note: "Could make more reps",
        type: .weighted(reps: 10, weight: 50)
    )
    
    static let mocks = [
        ExerciseSetModel(
            id: UUID(),
            order: 0,
            note: nil,
            type: .timed(duration: 60 * 30)
        ),
        ExerciseSetModel(
            id: UUID(),
            order: 1,
            note: nil,
            type: .weighted(reps: 10, weight: 55)
        ),
        ExerciseSetModel(
            id: UUID(),
            order: 2,
            note: "Got sweaty",
            type: .weighted(reps: 10, weight: 37.5)
        ),
        ExerciseSetModel(
            id: UUID(),
            order: 3,
            note: "Done",
            type: .weighted(reps: 12, weight: 40.25)
        ),
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
        tags: [TagModel.mock], exercises: ExerciseModel.mocks)
    
    static let mocks = [
        WorkoutModel(
            id: UUID(),
            name: "Training 1",
            date: Date.now,
            notes: "Training I need to repeat every week",
            tags: [TagModel.mock], exercises: ExerciseModel.mocks),
        WorkoutModel(
            id: UUID(),
            name: "Training 2",
            date: Date.now,
            notes: "Training I need to repeat every week",
            tags: [TagModel.mocks[1]], exercises: ExerciseModel.mocks),
        WorkoutModel(
            id: UUID(),
            name: "Training 3",
            date: Date.now,
            notes: "Training I need to repeat every week",
            tags: [TagModel.mocks[2]], exercises: ExerciseModel.mocks),
        WorkoutModel(
            id: UUID(),
            name: "Training 4",
            date: Date.now,
            notes: "Training I can skip once in a while",
            tags: [TagModel.mocks[0]], exercises: ExerciseModel.mocks),
    ]
}

extension WorkoutExerciseModel {
    static let mock = WorkoutExerciseModel(
        id: UUID(),
        order: 0,
        workout: WorkoutModel.mock,
        exercise: ExerciseModel.mock,
        sets: ExerciseSetModel.mocks
    )
    
    static let mocks = [
        WorkoutExerciseModel(
            id: UUID(),
            order: 0,
            workout: WorkoutModel.mock,
            exercise: ExerciseModel.mock,
            sets: ExerciseSetModel.mocks
        ),
        WorkoutExerciseModel(
            id: UUID(),
            order: 1,
            workout: WorkoutModel.mocks[2],
            exercise: ExerciseModel.mocks[1],
            sets: ExerciseSetModel.mocks
        ),
        WorkoutExerciseModel(
            id: UUID(),
            order: 2,
            workout: WorkoutModel.mocks[1],
            exercise: ExerciseModel.mocks[2],
            sets: ExerciseSetModel.mocks
        ),
    ]
}



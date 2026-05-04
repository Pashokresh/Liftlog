//
//  AppLocalization.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 05.03.26.
//

import Foundation

enum AppLocalization {
    // MARK: - Common

    static let error = String(localized: "Error")
    static let okay = String(localized: "OK")
    static let delete = String(localized: "Delete")
    static let cancel = String(localized: "Cancel")
    static let edit = String(localized: "Edit")
    static let save = String(localized: "Save")
    static let deleteConfirmationTitle = String(localized: "Delete?")
    static let deleteConfirmationMessage = String(
        localized: "This action cannot be undone."
    )
    static let add = String(localized: "Add")
    static func add(count: Int) -> String {
        AppLocalization.add + (count > 0 ? " (\(count))" : "")
    }

    // MARK: - Workout List

    static let noWorkoutsYet = String(localized: "No workouts yet")
    static let createNewWorkoutToGetStarted = String(
        localized: "Create a new workout to get started."
    )
    static let workouts = String(localized: "Workouts")

    // MARK: - Add/Edit Workout

    static let workoutName = String(localized: "Workout Name")
    static let date = String(localized: "Date")
    static let notesOptional = String(localized: "Notes (optional)")
    static let tags = String(localized: "Tags")
    static let newTag = String(localized: "New tag")
    static let editWorkout = String(localized: "Edit Workout")
    static let createWorkout = String(localized: "Create Workout")

    // MARK: - Workout Detail

    static let noExercisesYet = String(localized: "No Exercises yet")
    static let startByAddingExercisesHere = String(
        localized: "Start by adding exercises here"
    )
    static let exerciseAlreadyAdded = String(
        localized: "Exercise already added"
    )

    // MARK: - Exercise Library

    static let otherGroup = String(localized: "Other")
    // MARK: - Exercise Picker

    static let exerciseLibrary = String(
        localized: "Exercise Library"
    )
    static let searchExercise = String(localized: "Search Exercise")

    // MARK: - Add/Edit Exercise

    static let name = String(localized: "Name")
    static let exerciseType = String(localized: "Exercise type")
    static let descriptionOptional = String(localized: "Description (optional)")
    static let addExercise = String(localized: "Add Exercise")
    static let editExercise = String(localized: "Edit Exercise")
    static let muscleGroup = String(localized: "Muscle Group")
    static let notSpecified = String(localized: "Not specified")

    // MARK: - Exercise Types

    static let reps = String(localized: "Reps")
    static let time = String(localized: "Time")

    // MARK: - Exercise Muscle Groups

    static let chest = String(localized: "Chest")
    static let back = String(localized: "Back")
    static let legs = String(localized: "Legs")
    static let shoulders = String(localized: "Shoulders")
    static let arms = String(localized: "Arms")
    static let core = String(localized: "Core")
    static let cardio = String(localized: "Cardio")

    // MARK: - Exercise Set List

    static let currentWorkout = String(localized: "Current workout")
    static let noSetsYet = String(localized: "No Sets yet")
    static let startByAddingSetsHere = String(
        localized: "Start by adding sets here"
    )
    static let addSet = String(localized: "Add Set")
    static let warmUp = String(localized: "Warm-Up")
    static let workingSets = String(localized: "Working Sets")

    // MARK: - Add/Edit Set

    static let repsAndWeight = String(localized: "Reps and Weight")
    static let duration = String(localized: "Duration")
    static let notes = String(localized: "Notes")
    static let optional = String(localized: "Optional")
    static let editSet = String(localized: "Edit Set")
    static let isWarmUp = String(localized: "Is Warm-Up?")

    // MARK: - Weight/Duration Input

    static let repsLowercase = String(localized: "reps")
    static let kilogram = String(localized: "kg")
    static let gram = String(localized: "g")
    static let min = String(localized: "min")
    static let sec = String(localized: "sec")

    // MARK: - Repository Errors

    /// Generic "not found" error message
    static func itemNotFound(_ item: String) -> String {
        String(localized: "\(item) not found")
    }

    static let workoutNotFound = itemNotFound("Workout")
    static let exerciseWasNotFound = itemNotFound("Exercise")
    static let setWasNotFound = itemNotFound("Set")
    static let tagWasNotFound = itemNotFound("Tag")
}

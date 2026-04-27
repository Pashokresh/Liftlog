//
//  AppLocalization.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 05.03.26.
//

import Foundation

final class AppLocalization {
    
    // MARK: - Common
    
    static let error = String(localized: "Error")
    static let ok = String(localized: "OK")
    static let delete = String(localized: "Delete")
    static let cancel = String(localized: "Cancel")
    static let edit = String(localized: "Edit")
    static let save = String(localized: "Save")
    static let deleteConfirmationTitle = String(localized: "Delete?")
    static let deleteConfirmationMessage = String(localized: "This action cannot be undone.")
    
    // MARK: - Workout List
    
    static let noWorkoutsYet = String(localized: "No workouts yet")
    static let createNewWorkoutToGetStarted = String(localized: "Create a new workout to get started.")
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
    static let startByAddingExercisesHere = String(localized: "Start by adding exercises here")
    static let exerciseAlreadyAdded = String(localized: "Exercise already added")
    
    // MARK: - Exercise Picker
    
    static let pickExerciseFromLibrary = String(localized: "Pick Exercise from the Library")
    static let searchExercise = String(localized: "Search Exercise")
    
    // MARK: - Add/Edit Exercise
    
    static let name = String(localized: "Name")
    static let exerciseType = String(localized: "Exercise type")
    static let descriptionOptional = String(localized: "Description (optional)")
    static let addExercise = String(localized: "Add Exercise")
    static let editExercise = String(localized: "Edit Exercise")
    
    // MARK: - Exercise Types
    
    static let reps = String(localized: "Reps")
    static let time = String(localized: "Time")
    
    // MARK: - Exercise Set List
    
    static let currentWorkout = String(localized: "Current workout")
    static let noSetsYet = String(localized: "No Sets yet")
    static let startByAddingSetsHere = String(localized: "Start by adding sets here")
    static let addSet = String(localized: "Add set")
    static let setNotFound = String(localized: "Set not found")
    
    // MARK: - Add/Edit Set
    
    static let repsAndWeight = String(localized: "Reps and Weight")
    static let duration = String(localized: "Duration")
    static let notes = String(localized: "Notes")
    static let optional = String(localized: "Optional")
    static let editSet = String(localized: "Edit Set")
    static let addSetTitle = String(localized: "Add Set")
    
    // MARK: - Weight/Duration Input
    
    static let repsLowercase = String(localized: "reps")
    static let kg = String(localized: "kg")
    static let g = String(localized: "g")
    static let min = String(localized: "min")
    static let sec = String(localized: "sec")
    
    // MARK: - Repository Errors
    
    static let workoutNotFound = String(localized: "Workout not found")
    static let exerciseWasNotFound = String(localized: "Exercise was not found")
    static let setWasNotFound = String(localized: "Set was not found")
    static let tagWasNotFound = String(localized: "Tag was not found")
    
}


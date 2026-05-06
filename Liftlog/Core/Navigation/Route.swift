//
//  Route.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import Foundation
import SwiftUI

enum Route: Hashable, Equatable {
    case exerciseLibrary
    case workoutDetailView(WorkoutModel)
    case exerciseSet(WorkoutExerciseModel)
    case exerciseProgress(ExerciseModel)
}

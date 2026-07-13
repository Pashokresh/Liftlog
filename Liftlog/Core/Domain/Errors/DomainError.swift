//
//  DomainError.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Foundation

enum DomainError: Error, Equatable {
    case duplicateExercise
    case workoutNotFound
    case exerciseNotFound
    case setNotFound
    case tagNotFound
    case invalidInput(description: String)
}

extension DomainError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .duplicateExercise:
            return AppLocalization.Workout.exerciseAlreadyAdded
        case .workoutNotFound:
            return AppLocalization.Errors.workoutNotFound
        case .exerciseNotFound:
            return AppLocalization.Errors.exerciseWasNotFound
        case .setNotFound:
            return AppLocalization.Errors.setWasNotFound
        case .tagNotFound:
            return AppLocalization.Errors.tagWasNotFound
        case .invalidInput(let description):
            return description
        }
    }
}

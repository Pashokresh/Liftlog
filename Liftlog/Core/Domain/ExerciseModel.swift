//
//  ExerciseModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import Foundation

enum ExerciseType: Int, CaseIterable, Identifiable, CustomStringConvertible {
    
    case time = 0
    case reps = 1
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .reps:
            return String(localized: "Reps")
        case .time:
            return String(localized: "Time")
        }
    }
}

struct ExerciseModel: Identifiable, Equatable, Hashable {
    
    let id: UUID
    let name: String
    let description: String?
    let type: ExerciseType
}

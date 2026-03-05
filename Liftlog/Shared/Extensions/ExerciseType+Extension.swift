//
//  ExerciseType+Extension.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 05.03.26.
//

extension ExerciseType {
    
    var systemImage: String {
        switch self {
        case.reps:
            return Images.repeatSymbol
        case .time:
            return Images.stopwatch
        }
    }
}

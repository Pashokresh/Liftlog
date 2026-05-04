//
//  MuscleGroup.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 04.05.26.
//

import Foundation

enum MuscleGroup: Int, CaseIterable, Identifiable, Hashable {
    case chest = 0
    case back = 1
    case legs = 2
    case shoulders = 3
    case arms = 4
    case core = 5
    case cardio = 6

    var id: Int { rawValue }

    var localizedName: String {
        switch self {
        case .chest: AppLocalization.chest
        case .back: AppLocalization.back
        case .legs: AppLocalization.legs
        case .shoulders: AppLocalization.shoulders
        case .arms: AppLocalization.arms
        case .core: AppLocalization.core
        case .cardio: AppLocalization.cardio
        }
    }
}

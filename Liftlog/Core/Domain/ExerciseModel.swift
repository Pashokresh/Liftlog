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
            return AppLocalization.reps
        case .time:
            return AppLocalization.time
        }
    }
}

struct ExerciseModel: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let description: String?
    let type: ExerciseType
    let muscleGroup: MuscleGroup?
}

extension ExerciseModel {
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
}

extension Array where Element == ExerciseModel {
    func groupedByMuscle() -> [MuscleGroupSection] {
        let grouped = Dictionary(grouping: self) { $0.muscleGroup }

        let withGroup = ExerciseModel.MuscleGroup.allCases
            .compactMap { group -> MuscleGroupSection? in
                guard let exercises = grouped[Optional(group)],
                    !exercises.isEmpty
                else { return nil }
                return MuscleGroupSection(group: group, exercises: exercises)
            }

        let withoutGroup = grouped[nil] ?? []

        if withoutGroup.isEmpty {
            return withGroup
        }
        return withGroup + [
            MuscleGroupSection(group: nil, exercises: withoutGroup)
        ]
    }
}

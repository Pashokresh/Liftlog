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

extension Array where Element == ExerciseModel {
    func groupedByMuscle() -> [MuscleGroupSection] {
        let grouped = Dictionary(grouping: self) { $0.muscleGroup }

        let withGroup = MuscleGroup.allCases
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

//
//  MuscleGroupSection.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 04.05.26.
//

struct MuscleGroupSection: Identifiable {
    let group: ExerciseModel.MuscleGroup?
    let exercises: [ExerciseModel]

    var id: Int { group?.rawValue ?? -1 }

    var title: String {
        group?.localizedName ?? AppLocalization.otherGroup
    }
}

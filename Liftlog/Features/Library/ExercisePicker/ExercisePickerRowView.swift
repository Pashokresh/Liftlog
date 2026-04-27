//
//  ExercisePickerRowView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 27.04.26.
//

import SwiftUI

struct ExercisePickerRowView: View {
    
    var exercise: ExerciseModel
    var order: Int?
    
    var body: some View {
        HStack {
            SelectedOrderIndicator(order: order)
            
            ExerciseRowView(exercise: exercise)
        }
    }
}

#Preview {
    ExercisePickerRowView(exercise: .mock, order: 10)
}

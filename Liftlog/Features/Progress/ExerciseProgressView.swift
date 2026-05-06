//
//  ExerciseProgressView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import SwiftUI

struct ExerciseProgressView: View {
    @State private var viewModel: ExerciseProgressViewModel

    init(viewModel: ExerciseProgressViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if viewModel.hasData {
                }
            }
        }
    }
}

#Preview {
    ExerciseProgressView(
        viewModel: ViewModelFactory(dependencies: .mock)
            .makeExerciseProgressViewModel(exercise: ExerciseModel.mock)
    )
}

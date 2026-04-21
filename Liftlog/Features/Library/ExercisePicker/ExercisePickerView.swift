//
//  ExercisePickerView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 21.04.26.
//

import SwiftUI

struct ExercisePickerView: View {
    @State private var viewModel: ExercisePickerViewModel

    init(
        viewModel: ExercisePickerViewModel,
        onAdd: (OrderedSet<ExerciseModel>) -> Void
    ) {
        _viewModel = .init(initialValue: viewModel)
    }

    var body: some View {
        Text( /*@START_MENU_TOKEN@*/"Hello, World!" /*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ExercisePickerView(
        viewModel: ExercisePickerViewModel(
            repository: MockExerciseRepository()
        ),
        onAdd: { _ in
        }
    )
}

//
//  ExerciseProgressView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import SwiftUI
import Charts

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

// MARK: - Chart Interactive modifier

private extension View {
    @ViewBuilder var chartInteractive: some View {
        if #available(iOS 26, *) {
            self.chartScrollableAxes(.horizontal)
        } else {
            self
        }
    }
}

// MARK: Preview

#Preview {
    NavigationStack {
        ExerciseProgressView(
            viewModel: ExerciseProgressViewModel(
                exercise: .mock,
                fetchProgressUseCase: MockFetchExerciseProgressUseCase()
            )
        )
    }
}

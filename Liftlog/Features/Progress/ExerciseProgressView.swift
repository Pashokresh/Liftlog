//
//  ExerciseProgressView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import Charts
import SwiftUI

struct ExerciseProgressView: View {
    @State private var viewModel: ExerciseProgressViewModel

    init(viewModel: ExerciseProgressViewModel) {
        _viewModel = .init(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                PeriodPicker(selectedPeriod: viewModel.selectedPeriod) { period in
                    viewModel.selectedPeriod = period
                }
            }
            .onChange(of: viewModel.selectedPeriod) {
                viewModel.loadProgress()
            }
            .overlay {
                if !viewModel.hasData {
                    emptyState
                }
            }
        }
    }

    // MARK: - Empty State

    @ViewBuilder private var emptyState: some View {
        ContentUnavailableView(
            AppLocalization.noProgressYet,
            systemImage: Images.chart,
            description: Text(AppLocalization.startLoggingToSeeProgress)
        )
        .frame(maxHeight: .infinity)
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

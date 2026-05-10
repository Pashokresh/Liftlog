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
        Group {
            if viewModel.hasData {
                ScrollView {
                    VStack(spacing: 24) {
                        primaryChart
                        if viewModel.exercise.type == .reps {
                            totalVolumeChart
                        }
                    }
                    .padding()
                }
            } else {
                emptyState
            }
        }
        .navigationTitle(viewModel.exercise.name)
        .safeAreaInset(edge: .bottom) {
            PeriodPicker(selectedPeriod: viewModel.selectedPeriod) { period in
                viewModel.selectedPeriod = period
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(.bar)
        }
        .onChange(of: viewModel.selectedPeriod) {
            viewModel.loadProgress()
        }
        .task {
            await viewModel.loadProgress()
        }
    }

    @ViewBuilder private var primaryChart: some View {
        ExerciseProgressLineChartView(
            data: viewModel.chartEntries,
            title: viewModel.chartTitle,
            valueFormatter: viewModel.chartFormatter
        )
    }

    @ViewBuilder private var totalVolumeChart: some View {
        ExerciseProgressLineChartView(
            data: viewModel.volumeEntries,
            title: AppLocalization.totalVolume,
            valueFormatter: { $0.formattedVolume }
        )
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

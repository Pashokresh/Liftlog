//
//  ExerciseProgressViewModel.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 30.04.26.
//

import Foundation
import Observation

@Observable
@MainActor
final class ExerciseProgressViewModel {
    let exercise: ExerciseModel
    private(set) var entries: [ExerciseProgressEntry] = []
    private(set) var error: Error?
    var selectedPeriod: Period = .threeMonths {
        didSet { loadProgress() }
    }

    private let fetchProgressUseCase: FetchExerciseProgressUseCaseProtocol
    private var loadTask: Task<Void, Never>?

    init(
        exercise: ExerciseModel,
        fetchProgressUseCase: FetchExerciseProgressUseCaseProtocol
    ) {
        self.exercise = exercise
        self.fetchProgressUseCase = fetchProgressUseCase
    }

    func loadProgress() {
        loadTask?.cancel()

        loadTask = Task { await loadProgress() }
    }

    func loadProgress() async {
        do {
            entries = try await fetchProgressUseCase.execute(
                for: exercise,
                period: selectedPeriod
            )
        } catch {
            self.error = error
        }
    }

    var hasData: Bool { !entries.isEmpty }

    var chartEntries: [(date: Date, value: Double)] {
        switch exercise.type {
        case .reps: entries.map { ($0.date, $0.maxWeight) }
        case .time: entries.map { ($0.date, $0.maxDuration) }
        }
    }

    var volumeEntries: [(date: Date, value: Double)] {
        entries.map { ($0.date, $0.totalVolume) }
    }

    var chartTitle: String {
        switch exercise.type {
        case .reps: AppLocalization.maxWeight
        case .time: AppLocalization.maxDuration
        }
    }

    func nullifyError() { error = nil }
}

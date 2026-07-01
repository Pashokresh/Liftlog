//
//  ExerciseProgressBarChartView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 07.05.26.
//

import Charts
import SwiftUI

struct ExerciseProgressBarChartView: View {
    typealias DataEntry = [(date: Date, value: Double)]

    let data: DataEntry
    let title: String
    let valueFormatter: (Double) -> String

    @State private var selectedEntry: (date: Date, value: Double)?
    @State private var visibleCount: Int = 0
    @State private var animationProgress: Double = 0

    init(
        data: DataEntry,
        title: String,
        valueFormatter: @escaping (Double) -> String
    ) {
        self.data = data
        self.title = title
        self.valueFormatter = valueFormatter
    }

    private var xDomain: ClosedRange<Date> {
        guard let first = data.map(\.date).min(), let last = data.map(\.date).max() else {
            return Date()...Date()
        }
        let padding = max(last.timeIntervalSince(first) * 0.08, 60 * 60 * 24 * 5)
        return Date(timeInterval: -padding, since: first)...Date(timeInterval: padding, since: last)
    }

    // MARK: Header

    @ViewBuilder var headerView: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(selectedEntry.map { "\(valueFormatter($0.value))" } ?? "")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.accent)
                Text(
                    selectedEntry.map {
                        $0.date.formatted(date: .abbreviated, time: .omitted)
                    } ?? ""
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .frame(height: 30)
            .opacity(selectedEntry != nil ? 1 : 0)
            .animation(.easeInOut(duration: 0.2), value: selectedEntry?.date)
        }
    }

    // MARK: - Chart

    @ViewBuilder var chartView: some View {
        Chart(Array(data.prefix(visibleCount)), id: \.date) { entry in
            BarMark(
                x: .value(AppLocalization.date, entry.date),
                y: .value(title, entry.value),
            )
            .foregroundStyle(
                selectedEntry?.date == entry.date
                    ? Color.accentColor
                    : Color.accentColor.opacity(0.5)
            )
            .cornerRadius(3)

            if let selected = selectedEntry, selected.date == entry.date {
                RuleMark(x: .value(AppLocalization.date, entry.date))
                    .foregroundStyle(Color.accentColor.opacity(0.3))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4]))
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated))
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisGridLine()
                AxisValueLabel {
                    if let doubleValue = value.as(Double.self) {
                        Text(valueFormatter(doubleValue))
                            .font(.caption)
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle()
                    .fill(.clear)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateSelectedEntry(
                                    at: value.location,
                                    proxy: proxy,
                                    geometry: geometry
                                )
                            }
                            .onEnded { _ in
                                withAnimation(.easeOut(duration: 0.3)) {
                                    selectedEntry = nil
                                }
                            }
                    )
            }
        }
        .chartXScale(domain: xDomain)
        .chartYScale(domain: 0...(data.map(\.value).max() ?? 1))
        .chartPlotStyle { plotArea in
            plotArea
                .padding(.top, 16)
                .padding(.bottom, 12)
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
        .frame(height: 200)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            chartView
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .onAppear {
            Task {
                for i in 1...max(data.count, 1) {
                    try? await Task.sleep(for: .milliseconds(80))
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        visibleCount = i
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func updateSelectedEntry(
        at location: CGPoint,
        proxy: ChartProxy,
        geometry: GeometryProxy
    ) {
        if let plotFrame = proxy.plotFrame {
            let xPosition = location.x - geometry[plotFrame].origin.x

            guard let date: Date = proxy.value(atX: xPosition) else { return }

            let closest = data.min {
                abs($0.date.timeIntervalSince(date))
                    < abs($1.date.timeIntervalSince(date))
            }

            withAnimation(.easeInOut(duration: 0.1)) {
                selectedEntry = closest
            }
        }
    }
}

#Preview {
    VStack {
        ExerciseProgressBarChartView(
            data: ExerciseProgressEntry.mocks.map {
                ($0.date, $0.totalVolume)
            },
            title: AppLocalization.totalVolume,
            valueFormatter: { $0.formattedVolume }
        )
        .padding()
        ExerciseProgressBarChartView(
            data: ExerciseProgressEntry.mocks.map {
                ($0.date, $0.maxWeight)
            },
            title: AppLocalization.maxWeight,
            valueFormatter: { $0.formattedWeight }
        )
        .padding()
    }
}

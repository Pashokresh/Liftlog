//
//  ExerciseProgressVolumeChartView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 07.05.26.
//

import Charts
import SwiftUI

struct ExerciseProgressVolumeChartView: View {
    typealias DataEntry = [(date: Date, value: Double)]

    let data: DataEntry

    @State private var selectedEntry: (date: Date, value: Double)?
    @State private var animationProgress: Double = 0

    init(data: DataEntry) {
        self.data = data
    }

    private var gradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: Color.accentColor.opacity(0.8), location: 0),
                .init(color: Color.accentColor.opacity(0.3), location: 0.5),
                .init(color: Color.accentColor.opacity(0.0), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: Header

    @ViewBuilder var headerView: some View {
        HStack {
            Text(AppLocalization.totalVolume)
                .font(.headline)
                .foregroundStyle(.primary)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(selectedEntry.map { "\($0.value.formattedVolume)" } ?? "")
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
        Chart(data, id: \.date) { entry in
            LineMark(
                x: .value(AppLocalization.date, entry.date),
                y: .value(AppLocalization.volume, entry.value)
            )
            .foregroundStyle(Color.accentColor)
            .lineStyle(StrokeStyle(lineWidth: 2))
            .interpolationMethod(.catmullRom)

            AreaMark(
                x: .value(AppLocalization.date, entry.date),
                y: .value(AppLocalization.volume, entry.value)
            )
            .foregroundStyle(gradient)
            .interpolationMethod(.catmullRom)

            if let selected = selectedEntry, selected.date == entry.date {
                PointMark(
                    x: .value(AppLocalization.date, entry.date),
                    y: .value(AppLocalization.volume, entry.value)
                )
                .foregroundStyle(Color.accentColor)
                .symbolSize(80)

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
                        Text(doubleValue.formattedVolume)
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
        .chartYScale(domain: .automatic(includesZero: false))
        .padding(.top, 8)
        .frame(height: 200)
        .chartAnimation(progress: animationProgress)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            headerView
            chartView
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animationProgress = 1.0
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

// MARK: - Chart Animation modifier

extension View {
    @ViewBuilder
    func chartAnimation(progress: Double) -> some View {
        if #available(iOS 26, *) {
            self.chartXVisibleDomain(length: progress)
        } else {
            self.mask(
                GeometryReader { geometry in
                    Rectangle()
                        .frame(width: geometry.size.width * progress)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            )
        }
    }
}

#Preview {
    ExerciseProgressVolumeChartView(
        data: ExerciseProgressEntry.mocks.map {
            ($0.date, $0.totalVolume)
        }
    )
    .padding()
}

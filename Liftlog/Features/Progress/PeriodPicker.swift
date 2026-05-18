//
//  PeriodPicker.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 06.05.26.
//

import SwiftUI

struct PeriodPicker: View {
    @State private var selectedPeriod: Period
    @Namespace private var animation
    private var onChange: (Period) -> Void

    init(selectedPeriod: Period, onChange: @escaping (Period) -> Void) {
        self.selectedPeriod = selectedPeriod
        self.onChange = onChange
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Period.allCases) { period in
                let isSelected = selectedPeriod == period
                ZStack {
                    if isSelected {
                        Capsule()
                            .fill(Color.accentColor)
                            .matchedGeometryEffect(id: "pill", in: animation)
                    }
                    Text(period.localizedName)
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .foregroundStyle(isSelected ? Color.white : Color.primary)
                }
                .fixedSize()
                .contentShape(Capsule())
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPeriod = period
                        onChange(period)
                    }
                }
            }
        }
        .padding(4)
        .background(.secondary.opacity(0.15), in: Capsule())
    }
}

#Preview {
    PeriodPicker(selectedPeriod: .sixMonths, onChange: { _ in })
}

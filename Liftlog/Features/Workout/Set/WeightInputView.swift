//
//  WeightInputView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import SwiftUI

struct WeightInputView: View {
    @Binding var reps: Int
    @Binding var weight: Double

    @State private var kilo: Int = 0
    @State private var grams: Int = 0

    var body: some View {
        HStack {
            HStack {
                Picker("", selection: $reps) {
                    ForEach(1...99, id: \.self) { Text("\($0)") }
                }
                .pickerStyle(.wheel)
                .frame(width: 70)
                .clipped()

                Text(AppLocalization.repsLowercase)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                Picker("", selection: $kilo) {
                    ForEach(0...300, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 70)
                .clipped()

                Text(AppLocalization.kilogram)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)

            HStack {
                Picker("", selection: $grams) {
                    ForEach(
                        Array(stride(from: 0, to: 1000, by: 50)),
                        id: \.self
                    ) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 70)
                .clipped()

                Text(AppLocalization.gram)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onChange(of: kilo) { updateBinding() }
        .onChange(of: grams) { updateBinding() }
        .onAppear { loadFromBinding() }
    }

    private func updateBinding() {
        weight = Double(kilo) + Double(grams) / 1000.0
    }

    private func loadFromBinding() {
        kilo = Int(weight)
        grams = Int(weight.truncatingRemainder(dividingBy: 1) * 1000)
    }
}

#Preview {
    WeightInputView(reps: Binding.constant(10), weight: Binding.constant(57))
}

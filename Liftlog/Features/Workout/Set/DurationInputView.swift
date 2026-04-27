//
//  DurationInputView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 05.03.26.
//

import SwiftUI

struct DurationInputView: View {

    @Binding var duration: Double

    @State var minutes: Int = 0
    @State var seconds: Int = 0

    var body: some View {
        HStack {

            HStack(spacing: 8) {
                Picker("", selection: $minutes) {
                    ForEach(0...300, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
                .clipped()

                Text(AppLocalization.min)
            }
            .frame(maxWidth: .infinity, alignment: .center)


            HStack(spacing: 8) {
                Picker("", selection: $seconds) {
                    ForEach(0...59, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
                .clipped()

                Text(AppLocalization.sec)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .onChange(of: minutes) { updateBinding() }
        .onChange(of: seconds) { updateBinding() }
        .onAppear { loadFromBinding() }
    }

    private func updateBinding() {
        duration = Double(minutes * 60 + seconds)
    }

    private func loadFromBinding() {
        minutes = Int(duration) / 60
        seconds = Int(duration) % 60
    }
}

#Preview {
    DurationInputView(duration: Binding.constant(543))
}

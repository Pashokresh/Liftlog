//
//  WeightInputView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import SwiftUI

struct WeightInputView: View {
    
    @Binding var weight: Double
    
    @State private var kg: Int = 0
    @State private var grams: Int = 0
    
    var body: some View {
        HStack {
            Spacer()
            
            HStack(spacing: 8) {
                Picker("", selection: $kg) {
                    ForEach(0...300, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
                .clipped()
                
                Text(String(localized: "kg"))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            
            HStack(spacing: 8) {
                Picker("", selection: $grams) {
                    ForEach(
                        Array(stride(from: 0, to: 1000, by: 50)),
                        id: \.self
                    ) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 80)
                .clipped()
                
                Text(String(localized: "grams"))
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .onChange(of: kg) { updateBinding() }
        .onChange(of: grams) { updateBinding() }
        .onAppear { loadFromBinding() }
    }
    
    private func updateBinding() {
        weight = Double(kg) + Double(grams) / 1000.0
    }
    
    private func loadFromBinding() {
        kg = Int(weight)
        grams = Int(weight.truncatingRemainder(dividingBy: 1) * 1000)
    }
}

#Preview {
    WeightInputView(weight: Binding.constant(57))
}

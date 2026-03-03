//
//  RepsInputView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import SwiftUI

struct RepsInputView: View {
    
    @Binding var reps: Int
    
    var body: some View {
        HStack {
            Spacer()
            
            Picker("", selection: $reps) {
                ForEach(1...99, id: \.self) { Text("\($0)") }
            }
            .pickerStyle(.wheel)
            .frame(width: 80, height: 120)
            
            Spacer()
        }
    }
}

#Preview {
    RepsInputView(reps: Binding.constant(10))
}

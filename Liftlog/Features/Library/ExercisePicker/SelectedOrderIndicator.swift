//
//  SelectedOrderIndicator.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 27.04.26.
//

import SwiftUI

struct SelectedOrderIndicator: View {

    var order: Int?

    var body: some View {
        ZStack {
            Text(order?.description ?? "")
                .font(.system(size: 100))
                .foregroundStyle(.background)
                .minimumScaleFactor(0.1)
                .lineLimit(1)
                .padding(4)
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(order == nil ? .clear : .accent)
                        .stroke(order == nil ? Color.secondary : Color.accent, lineWidth: 2)
                )
        }
    }
}

#Preview {
    SelectedOrderIndicator(order: 100)
}

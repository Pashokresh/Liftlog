//
//  AdaptiveCancelButton.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 05.03.26.
//

import SwiftUI

struct AdaptiveCancelButton: View {

    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .cancel) {
                action()
            }
            .adaptiveCancelStyle()
        } else {
            Button {
                action()
            } label: {
                Image(systemName: Images.xmark)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(.accent, in: Circle())
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    AdaptiveCancelButton {}
}

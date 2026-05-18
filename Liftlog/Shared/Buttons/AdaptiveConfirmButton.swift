//
//  AdaptiveConfirmButton.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 05.03.26.
//

import SwiftUI

struct AdaptiveConfirmButton: View {
    let action: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            Button(role: .confirm) {
                action()
            }
        } else {
            Button(AppLocalization.save) {
                action()
            }
        }
    }
}

#Preview {
    AdaptiveConfirmButton {}
}

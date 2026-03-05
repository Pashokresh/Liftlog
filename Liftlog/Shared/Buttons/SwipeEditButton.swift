//
//  SwipeEditButton.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import SwiftUI

struct SwipeEditButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Label(
                String(localized: "Edit"),
                systemImage: Images.pencil
            )
        }
        .tint(.blue)
    }
}

#Preview {
    SwipeEditButton {}
}

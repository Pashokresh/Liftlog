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
        Button(
            String(localized: "Edit"),
            systemImage: Images.pencil,
            action: {
                action()
            }
        )
        .tint(.blue)
    }
}

#Preview {
    SwipeEditButton {}
}

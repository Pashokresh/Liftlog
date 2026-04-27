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
            AppLocalization.edit,
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

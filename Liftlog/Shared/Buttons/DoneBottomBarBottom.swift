//
//  DoneBottomBarBottom.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 04.05.26.
//

import SwiftUI

struct DoneBottomBarBottom: View {
    let title: String
    let action: () -> Void

    init(with title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Image(systemName: Images.checkmarkCircle)
                Text(title)
            }
        }
        .adaptiveGlassProminentButton()
        .foregroundStyle(.ultraThickMaterial)
    }
}

#Preview {
    DoneBottomBarBottom(with: "Add Set") { }
}

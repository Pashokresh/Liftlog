//
//  AddBottomBarButton.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import SwiftUI

struct AddBottomBarButton: View {
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
                    Image(systemName: Images.plusCircle)
                    Text(title)
                }
            }
            .adaptiveGlassProminentButton()
            .foregroundStyle(.ultraThickMaterial)
    }
}

#Preview {
    AddBottomBarButton(with: "Add Set") { }
}

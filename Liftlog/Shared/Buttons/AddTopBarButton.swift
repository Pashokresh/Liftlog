//
//  AddTopBarButton.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import SwiftUI

struct AddTopBarButton: View {
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: Images.plus)
                .font(.headline)
                .foregroundStyle(.ultraThickMaterial)
        }
        .adaptiveGlassProminentButton()
    }
}

#Preview {
    AddTopBarButton {}
}

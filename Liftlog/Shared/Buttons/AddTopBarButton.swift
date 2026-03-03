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
            Image(systemName: "plus")
                .font(.headline)
                .foregroundStyle(.white)
        }
        .buttonStyle(.glassProminent)
    }
}

#Preview {
    AddTopBarButton() {}
}

//
//  SwipeDeleteButton.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import SwiftUI

struct SwipeDeleteButton: View {
    
    let action: () -> Void
    
    init(_ action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(role: .destructive) {
            action()
        } label: {
            Label(String(localized: "Delete"), systemImage: "trash")
        }
    }
}

#Preview {
    SwipeDeleteButton { }
}

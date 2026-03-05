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
        } else {
            Button {
                action()
            } label: {
                Image(systemName: Images.xmark)
            }
        }
    }
}

#Preview {
    AdaptiveCancelButton { }
}

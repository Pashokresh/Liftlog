//
//  View+Extensions.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 05.03.26.
//

import SwiftUI

extension View {
    
    func adjustableNavigationSubtitle(_ subtitle: String) -> some View {
        modifier(AdjustableNavigationSubtitle(subtitle: subtitle))
    }
    
    @ViewBuilder
    func adaptiveGlassProminentButton() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
}

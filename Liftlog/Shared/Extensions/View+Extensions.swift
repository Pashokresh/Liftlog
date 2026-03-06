//
//  View+Extensions.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 05.03.26.
//

import SwiftUI

extension View {
    
    func adaptiveNavigationSubtitle(_ subtitle: String) -> some View {
        modifier(AdaptiveNavigationSubtitle(subtitle: subtitle))
    }
    
    @ViewBuilder
    func adaptiveGlassProminentButton() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }
    
    func onRowTap(_ action: @escaping () -> Void) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                action()
            }
    }
}

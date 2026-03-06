//
//  AdaptiveNavigationSubtitle.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 05.03.26.
//

import SwiftUI

struct AdaptiveNavigationSubtitle: ViewModifier {

    var subtitle: String

    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .navigationSubtitle(subtitle)
        } else {
            content
        }
    }
}

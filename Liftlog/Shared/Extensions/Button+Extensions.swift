//
//  Button+Extensions.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 15.04.26.
//

import SwiftUI

extension Button {
    @available(iOS 26.0, *)
    @ViewBuilder
    func adaptiveGlassStyle(_ isProminent: Bool) -> some View {
        if isProminent {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.glass)
        }
    }

    @ViewBuilder
    func tagChipStyle(isSelected: Bool) -> some View {
        if #available(iOS 26.0, *) {
            self.adaptiveGlassStyle(isSelected)
        } else {
            self
                .buttonStyle(.plain)
                .background(
                    isSelected
                        ? Color.accentColor : Color.secondary.opacity(0.2)
                )
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(.capsule)
                .overlay {
                    Capsule()
                        .strokeBorder(
                            isSelected
                                ? Color.clear : Color.secondary.opacity(0.3),
                            lineWidth: 1
                        )
                }
        }
    }

    @ViewBuilder
        func adaptiveGlassProminentButton() -> some View {
            if #available(iOS 26.0, *) {
                self
                    .buttonStyle(.glassProminent)
            } else {
                self
                    .buttonStyle(.borderedProminent)
                    .clipShape(.capsule)
            }
        }

    @ViewBuilder
    func adaptiveGlassProminentIconButton() -> some View {
        if #available(iOS 26.0, *) {
            self
                .buttonStyle(.glassProminent)
        } else {
            self
                .buttonStyle(.plain)
                .labelStyle(.iconOnly)
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(.accent, in: Circle())
        }
    }
}

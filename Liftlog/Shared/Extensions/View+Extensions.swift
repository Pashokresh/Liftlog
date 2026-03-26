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


    func deleteConfirmation<T: Identifiable>(
        item: Binding<T?>,
        title: String = String(localized: "Delete?"),
        message: String = String(localized: "This action cannot be undone."),
        action: @escaping (T) -> Void
    ) -> some View {
        self.alert(
            title,
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: { if !$0 { item.wrappedValue = nil } }
            ),
            presenting: item.wrappedValue
        ) { itemToDelete in
            Button(String(localized: "Delete"), role: .destructive) {
                action(itemToDelete)
                item.wrappedValue = nil
            }
            Button(String(localized: "Cancel"), role: .cancel) {
                item.wrappedValue = nil
            }
        } message: { _ in
            Text(message)
        }
    }
}

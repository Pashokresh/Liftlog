//
//  View+Extensions.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 05.03.26.
//

import SwiftUI
import Charts

extension View {
    func adaptiveNavigationSubtitle(_ subtitle: String) -> some View {
        modifier(AdaptiveNavigationSubtitle(subtitle: subtitle))
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
        title: String = AppLocalization.deleteConfirmationTitle,
        message: String = AppLocalization.deleteConfirmationMessage,
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
            Button(AppLocalization.delete, role: .destructive) {
                action(itemToDelete)
                item.wrappedValue = nil
            }
            Button(AppLocalization.cancel, role: .cancel) {
                item.wrappedValue = nil
            }
        } message: { _ in
            Text(message)
        }
    }

    // MARK: - Chart Interactive modifier

    @ViewBuilder var chartInteractive: some View {
        if #available(iOS 26, *) {
            self.chartScrollableAxes(.horizontal)
        } else {
            self
        }
    }
}

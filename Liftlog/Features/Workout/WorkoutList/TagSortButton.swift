//
//  TagSortButton.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 09.03.26.
//

import SwiftUI

struct TagSortButton: View {

    var isSelected: Bool
    var tag: TagModel
    var action: () -> Void

    init(isSelected: Bool, tag: TagModel, action: @escaping () -> Void) {
        self.isSelected = isSelected
        self.tag = tag
        self.action = action
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(tag.name)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        }
        .tagChipStyle(isSelected: isSelected)
        .buttonBorderShape(.capsule)
        .animation(
            .spring(response: 0.35, dampingFraction: 0.7),
            value: isSelected
        )
    }
}

#Preview {
    TagSortButton(isSelected: true, tag: TagModel.mock) {}
    TagSortButton(isSelected: false, tag: TagModel.mock) {}
}

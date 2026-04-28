//
//  TagChipView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 09.03.26.
//

import SwiftUI

struct TagChipView: View {
    let tag: TagModel
    var isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 4) {
                Text(tag.name)
                    .font(.caption)
                Image(systemName: isSelected ? Images.xmark : Images.plus)
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.8) : Color.secondary.opacity(0.3))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TagChipView(
        tag: TagModel.mock,
        isSelected: true) { }

    TagChipView(
        tag: TagModel.mock,
        isSelected: false) { }
}

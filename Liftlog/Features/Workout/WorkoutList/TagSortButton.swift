//
//  TagSortButton.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 09.03.26.
//

import SwiftUI

struct TagSortButton: View {
    
    var isSelected: Bool
    var action: () -> Void
    var tag: TagModel
    
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
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor.opacity(0.8) : Color.secondary.opacity(0.3))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(.capsule)
        }
        .buttonStyle(.plain)
        .animation(.easeIn, value: isSelected) 
    }
}

#Preview {
    TagSortButton(isSelected: true, tag: TagModel.mock) { }
    TagSortButton(isSelected: false, tag: TagModel.mock) { }
}

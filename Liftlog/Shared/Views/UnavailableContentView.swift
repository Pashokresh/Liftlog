//
//  UnavailableContentView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 03.03.26.
//

import SwiftUI

struct UnavailableContentView: View {
    
    let title: String
    let message: String
    
    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: Images.dumbbell,
            description: Text(message)
        )
    }
}

#Preview {
    UnavailableContentView(
        title: "No sets",
        message: "Start adding sets here"
    )
}

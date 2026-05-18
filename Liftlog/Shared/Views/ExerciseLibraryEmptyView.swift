//
//  ExerciseLibraryEmptyView.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 26.04.26.
//

import SwiftUI

struct ExerciseLibraryEmptyView: View {
    var body: some View {
        UnavailableContentView(
            title: String(
                localized: "No exercises in the library yet."
            ),
            message: String(
                localized: "Tap \"+\" to add a new one."
            )
        )
    }
}

#Preview {
    ExerciseLibraryEmptyView()
}

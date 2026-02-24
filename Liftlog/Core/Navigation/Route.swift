//
//  Route.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 24.02.26.
//

import Foundation
import SwiftUI

enum Route: Hashable, Codable, Equatable {
    case workoutDetailView(workoutId: UUID)
    case exerciseLibrary
}



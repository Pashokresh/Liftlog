//
//  LiftlogApp.swift
//  Liftlog
//
//  Created by Pavel Martynenkov on 19.02.26.
//

import SwiftUI
import CoreData

@main
struct LiftlogApp: App {
    @State private var dependencies = AppDependencies()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dependencies)
        }
    }
}

//
//  SwiftUICoreDataSpendingTrackerApp.swift
//  SwiftUICoreDataSpendingTracker
//
//  Created by Michael Doroff on 10/8/22.
//

import SwiftUI

@main
struct SwiftUICoreDataSpendingTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

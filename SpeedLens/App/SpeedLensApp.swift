//
//  SpeedLensApp.swift
//  SpeedLens
//
//  Created by George on 30/04/25.
//

import SwiftUI
import SwiftData

@main
struct SpeedLensApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
			CameraView()
        }
        .modelContainer(sharedModelContainer)
    }
}

//
//  SpeedLensApp.swift
//  SpeedLens
//
//  Created by George on 30/04/25.
//

import SwiftUI
import SwiftData
import CubeLoaderKit
import NavigationTransitions
import ADManagerKit

// MARK: - SpeedLensApp
/// App entry point for SpeedLens, configuring persistence and navigation
@main
struct SpeedLensApp: App {
	// MARK: - Properties
	/// Router managing navigation stack path
	@StateObject private var router = NavigationRouter()

	/// Shared ModelContainer for SwiftData persistence
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

	init() {
		let loader = CubeLoader.shared
		loader.loadLUTsFromBundle()

		ADManagerKit()
				.start(completionHandler: nil)
	}

	// MARK: - Scenes
	/// Main application scene containing the camera view and navigation
	var body: some Scene {
		WindowGroup {
			NavigationStack(path: $router.path) {
				CameraView()
					.navigationDestination(for: AppRoute.self) { route in
						switch route {
						case .detail(let image):
							DetailImageViewFactory.make(with: image)
						default:
							EmptyView()
						}
					}
			}
			.navigationTransition(
				.fade(.in).animation(.easeIn(duration: 0.5))
			)
			.environmentObject(router)
		}
	}
}

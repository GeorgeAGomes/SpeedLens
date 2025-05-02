//
//  AppRouter.swift
//  SpeedLens
//
//  Created by George on 01/05/25.
//

import SwiftUI

// MARK: - AppRoute
/// Defines the possible navigation destinations in the app
enum AppRoute: Hashable {
    /// Main camera view
    case camera
    /// Detail view for a captured image
    case detail(image: UIImage)
    /// Sharing flow
    case share
    /// Subscription flow
    case subscribe
    /// Advertisement flow
    case ad
}

// MARK: - NavigationRouter
/// Observable router managing a stack of AppRoute for SwiftUI NavigationStack
final class NavigationRouter: ObservableObject {
    // MARK: - Properties
    /// Stack of active navigation routes
    @Published var path: [AppRoute] = []

    // MARK: - Navigation Actions
    /// Pushes a new route onto the navigation stack
    /// - Parameter route: The destination route to navigate to
    func go(to route: AppRoute) {
        withAnimation(.easeInOut) {
            path.append(route)
        }
    }

    /// Pops the top route off the navigation stack
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pops all routes, returning to the root view
    func popToRoot() {
        path.removeAll()
    }
}

//
//  AppRouter.swift
//  SpeedLens
//
//  Created by George on 01/05/25.
//

import SwiftUI

final class NavigationRouter: ObservableObject {

	enum AppRoute: Hashable {
		case camera
		case detail(image: UIImage)
		case share
		case subscribe
		case ad
	}

	@Published var path: [AppRoute] = []

	func go(to route: AppRoute) {
		print("🚀 roteando para \(route)")
		path.append(route)
	}

	func pop() {
		path.removeLast()
	}

	func popToRoot() {
		path.removeLast(path.count)
	}
}

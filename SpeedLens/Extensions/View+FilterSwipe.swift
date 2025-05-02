//
//  Swipe.swift
//  SpeedLens
//
//  Created by George on 01/05/25.
//

import SwiftUI

extension View {
	func filterSwipe(
		currentIndex: Binding<Int>,
		maxIndex: Int,
		onUpdate: @escaping () -> Void
	) -> some View {
		self.modifier(
			SwipeFilterGesture(
				currentIndex: currentIndex,
				maxIndex: maxIndex,
				onUpdate: onUpdate
			)
		)
	}
}

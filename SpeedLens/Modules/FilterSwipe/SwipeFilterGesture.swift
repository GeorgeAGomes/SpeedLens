//
//  SwipeFilterGesture.swift
//  SpeedLens
//
//  Created by George on 01/05/25.
//



import SwiftUI

struct SwipeFilterGesture: ViewModifier {
	@Binding var currentIndex: Int
	let maxIndex: Int
	let onUpdate: () -> Void

	func body(content: Content) -> some View {
		content
			.gesture(
				DragGesture()
					.onEnded { value in
						if value.translation.width < -50 {
							if currentIndex < maxIndex {
								currentIndex += 1
							}
						} else if value.translation.width > 50 {
							if currentIndex > 0 {
								currentIndex -= 1
							}
						}
						onUpdate()
					}
			)
	}
}

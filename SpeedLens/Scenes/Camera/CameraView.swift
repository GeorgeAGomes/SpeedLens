//
//  ContentView.swift
//  SpeedLens
//
//  Created by George on 30/04/25.
//

import SwiftUI
import UIKit

// MARK: - CameraView
/// SwiftUI view displaying camera preview and capture button

struct CameraView: View {
	// MARK: - Properties
	/// Holds the latest captured image from the camera
	@State private var capturedImage: UIImage?
	/// Router for navigation between routes
	@EnvironmentObject private var router: NavigationRouter

	// MARK: - Body
	/// The main view body displaying preview and capture control
	var body: some View {
		ZStack {
			// Centered camera preview with aspect ratio 3:4
			CameraPreview(capturedImage: $capturedImage)
				.aspectRatio(3/4, contentMode: .fit)
				.padding(.horizontal)

			// Capture button anchored to the bottom
			VStack {
				Spacer()
				Button(action: {
					NotificationCenter.default.post(name: .capturePhoto, object: nil)
				}) {
					Text("Capture")
						.foregroundColor(.white)
						.padding()
						.background(Color.blue)
						.cornerRadius(10)
				}
				.padding(.bottom, 50)
			}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.ignoresSafeArea(edges: .top)

		// MARK: - Actions
		/// Trigger navigation when a new image is captured
		.onChange(of: capturedImage) { _, image in
			if let image = image {
				router.go(to: .detail(image: image))
			}
		}
	}
}

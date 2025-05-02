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
		VStack {
			CameraPreview(
				capturedImage: $capturedImage
			)
			.aspectRatio(3/4, contentMode: .fit)
			.padding(.horizontal)

			Button(action: {
				NotificationCenter.default.post(name: .capturePhoto, object: nil)
			}) {
				Text("Capture")
					.foregroundColor(.white)
					.padding()
					.background(Color.blue)
					.cornerRadius(10)
			}
        }
        // MARK: - Actions
        .onChange(of: capturedImage) {
            // Navigate to detail view when an image is captured
            if let image = capturedImage {
                router.go(to: .detail(image: image))
            }
        }
	}
}

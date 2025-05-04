//
//  ContentView.swift
//  SpeedLens
//
//  Created by George on 30/04/25.
//

import SwiftUI
import UIKit
import ADManagerKit

// MARK: - CameraView
/// SwiftUI view displaying camera preview and capture button

struct CameraView: View {
	// MARK: - Properties
	/// Holds the latest captured image from the camera
	@State private var capturedImage: UIImage?
	/// Router for navigation between routes
	@EnvironmentObject private var router: NavigationRouter
	@StateObject private var adState = BannerAdState()
	
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
				if adState.error == nil {
					BannerAdView(
						state: adState,
						retryLimit: 3,
						didLoad: {
							// Call Analytics: banner successfully loaded
							// Analytics.logEvent("banner_loaded", parameters: nil)
						},
						didClick: {
							// Call Analytics: banner clicked by user
							// Analytics.logEvent("banner_click", parameters: nil)
							// Optionally handle navigation or present a modal
						},
						didRecordImpression: {
							// Call Analytics: banner impression recorded
							// Analytics.logEvent("banner_impression", parameters: nil)
						},
						willPresentScreen: {
							// Call Analytics: banner is about to present full‐screen content
							// Analytics.logEvent("banner_will_present", parameters: nil)
						},
						willDismissScreen: {
							// Call Analytics: banner is about to dismiss full‐screen content
							// Analytics.logEvent("banner_will_dismiss", parameters: nil)
						},
						didDismissScreen: {
							// Call Analytics: full‐screen content has been dismissed
							// Analytics.logEvent("banner_did_dismiss", parameters: nil)
						}
					)
					.sized(.medium)

				} else {
					// Call Analytics: error loading banner
					// Analytics.logEvent("banner_error", parameters: ["error": error.localizedDescription])
					// Optionally show a fallback view or initiate retry logic

				}

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

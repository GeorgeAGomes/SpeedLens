//
//  ContentView.swift
//  SpeedLens
//
//  Created by George on 30/04/25.
//

import SwiftUI
import UIKit

struct CameraView: View {
	@State private var capturedImage: UIImage?
	@EnvironmentObject private var router: NavigationRouter

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
		.onChange(of: capturedImage) {
			if let image = capturedImage {
				router.go(to: .detail(image: image))
			}
		}
	}
}

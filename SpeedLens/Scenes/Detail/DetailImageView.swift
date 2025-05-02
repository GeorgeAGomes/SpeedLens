//
//  DetailImageView.swift
//  SpeedLens
//
//  Created by George on 01/05/25.
//

import SwiftUI

// MARK: - DetailImageView
/// SwiftUI view displaying a captured image and allowing filter selection via swipe gestures
struct DetailImageView: View {
	// MARK: - Properties
	/// View model providing image data and filter logic
	@ObservedObject var viewModel: DetailImageViewModel
	/// Controls visibility of the filter name overlay
	@State private var showFilterName = false
	/// Dispatch work item used to cancel previous hide timers
	@State private var hideWorkItem: DispatchWorkItem?
	/// Controls whether the share sheet is shown
	@State private var isSharing = false
	/// Indicates whether the share was completed successfully
	@State private var shareCompleted: Bool? = nil

	// MARK: - Body
	/// The view body rendering the image and handling user interactions
	var body: some View {
		let filterName = viewModel.filters.indices.contains(viewModel.currentFilterIndex)
			? viewModel.filters[viewModel.currentFilterIndex].name
			: "Original"

		ZStack(alignment: .top) {
			// Main image display with swipe gesture for filters
			Image(uiImage: viewModel.imageToShow)
				.resizable()
				.aspectRatio(3/4, contentMode: .fit)
				.padding(.horizontal)
				.filterSwipe(
					currentIndex: $viewModel.currentFilterIndex,
					maxIndex: viewModel.filters.count - 1
				) {
					viewModel.updateFilter()
				}
				.onAppear { viewModel.didLoad() }

			// Filter name overlay with animation
			Text(filterName)
				.padding(.vertical, 6)
				.padding(.horizontal, 12)
				.foregroundColor(.white)
				.background(Color.black.opacity(0.6))
				.cornerRadius(8)
				.padding(.top, 16)
				.opacity(showFilterName ? 1 : 0)
				.animation(.easeInOut(duration: 0.5), value: showFilterName)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
		.ignoresSafeArea(edges: .top)

		// Share button in top-right overlay
		.overlay(alignment: .topTrailing) {
			Button(action: {
				isSharing = true
			}) {
				Image(systemName: "square.and.arrow.up")
					.font(.title3)
					.imageScale(.medium)
					.padding(.vertical, 6)
					.padding(.horizontal, 8)
					.offset(y: -1)
			}
			.background(Color.white.opacity(0.8))
			.foregroundColor(.black)
			.cornerRadius(10)
			.padding(.top, 20)
			.padding(.trailing, 20)
		}

		// Share sheet presentation and dismissal
		.sheet(isPresented: $isSharing, onDismiss: {
			if let completed = shareCompleted {
				print(completed
					? "User completed sharing ✅"
					: "User canceled sharing ❌")
			}
		}) {
			ShareSheet(
				activityItems: [viewModel.imageToShow],
				onComplete: { completed in
					shareCompleted = completed
					isSharing = false
				}
			)
		}

		// Schedule hide on appear and on filter change
		.onAppear {
			scheduleHide()
		}
		.onChange(of: viewModel.currentFilterIndex) {
			scheduleHide()
		}
	}

	// MARK: - Helpers
	/// Schedules hiding the filter name label after a delay, canceling any previous task
	private func scheduleHide() {
		// Show immediately with animation
		withAnimation { showFilterName = true }

		// Cancel any previously scheduled hide
		hideWorkItem?.cancel()

		// Create and store new work item to hide after delay
		let item = DispatchWorkItem {
			withAnimation { showFilterName = false }
		}
		hideWorkItem = item

		// Execute the work item after 3 seconds
		DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: item)
	}
}

// MARK: - ShareSheet
/// UIKit wrapper for UIActivityViewController to present a share sheet from SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
	let activityItems: [Any]
	let onComplete: (Bool) -> Void

	func makeCoordinator() -> Coordinator {
		Coordinator(onComplete: onComplete)
	}

	func makeUIViewController(context: Context) -> UIActivityViewController {
		let controller = UIActivityViewController(
			activityItems: activityItems,
			applicationActivities: nil
		)
		controller.completionWithItemsHandler = context.coordinator.handler
		return controller
	}

	func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}

	// MARK: - Coordinator
	class Coordinator {
		let onComplete: (Bool) -> Void

		init(onComplete: @escaping (Bool) -> Void) {
			self.onComplete = onComplete
		}

		/// Completion handler for activity controller
		lazy var handler: UIActivityViewController.CompletionWithItemsHandler = { _, completed, _, _ in
			self.onComplete(completed)
		}
	}
}

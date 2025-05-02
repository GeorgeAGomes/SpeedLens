//
//  DetailImageViewModel.swift
//  SpeedLens
//
//  Created by George on 01/05/25.
//

import SwiftUI
import CubeLoaderKit

// MARK: - DetailImageViewModel
/// ViewModel managing the display and filtering of a captured image
final class DetailImageViewModel: ObservableObject {
	// MARK: - Properties
	/// Original captured image
	@Published var image: UIImage
	/// Image updated with the current LUT filter applied
	@Published var imageToShow: UIImage
	/// Controls display of photo picker (currently unused)
	@Published var showPhotoPicker = false
	/// Index of the currently selected filter
	@Published var currentFilterIndex = 0

	/// Array of available CIFilter LUT filters, with "Original" first
	var filters: [CIFilter] = []

	// MARK: - Initialization
	/// Initializes the view model with the given image
	/// - Parameter image: The captured UIImage to display and filter
	init(image: UIImage) {
		self.image = image
		self.imageToShow = image
		print("init Detail viewModel")
	}

	// MARK: - Public Methods
	/// Applies the currently selected filter to `image` and updates `imageToShow`
	func updateFilter() {
		applyLUT(to: image)
	}

	/// Loads LUT filters from bundle, ordering "Original" first
	@MainActor
	func didLoad() {
		let loader = CubeLoader.shared

		let reordered = loader.LUTs.toFilter().sorted { lhs, rhs in
			lhs.name == "Original" ? true : rhs.name == "Original" ? false : true
		}

		self.filters = reordered
	}

	// MARK: - Private Methods
	/// Internal helper to apply a LUT filter to the given image
	/// - Parameter image: The base UIImage to process
	private func applyLUT(to image: UIImage) {
		let filter = filters[currentFilterIndex]
		if let result = ImageLUTApplier.apply(to: image, using: filter) {
			DispatchQueue.main.async {
				self.imageToShow = result
			}
		}
	}
}


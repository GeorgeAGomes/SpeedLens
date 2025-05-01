//
//  DetailImageViewModel.swift
//  SpeedLens
//
//  Created by George on 01/05/25.
//

import SwiftUI
import CubeLoaderKit

final class DetailImageViewModel: ObservableObject {
	@Published var image: UIImage
	@Published var imageToShow: UIImage
	@Published var showPhotoPicker = false
	@Published var currentFilterIndex = 0

	var filters: [CIFilter] = []

	init(image: UIImage) {
		self.image = image
		self.imageToShow = image
		print("init Detail viewModel")
	}

	func updateFilter() {
		applyLUT(to: image)
	}

	@MainActor
	func didLoad() {
		let loader = CubeLoader.shared

		let reordered = loader.LUTs.toFilter().sorted { lhs, rhs in
			lhs.name == "Original" ? true : rhs.name == "Original" ? false : true
		}

		self.filters = reordered
	}

	private func applyLUT(to image: UIImage) {
		let filter = filters[currentFilterIndex]
		if let result = ImageLUTApplier.apply(to: image, using: filter) {
			DispatchQueue.main.async {
				self.imageToShow = result
			}
		}
	}
}


//
//  DetailImageView.swift
//  SpeedLens
//
//  Created by George on 01/05/25.
//

import SwiftUI

struct DetailImageView: View {
	@ObservedObject var viewModel: DetailImageViewModel

	var body: some View {

		let filterName = viewModel.filters.count > 0 ? viewModel.filters[viewModel.currentFilterIndex].name : "Original"
		Text(filterName)

		Image(uiImage: viewModel.imageToShow)
			.resizable()
			.aspectRatio(3/4, contentMode: .fit)
			.padding(.horizontal)
			.gesture(
				DragGesture()
					.onEnded { value in
						if value.translation.width < -50 {
							if viewModel.currentFilterIndex < viewModel.filters.count - 1 {
								viewModel.currentFilterIndex += 1
							}
						} else if value.translation.width > 50 {
							if viewModel.currentFilterIndex > 0 {
								viewModel.currentFilterIndex -= 1
							}
						}
						viewModel.updateFilter()
					}
			)
			.onAppear {
				viewModel.didLoad()
			}
	}
}

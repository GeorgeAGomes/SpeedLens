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

    // MARK: - Body
    /// The view body rendering the image and handling user interactions
    var body: some View {
        // Current filter name or "Original" if no filters loaded
        let filterName = viewModel.filters.isEmpty
            ? "Original"
            : viewModel.filters[viewModel.currentFilterIndex].name
        Text(filterName)

        Image(uiImage: viewModel.imageToShow)
            .resizable()
            .aspectRatio(3/4, contentMode: .fit)
            .padding(.horizontal)
            // MARK: - Gesture
            /// Swipe left/right to change filters
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 {
                            // Next filter
                            if viewModel.currentFilterIndex < viewModel.filters.count - 1 {
                                viewModel.currentFilterIndex += 1
                            }
                        } else if value.translation.width > 50 {
                            // Previous filter
                            if viewModel.currentFilterIndex > 0 {
                                viewModel.currentFilterIndex -= 1
                            }
                        }
                        viewModel.updateFilter()
                    }
            )
            // MARK: - Lifecycle
            .onAppear {
                // Load available filters when view appears
                viewModel.didLoad()
            }
    }
}

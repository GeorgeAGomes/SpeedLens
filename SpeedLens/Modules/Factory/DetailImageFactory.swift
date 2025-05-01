//
//  DetailImageViewFactory.swift
//  SpeedLens
//
//  Created by George on 01/05/25.
//

import Foundation
import SwiftUI

struct DetailImageViewFactory {
	private init() { }
	
	static func make(with image: UIImage) -> DetailImageView {
		let viewModel = DetailImageViewModel(image: image)
		return DetailImageView(viewModel: viewModel)
	}
}

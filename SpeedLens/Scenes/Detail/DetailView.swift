//
//  DetailView.swift
//  SpeedLens
//
//  Created by George on 01/05/25.
//

import SwiftUI

struct DetailView: View {
	private let image: UIImage

	init (image: UIImage) {
		self.image = image
	}

    var body: some View {
        Image(uiImage: image)
			.resizable()
			.aspectRatio(3/4, contentMode: .fit)
			.padding(.horizontal)
    }
}

//#Preview {
//	DetailView(image: UIIma)
//}

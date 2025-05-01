import SwiftUI
import UIKit

struct CameraPreview: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onCapture = { image in
            capturedImage = image
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // No update needed
    }
}
import SwiftUI
import UIKit

// MARK: - CameraPreview
/// SwiftUI wrapper for CameraViewController, providing live camera feed and capture callback

struct CameraPreview: UIViewControllerRepresentable {
    // MARK: - Properties
    /// Binding to receive the captured image from the camera controller
    @Binding var capturedImage: UIImage?

    // MARK: - UIViewControllerRepresentable
    /// Creates and configures the CameraViewController
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.onCapture = { image in
            capturedImage = image
        }
        return controller
    }

    /// No dynamic updates are required for the embedded view controller
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Intentionally left blank
    }
}
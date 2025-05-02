import UIKit
import AVFoundation
import CoreImage

// MARK: - Notification.Name Extension
extension Notification.Name {
    /// Notification to trigger photo capture
    static let capturePhoto = Notification.Name("capturePhoto")
}

// MARK: - CameraViewController
/// View controller responsible for displaying camera preview and capturing photos.
final class CameraViewController: UIViewController {
    // MARK: Properties
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let ciContext = CIContext()
    private var captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    /// Callback invoked when a photo is captured
    var onCapture: ((UIImage) -> Void)?

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreview()
        setupCamera()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCapture),
            name: .capturePhoto,
            object: nil
        )

        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }

    // MARK: - Setup Methods
    /// Configures the preview layer for live camera feed
    private func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }

    /// Configures the capture session inputs and outputs
    private func setupCamera() {
        captureSession.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
              ),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        captureSession.beginConfiguration()
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        captureSession.commitConfiguration()
    }

    // MARK: Actions
    /// Triggered by notification to capture a photo
    @objc private func handleCapture() {
        let settings = AVCapturePhotoSettings(
            format: [AVVideoCodecKey: AVVideoCodecType.jpeg]
        )
        if #available(iOS 16.0, *) {
            photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)
        } else {
            photoOutput.isHighResolutionCaptureEnabled = true
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(
        _ output: AVCaptureOutput,
        sampleBuffer: CMSampleBuffer,
        connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.right)
        let uiImage = convertCIImageToUIImage(ciImage)
        DispatchQueue.main.async {
            self.onCapture?(uiImage)
        }
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let imageData = photo.fileDataRepresentation(),
              var ciImage = CIImage(data: imageData) else {
            return
        }
        ciImage = ciImage.oriented(.right)
        let finalImage = convertCIImageToUIImage(ciImage)
        onCapture?(finalImage)
    }
}

// MARK: - Helpers
private extension CameraViewController {
    /// Converts a CIImage to UIImage
    func convertCIImageToUIImage(_ ciImage: CIImage) -> UIImage {
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return UIImage(systemName: "exclamationmark.triangle") ?? UIImage()
        }
        return UIImage(cgImage: cgImage)
    }
}

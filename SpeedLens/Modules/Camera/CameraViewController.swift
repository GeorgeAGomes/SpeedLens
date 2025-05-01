import UIKit
import AVFoundation
import CoreImage

extension Notification.Name {
    static let capturePhoto = Notification.Name("capturePhoto")
}

final class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCapturePhotoCaptureDelegate {
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let ciContext = CIContext()
    private var captureSession = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()

    var onCapture: ((UIImage) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupPreview()
        setupCamera()
        NotificationCenter.default.addObserver(self, selector: #selector(handleCapture), name: .capturePhoto, object: nil)

        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
    }

    private func setupPreview() {
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
    }

    private func setupCamera() {
        captureSession.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }

        captureSession.beginConfiguration()
        if captureSession.canAddInput(input) { captureSession.addInput(input) }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) { captureSession.addOutput(videoOutput) }
        if captureSession.canAddOutput(photoOutput) { captureSession.addOutput(photoOutput) }

        captureSession.commitConfiguration()
    }

    @objc private func handleCapture() {
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        if #available(iOS 16.0, *) {
            photoOutput.maxPhotoDimensions = CMVideoDimensions(width: 4032, height: 3024)
        } else {
            photoOutput.isHighResolutionCaptureEnabled = true
        }
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func captureOutput(_ output: AVCaptureOutput, sampleBuffer: CMSampleBuffer, connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.right)
        let uiImage = convertCIImageToUIImage(ciImage)
        DispatchQueue.main.async {
            self.onCapture?(uiImage)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              var ciImage = CIImage(data: imageData) else { return }

        ciImage = ciImage.oriented(.right)
        let finalImage = convertCIImageToUIImage(ciImage)
        onCapture?(finalImage)
    }

    private func convertCIImageToUIImage(_ ciImage: CIImage) -> UIImage {
        guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
            return UIImage(systemName: "exclamationmark.triangle") ?? UIImage()
        }
        return UIImage(cgImage: cgImage)
    }
}
//
//  ContentView.swift
//  SpeedLens
//
//  Created by George on 30/04/25.
//

import SwiftUI
import AVFoundation
import CoreImage
import CubeLoaderKit

struct CameraView: View {
	@State private var isLUTEnabled = false
	@State private var lutIntensity: Float = 1.0
	@State private var capturedImage: UIImage?
	@State private var currentFilterIndex = 0

	private let lutLoader = CubeLoader.shared
	private var filters: [CIFilter] = []

	init() {
		lutLoader.loadLUTsFromBundle()
		self.filters = lutLoader.LUTs.toFilter()
	}

	var body: some View {
		VStack {
			CameraPreview(
				capturedImage: $capturedImage
			)
			.aspectRatio(3/4, contentMode: .fit)
			.padding(.horizontal)

			Button(action: {
				NotificationCenter.default.post(name: .capturePhoto, object: nil)
			}) {
				Text("Capture")
					.foregroundColor(.white)
					.padding()
					.background(Color.blue)
					.cornerRadius(10)
			}
		}
	}
}

struct CameraPreview: UIViewControllerRepresentable {
	@Binding var capturedImage: UIImage?

	func makeUIViewController(context: Context) -> CameraViewController {
		let controller = CameraViewController()
		return controller
	}

	func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {

	}
}


class CameraViewController: UIViewController,
							AVCaptureVideoDataOutputSampleBufferDelegate,
							AVCapturePhotoCaptureDelegate {

	private var previewLayer: AVCaptureVideoPreviewLayer!

	private let ciContext = CIContext()
	private var captureSession = AVCaptureSession()
	private let photoOutput = AVCapturePhotoOutput()
	private let previewImageView = UIImageView()

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
			print("Capture session started") // DEBUG
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
			  let input = try? AVCaptureDeviceInput(device: device) else { return }

		captureSession.beginConfiguration()
		if captureSession.canAddInput(input) { captureSession.addInput(input) }

		let videoOutput = AVCaptureVideoDataOutput()
		videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
		if captureSession.canAddOutput(videoOutput) { captureSession.addOutput(videoOutput) }
		if captureSession.canAddOutput(photoOutput) { captureSession.addOutput(photoOutput) }

		captureSession.commitConfiguration()

		DispatchQueue.global(qos: .background).async {
			self.captureSession.startRunning()
		}
	}

	func captureOutput(_ output: AVCaptureOutput, sampleBuffer: CMSampleBuffer, connection: AVCaptureConnection) {
		guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
		let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.right)

		let uiImage = convertCIImageToUIImage(ciImage)
		DispatchQueue.main.async {
			self.previewImageView.image = uiImage
		}
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

	// Called by delegate
	func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		guard let imageData = photo.fileDataRepresentation(),
			  var ciImage = CIImage(data: imageData) else { return }

		ciImage = ciImage.oriented(.right)

		let finalImage = convertCIImageToUIImage(ciImage)
		// Save image on device
		UIImageWriteToSavedPhotosAlbum(finalImage, nil, nil, nil)
	}

	private func convertCIImageToUIImage(_ ciImage: CIImage) -> UIImage {
		guard let cgImage = ciContext.createCGImage(ciImage, from: ciImage.extent) else {
			return UIImage(systemName: "exclamationmark.triangle") ?? UIImage()
		}
		return UIImage(cgImage: cgImage)
	}
}

extension Notification.Name {
	static let capturePhoto = Notification.Name("capturePhoto")
}

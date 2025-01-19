//
//  iOSLiveCamera.swift
//  frontend
//
//  Created by Vincent Liu on 2025-01-19.
//

import SwiftUI
import AVFoundation

struct LiveCameraScreen: View {
    @State private var capture: UIImage? // Use UIImage for iOS
    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        VStack {
            HStack {
                Text("Live Camera Screen")
                    .navigationTitle("Live Camera View")
                CamView(cameraManager: cameraManager)
                    .frame(width: 640, height: 480)
                    .background(Color.white)
                if let image = capture {
                    Image(uiImage: image) // Use uiImage for UIImage
                        .resizable()
                        .scaledToFit()
                        .frame(width: 640, height: 480)
                } else {
                    Color.clear
                        .frame(width: 640, height: 480) // Placeholder
                }
            }
            .padding()
        }
        .onAppear {
            cameraManager.startCapture()
        }
        .onDisappear {
            cameraManager.stopCapture()
        }
        .onReceive(cameraManager.$capturedImage) { image in
            self.capture = image
            if let image = image {
                cameraManager.sendImageToServer(image: image)
            }
        }
    }
}

class CameraManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession? // Changed from private to internal
    private var videoOutput: AVCaptureVideoDataOutput?
    private var timer: Timer?
    private var lastUploadTime: Date?

    @Published var capturedImage: UIImage?

    func startCapture() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No camera available")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            videoOutput = AVCaptureVideoDataOutput()
            if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            }

            captureSession.startRunning()
            startTimer()

        } catch {
            print("Error setting up camera: \(error)")
        }
    }

    func stopCapture() {
        captureSession?.stopRunning()
        stopTimer()
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.captureFrame()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func captureFrame() {
        guard let videoOutput = videoOutput else { return }
        let connection = videoOutput.connection(with: .video)
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            let uiImage = UIImage(cgImage: cgImage)
            DispatchQueue.main.async {
                self.capturedImage = uiImage
            }
        }
    }

    func sendImageToServer(image: UIImage) {
        guard let url = URL(string: "http://10.19.128.182:5729/upload") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        let imageData = image.jpegData(compressionQuality: 0.5)
        
        // Check if the last upload time was more than 1 second ago
        if let lastUploadTime = lastUploadTime, Date().timeIntervalSince(lastUploadTime) < 1 {
            return
        }
        
        lastUploadTime = Date()
        
        let task = URLSession.shared.uploadTask(with: request, from: imageData) { data, response, error in
            if let error = error {
                print("Error uploading image: \(error)")
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Server response: \(responseString)")
            }
        }
        task.resume()
    }
}

struct CamView: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager

    func makeUIView(context: Context) -> UIView {
        let uiView = UIView()
        if let captureSession = cameraManager.captureSession {
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = uiView.bounds
            uiView.layer.addSublayer(videoPreviewLayer)
        }
        return uiView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let videoPreviewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
                videoPreviewLayer.frame = uiView.bounds
            }
        }
    }
}

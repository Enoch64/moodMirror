//
//  Created by Vincent Liu on 2025-01-19.
//

import SwiftUI
import AVFoundation

struct LiveCameraScreen: View {
    @StateObject private var cameraManager = CameraManager()

    var body: some View {
        VStack {
            Text("Live Camera Screen")
                .font(.headline)
                .padding()

            CameraPreview(cameraManager: cameraManager)
                .aspectRatio(4/3, contentMode: .fit)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding()

            Text(cameraManager.serverResponse) // Display the server response
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding()

        }
        .navigationTitle("Live Camera View")
        .onAppear {
            cameraManager.startSession()
        }
        .onDisappear {
            cameraManager.stopSession()
        }
    }
}


class CameraManager: NSObject, ObservableObject {
    @Published var serverResponse: String = "Waiting for server response..."
    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var lastSentTimestamp: Date = Date()

    override init() {
        super.init()
        setupCaptureSession()
    }

    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else {
            print("Failed to create capture session")
            return
        }

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No front camera available")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            } else {
                print("Failed to add input to capture session")
            }

            videoOutput = AVCaptureVideoDataOutput()
            videoOutput?.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if let videoOutput = videoOutput, captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            } else {
                print("Failed to add output to capture session")
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.videoGravity = .resizeAspectFill

        } catch {
            print("Error setting up camera: \(error)")
        }
    }

    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.startRunning()
            print("Capture session started")
        }
    }

    func stopSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession?.stopRunning()
            print("Capture session stopped")
        }
    }

    func getPreviewLayer() -> AVCaptureVideoPreviewLayer? {
        return previewLayer
    }

    private func uploadImageToServer(data: Data) {
        let url = URL(string: "http://10.19.128.182:5729/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.serverResponse = "Upload failed: \(error.localizedDescription)"
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    self.serverResponse = "Status: \(httpResponse.statusCode)"
                }
            }

            if let responseData = responseData, let responseString = String(data: responseData, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.serverResponse = responseString
                }
            } else {
                DispatchQueue.main.async {
                    self.serverResponse = "No response data received"
                }
            }
        }
        task.resume()
    }
}


extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentTime = Date()

        // Throttle frame processing to every 2 seconds
        if currentTime.timeIntervalSince(lastSentTimestamp) < 2.0 {
            return
        }

        lastSentTimestamp = currentTime

        // Get the image buffer
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("Failed to get image buffer from sample buffer")
            return
        }

//        // Log frame size
//        let width = CVPixelBufferGetWidth(imageBuffer)
//        let height = CVPixelBufferGetHeight(imageBuffer)
//        print("Captured frame size: \(width)x\(height)")

        // Convert to CIImage and UIImage
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let uiImage = UIImage(ciImage: ciImage)

        // Ensure UIImage conversion was successful
        if uiImage.size == .zero {
            print("Failed to convert CVPixelBuffer to UIImage")
            return
        }

        print("Frame captured successfully: \(uiImage.size)")

        // Convert UIImage to JPEG Data
        if let jpegData = uiImage.jpegData(compressionQuality: 0.8) {
            print("JPEG data size: \(jpegData.count) bytes")
            uploadImageToServer(data: jpegData)
        } else {
            print("Failed to convert UIImage to JPEG data")
        }
    }

//    private func uploadImageToServer(data: Data) {
//        // Replace with your backend URL
//        let url = URL(string: "http://10.19.128.182:5729/upload")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
//
//        // Create the upload task
//        let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
//            if let error = error {
//                print("Failed to upload image: \(error.localizedDescription)")
//                return
//            }
//
//            // Check the HTTP response status
//            if let httpResponse = response as? HTTPURLResponse {
//                print("Server responded with status code: \(httpResponse.statusCode)")
//            }
//
//            // Process the response data
//            if let responseData = responseData {
//                if let responseString = String(data: responseData, encoding: .utf8) {
//                    print("Server response: \(responseString)")
//                } else {
//                    print("Unable to decode server response")
//                }
//            } else {
//                print("No response data received from the server")
//            }
//        }
//        task.resume()
//    }
}


struct CameraPreview: UIViewRepresentable {
    @ObservedObject var cameraManager: CameraManager

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black

        DispatchQueue.main.async {
            if let previewLayer = cameraManager.getPreviewLayer() {
                previewLayer.frame = view.bounds
                view.layer.addSublayer(previewLayer)
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let previewLayer = cameraManager.getPreviewLayer() {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}

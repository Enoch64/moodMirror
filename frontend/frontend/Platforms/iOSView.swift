import SwiftUI
import AVFoundation
import Foundation

class VideoSocketManager {
    private var socket: URLSessionWebSocketTask?
    private let url: URL
    private var session: URLSession

    var onConnect: (() -> Void)?

    init(url: URL) {
        self.url = url
        self.session = URLSession(configuration: .default)
    }

    func connect() {
        socket = session.webSocketTask(with: url)
        socket?.resume()
        
        socket?.receive { result in
            switch result {
            case .failure(let error):
                print("WebSocket connection failed: \(error)")
            case .success(let message):
                switch message {
                case .data(let data):
                    print("Received data: \(data)")
                case .string(let text):
                    print("Received text: \(text)")
                @unknown default:
                    fatalError()
                }
            }
        }
    }

    private func receiveMessages() {
        socket?.receive { result in
            switch result {
            case .failure(let error):
                print("WebSocket receive error: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string message: \(text)")
                    // Handle the response from the server after WebSocket upgrade
                    if text == "Connection established" {
                        print("Successfully connected to WebSocket!")
                    }
                case .data(let data):
                    print("Received data message: \(data)")
                @unknown default:
                    print("Unknown WebSocket message received")
                }
                self.receiveMessages()  // Recursively listen for more messages
            }
        }
    }

    func sendFrame(_ frameData: Data) {
        let message = URLSessionWebSocketTask.Message.data(frameData)
        socket?.send(message) { error in
            if let error = error {
                print("Error sending frame: \(error)")
            } else {
                print("Frame sent successfully")
            }
        }
    }

    func disconnect() {
        socket?.cancel(with: .normalClosure, reason: nil)
    }
}

struct CameraView: UIViewRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        var socketManager: VideoSocketManager

        init(parent: CameraView, socketManager: VideoSocketManager) {
            self.parent = parent
            self.socketManager = socketManager
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

            // Convert the pixel buffer into a JPEG image or video frame format
            if let imageData = convertPixelBufferToJPEG(pixelBuffer) {
                socketManager.sendFrame(imageData)
            }
        }

        func convertPixelBufferToJPEG(_ pixelBuffer: CVPixelBuffer) -> Data? {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let uiImage = UIImage(cgImage: cgImage)
                return uiImage.jpegData(compressionQuality: 0.5)
            }
            return nil
        }
    }

    var session: AVCaptureSession
    var previewLayer: AVCaptureVideoPreviewLayer
    var socketManager: VideoSocketManager

    init(socketURL: URL) {
        session = AVCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        socketManager = VideoSocketManager(url: socketURL)
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { response in
                if response {
                    self.setupSessionAndStart()
                } else {
                    print("Camera access denied")
                }
            }
        case .authorized:
            setupSessionAndStart()
        case .restricted, .denied:
            print("Camera access restricted or denied")
        @unknown default:
            print("Unknown camera authorization status")
        }
    }

    private func setupSessionAndStart() {
        DispatchQueue.global(qos: .background).async {
            self.setupSession()
            DispatchQueue.main.async {
                self.session.startRunning()
                self.socketManager.connect()

                // Set the onConnect callback to print a success message when connected
                self.socketManager.onConnect = {
                    print("Successfully connected to WebSocket!")
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, socketManager: socketManager)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black

        previewLayer.frame = view.bounds
        view.layer.addSublayer(previewLayer)

        // Ensure session starts only after permissions are granted
        checkCameraPermission()

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            self.previewLayer.frame = uiView.bounds
        }
    }

    private func setupSession() {
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("back camera is not available")
            return
        }

        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
            } else {
                print("Cannot add back camera input")
            }

            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(makeCoordinator(), queue: DispatchQueue(label: "videoOutputQueue"))
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
            } else {
                print("Cannot add video data output")
            }
        } catch {
            print("Error setting up back camera session: \(error)")
        }
    }
}

struct iOSSpecificView: View {
    var body: some View {
        VStack {
            Text("Live Camera Screen")
                .font(.headline)
                .padding()
            CameraView(socketURL: URL(string: "ws://10.19.128.182:5729")!)
                .frame(width: 320, height: 480)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 10)
        }
    }
}

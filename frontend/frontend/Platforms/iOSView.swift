import SwiftUI
import AVFoundation

struct CameraView: UIViewRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView

        init(parent: CameraView) {
            self.parent = parent
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // Process the video buffer if needed
        }
    }

    var session: AVCaptureSession
    var previewLayer: AVCaptureVideoPreviewLayer

    init() {
        session = AVCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
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
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
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
            CameraView()
                .frame(width: 320, height: 480)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 10)
        }
    }
}

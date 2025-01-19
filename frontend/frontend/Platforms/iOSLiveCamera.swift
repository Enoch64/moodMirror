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
    
    var body: some View {
        VStack {
            HStack {
                Text("Live Camera Screen")
                    .navigationTitle("Live Camera View")
                CamView()
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
    }
}

struct CamView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let uiView = UIView()
        let captureSession = AVCaptureSession()

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("No camera available")
            return uiView
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = uiView.bounds
            uiView.layer.addSublayer(videoPreviewLayer)

            captureSession.sessionPreset = .high
            captureSession.startRunning()
            print("live cam session is running")
            context.coordinator.videoPreviewLayer = videoPreviewLayer

        } catch {
            print("Error setting up camera: \(error)")
        }

        return uiView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.videoPreviewLayer?.frame = uiView.bounds
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    }
}

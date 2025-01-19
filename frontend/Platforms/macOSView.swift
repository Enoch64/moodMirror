//
//  macOSView.swift
//  frontend
//
//  Created by Vincent Liu on 2025-01-18.
//

import SwiftUI
import AVFoundation

struct WebcamView: NSViewRepresentable {
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: WebcamView

        init(parent: WebcamView) {
            self.parent = parent
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            // Process the video buffer if needed (e.g., for facial detection)
        }
    }

    var session: AVCaptureSession
    var previewLayer: AVCaptureVideoPreviewLayer

    init() {
        session = AVCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        setupSession()
        checkCameraPermission()
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        previewLayer.frame = nsView.bounds
        nsView.layer = previewLayer
        nsView.wantsLayer = true
        session.startRunning()
        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        previewLayer.frame = nsView.bounds
    }
    
    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // Ask for permission
            AVCaptureDevice.requestAccess(for: .video) { response in
                if response {
                    print("Permission granted")
                } else {
                    print("Permission denied")
                }
            }
        case .restricted, .denied:
            print("Camera access denied")
        case .authorized:
            print("Camera access granted")
        @unknown default:
            print("Unknown camera authorization status")
        }
    }


    private func setupSession() {
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
            }

            let videoDataOutput = AVCaptureVideoDataOutput()
            if session.canAddOutput(videoDataOutput) {
                session.addOutput(videoDataOutput)
                videoDataOutput.setSampleBufferDelegate(Coordinator(parent: self), queue: DispatchQueue.main)
            }
        } catch {
            print("Error setting up video capture session: \(error)")
        }
    }
    
}

struct macOSSpecificView: View {
    var body: some View {
        WebcamView()
            .frame(width: 640, height: 480)
    }
}

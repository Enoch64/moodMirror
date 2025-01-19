//
//  macOSLiveCamera.swift
//  frontend
//
//  Created by Eunsong on 2025-01-18.
//

import SwiftUI
import AVFoundation

struct WebcamView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()

        // Camera Setup
        let captureSession = AVCaptureSession()
        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("No camera available")
            return nsView
        }

        do {
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = nsView.bounds
            videoPreviewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]

            nsView.layer = CALayer()
            nsView.layer?.addSublayer(videoPreviewLayer)

            // Start session
            captureSession.startRunning()
        } catch {
            print("Error setting up camera: \(error)")
        }

        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // Update logic if needed
    }
}

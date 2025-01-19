//
//  macOSLiveCamera.swift
//  frontend
//
//  Created by Eunsong on 2025-01-18.
//

import SwiftUI
import AVFoundation


struct LiveCameraScreen: View {
    @State private var capture: NSImage?
    
    var body: some View {
        VStack {
            HStack(){
                Text("Live Camera Screen")
                    .navigationTitle("Live Camera View")
                WebcamView()
                    .frame(width: 640, height: 480)
                if let image = capture {
                    Image(nsImage: image)
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

struct WebcamView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()

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

        } catch {
            print("Error setting up camera: \(error)")
        }

        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        
    }
    
}



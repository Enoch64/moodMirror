//
//  macOSLiveCamera.swift
//  frontend
//
//  Created by Eunsong on 2025-01-18.
//

import SwiftUI
import AVFoundation

class VideoSocketManager {
    private var socket: URLSessionWebSocketTask?
    private let url: URL
    private var session: URLSession

    var onConnect: (() -> Void)?

    init(url: URL) {
        self.url = url
        self.session = URLSession(configuration: .default)
        connect()
    }

    func connect() {
        print("Connecting to WebSocket at: \(url)")
        socket = session.webSocketTask(with: url)
        
        // Add event listeners to log connection status
        socket?.resume()
        
        // Check WebSocket state
        if socket?.state == .running {
            print("WebSocket is running.")
        } else {
            print("WebSocket is not running.")
        }

        receiveMessages()
    }

    private func receiveMessages() {
        socket?.receive { result in
            switch result {
            case .failure(let error):
                print("WebSocket connection failed: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received string message: \(text)")
                    if text == "Connection established" {
                        print("Successfully connected to WebSocket!")
                        self.onConnect?()
                    }
                case .data(let data):
                    print("Received data message: \(data)")
                @unknown default:
                    print("Unknown WebSocket message received")
                }
                self.receiveMessages()
            }
        }
    }



    func sendFrame(_ frameData: Data) {
        print("About to Send Frame")
        let message = URLSessionWebSocketTask.Message.data(frameData)
        print(message)
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


struct LiveCameraScreen: View {
    @State private var capture: NSImage?
    
    private let socketManager = VideoSocketManager(url: URL(string: "ws://10.19.133.215:5729/")!)
    
    var body: some View {
        VStack {
            Text("Live Camera Screen")
                .navigationTitle("Live Camera View")
                .padding(.top)
            Spacer()
            
            HStack {
                Spacer()
                VStack {
                    WebcamView(socketManager: socketManager)
                        .frame(width: 640, height: 480)
                    if let image = capture {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 640, height: 480)
                            .cornerRadius(5)
                    } else {
                        Color.clear
                            .frame(width: 640, height: 480)
                            .cornerRadius(5)
                    }
                }
                Spacer()
            }
            Spacer()
        }
        .padding()
    }

}

struct WebcamView: NSViewRepresentable {
    let socketManager: VideoSocketManager
    
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
            } else {
                print("input not found")
            }
            
            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.videoGravity = .resizeAspectFill
            videoPreviewLayer.frame = nsView.bounds
            videoPreviewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
            
            nsView.layer = CALayer()
            nsView.layer?.addSublayer(videoPreviewLayer)
            
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoOutputQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            } else {
                print("video output not found")
            }
            
            captureSession.startRunning()
            
        } catch {
            print("Error setting up camera: \(error)")
        }
        
        return nsView
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    func makeCoordinator() -> Coordinator {
        return Coordinator(socketManager: socketManager)
    }
        
    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let socketManager: VideoSocketManager
        
        init(socketManager: VideoSocketManager) {
            self.socketManager = socketManager
        }
        
        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            print("capturing output")
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
                if let imageData = nsImage.tiffRepresentation(using: .jpeg, factor: 0.5) {
                        print("Sending frame")
                        socketManager.sendFrame(imageData)
                }
            }
        }
    }
}

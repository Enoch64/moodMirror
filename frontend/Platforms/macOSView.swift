import SwiftUI
import AVFoundation

struct macOSSpecificView: View {
    @State private var showLiveCameraView = false
    @State private var showCallView = false
    
    var body: some View {
        NavigationStack{
            VStack(spacing: 40){
                NavigationLink("Live"){
                    LiveCameraScreen()
                }
                NavigationLink("Call"){
                    CallScreen()
                }
            }
        }
    }
}

struct LiveCameraScreen: View {
    var body: some View {
        Text("Live Camera Screen")
            .navigationTitle("Live Camera View")
        WebcamView()
                    .frame(width: 640, height: 480)
    }
}

struct CallScreen: View {
    var body: some View {
        Text("Live Call Screen")
            .navigationTitle("Live Call View")
    }
}

//
//struct WebcamView: NSViewRepresentable {
//    func makeNSView(context: Context) -> NSView {
//        let nsView = NSView()
//
//        // Camera Setup
//        let captureSession = AVCaptureSession()
//        guard let camera = AVCaptureDevice.default(for: .video) else {
//            print("No camera available")
//            return nsView
//        }
//
//        do {
//            let input = try AVCaptureDeviceInput(device: camera)
//            if captureSession.canAddInput(input) {
//                captureSession.addInput(input)
//            }
//
//            let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            videoPreviewLayer.videoGravity = .resizeAspectFill
//            videoPreviewLayer.frame = nsView.bounds
//            videoPreviewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
//
//            nsView.layer = CALayer()
//            nsView.layer?.addSublayer(videoPreviewLayer)
//
//            // Start session
//            captureSession.startRunning()
//        } catch {
//            print("Error setting up camera: \(error)")
//        }
//
//        return nsView
//    }
//
//    func updateNSView(_ nsView: NSView, context: Context) {
//        // Update logic if needed
//    }
//}

import SwiftUI
import AVFoundation

struct macOSSpecificView: View {
    @State private var showLiveCameraView = false
    @State private var showCallView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                NavigationLink("Live") {
                    LiveCameraScreen()
                }
                NavigationLink("Call"){
                    CallScreen()
                }
                
                // Use the NSViewControllerRepresentable here
                
                
//                Button(action: {
//                    // Directly call the method from the wrapped ViewController
//                    ViewControllerRepresentable().makeNSViewController()
////                    ViewController.sharedInstance()
//                }) {
//                    Text("Call")
//                }
            }
        }
    }
}

struct CallScreen: View {
    var body: some View {
//        navigationTitle("Live Call View")
        ViewControllerRepresentable()
        
    }
}

struct ViewControllerRepresentable: NSViewControllerRepresentable {
    
    func makeNSViewController(context: Context) -> ViewController {
        let viewController = ViewController()
        return viewController
    }

    func updateNSViewController(_ nsViewController: ViewController, context: Context) {
    }
}
//
//struct LiveCameraScreen: View {
//    @State private var capture: NSImage?
//    @State private var webcamView: WebcamView?
//    
//    var body: some View {
//        VStack {
//            HStack(){
//                Text("Live Camera Screen")
//                    .navigationTitle("Live Camera View")
//                WebcamView()
//                    .frame(width: 640, height: 480)
//                    .background(GeometryReader { geo in
//                        Color.clear.onAppear {
//                            self.webcamView = WebcamView()
//                        }
//                    })
//                if let image = capture {
//                    Image(nsImage: image)
//                        .resizable()
//                        .scaledToFit() // To ensure it fits within its allocated space
//                        .frame(width: 640, height: 480) // Adjust size to match
//                } else {
//                    Color.clear
//                        .frame(width: 640, height: 480) // Placeholder
//                }
//        
//            }
//            .padding()
//            
//            Button("Capture", action: {
//                capture = ImageRenderer(content: WebcamView()).nsImage
//            })
//            .padding()
//            
//        }
//    }
    
//    func captureScreenshot() {
//        guard let webcamView = webcamView else { return }
//        
//        // Create an NSImage from the webcamView
//        let snapshot = webcamView.snapshot()
//        
//        // Assign the snapshot to the capture state
//        capture = snapshot
//    }
//}

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

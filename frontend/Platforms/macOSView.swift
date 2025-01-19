import SwiftUI
import AVFoundation

struct macOSSpecificView: View {
    @State private var showLiveCameraView = false
    @State private var showCallView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                Text("moodMirror")
                    .font(.system(size:60 , weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .shadow(radius:5)
                
                NavigationLink(destination: LiveCameraScreen()) {
                    Text("Live Camera Mode")
                        .font(.system(size: 20))
                        .padding(15)
                        .background(
                            ZStack {
                                Color.white.opacity(0.2)
                                Color.white.opacity(0.1)
                            }
                            .blur(radius: 10)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: CallScreen()) {
                    Text("Live Call Mode")
                        .font(.system(size: 20))
                        .padding(15)
                        .background(
                            ZStack {
                                Color.white.opacity(0.2)
                                Color.white.opacity(0.1)
                            }
                            .blur(radius: 10)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }

}

struct CallScreen: View {
    var body: some View {
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

import SwiftUI
import AVFoundation

struct macOSSpecificView: View {
    @State private var showLiveCameraView = false
    @State private var showCallView = false

    var body: some View {
        NavigationStack {
                VStack(spacing: 40) {
                    Text("moodMirror")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    NavigationLink("Live Camera Mode") {
                        LiveCameraScreen()
                    }
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .background(.black)
                    .cornerRadius(5)
                    .padding()
                    .buttonStyle(.borderedProminent)
                    
                    NavigationLink("Live Call Mode") {
                        CallScreen()
                    }
                    .font(.system(size: 20))
                    .background(.black)
                    .foregroundColor(.white)
                    .cornerRadius(5)
                    .padding()
                    .buttonStyle(.borderedProminent)
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

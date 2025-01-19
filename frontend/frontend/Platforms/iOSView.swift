import SwiftUI
import AVFoundation

struct iOSSpecificView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                NavigationLink("Live Camera") {
                    LiveCameraScreen()
                }
                NavigationLink("Call View") {
                    CallScreen()
                }
            }
            .navigationTitle("Main Menu")
        }
    }
}

struct CallScreen: View {
    var body: some View {
        VStack {
            Text("Call Screen")
                .font(.title)
            ViewControllerRepresentable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .navigationTitle("Call")
    }
}

struct ViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
        // Update logic if needed
    }
}

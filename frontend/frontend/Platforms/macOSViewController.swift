import AgoraRtcKit
import Cocoa

class ViewController: NSViewController {
    static var shared: ViewController?
    
    var localView: NSView!
    var remoteView: NSView!
    var agoraKit: AgoraRtcEngineKit!
    private var lastSentTimestamp: Date = Date()
    
    var remoteViewFrame: CGRect?
    var responseLabel: NSTextField!

    override func viewDidLayout() {
        super.viewDidLayout()

        if let screenFrame = NSScreen.main?.frame {
            let remoteViewWidth: CGFloat = 640
            let remoteViewHeight: CGFloat = 480
            remoteView.frame = CGRect(
                x: (screenFrame.width - remoteViewWidth) / 2,
                y: (screenFrame.height - remoteViewHeight) / 2,
                width: remoteViewWidth,
                height: remoteViewHeight
            )
            
            remoteViewFrame = remoteView.frame

            let localViewWidth: CGFloat = 135
            let localViewHeight: CGFloat = 240
            let topPadding: CGFloat = 40

            localView.frame = CGRect(
                x: 20,
                y: topPadding,
                width: localViewWidth,
                height: localViewHeight
            )
        }
    }

    func initView() {
        remoteView = NSView()
           self.view.addSubview(remoteView)

           localView = NSView()
           self.view.addSubview(localView)

           responseLabel = NSTextField(labelWithString: "Server Response: Waiting...")
           responseLabel.font = NSFont.systemFont(ofSize: 20)
           responseLabel.textColor = NSColor.white
           responseLabel.frame = CGRect(x: 250, y: 20, width: 600, height: 40)
           self.view.addSubview(responseLabel)

        if let appId = ProcessInfo.processInfo.environment["APP_ID"] {
            print(appId)
            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
        } else {
            print("APP ID INVALID")
        }
    }

    deinit {
        agoraKit.stopPreview()
        agoraKit.leaveChannel(nil)
        AgoraRtcEngineKit.destroy()
    }

    func startPreview() {
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.view = localView
        videoCanvas.renderMode = .hidden
        agoraKit.setupLocalVideo(videoCanvas)
        agoraKit.startPreview()
    }

    func joinChannel() {
        let options = AgoraRtcChannelMediaOptions()
        options.channelProfile = .liveBroadcasting
        options.clientRoleType = .broadcaster
        options.publishMicrophoneTrack = true
        options.publishCameraTrack = true
        options.autoSubscribeAudio = true
        options.autoSubscribeVideo = true

        if let token = ProcessInfo.processInfo.environment["TEMP_TOKEN"],
           let cId = ProcessInfo.processInfo.environment["CHANNEL_NAME"],
           !cId.isEmpty,
           !token.isEmpty {
            agoraKit.joinChannel(byToken: token, channelId: cId, uid: 0, mediaOptions: options)
        } else {
            print("Join Channel Failed")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        agoraKit.enableVideo()
        startPreview()
        joinChannel()
        
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(captureRemoteViewImage), userInfo: nil, repeats: true)
    }

    @objc func captureRemoteViewImage() {
        let currentTime = Date()

        if currentTime.timeIntervalSince(lastSentTimestamp) < 2.0 {
            return
        }

        lastSentTimestamp = currentTime


        if let remoteViewFrame = remoteViewFrame,
           let screenshotData = captureScreenshot(of: remoteViewFrame) {
            uploadImageToServer(data: screenshotData)
        }
    }


    func captureScreenshot(of frame: CGRect) -> Data? {
        guard let screenImage = CGWindowListCreateImage(frame, .optionOnScreenBelowWindow, kCGNullWindowID, .bestResolution) else {
            print("Failed to capture the screen area")
            return nil
        }
        
        let image = NSImage(cgImage: screenImage, size: frame.size)
        
        if let imageData = image.tiffRepresentation {
            let bitmapRep = NSBitmapImageRep(data: imageData)
            let jpegData = bitmapRep?.representation(using: .jpeg, properties: [:])
            return jpegData
        }
        
        return nil
    }

    private func uploadImageToServer(data: Data) {
        let url = URL(string: "http://10.19.128.182:5729/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        request.setValue("macOS", forHTTPHeaderField: "platform")
        let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print("Upload failed: \(error.localizedDescription)")
                    self.updateResponseLabel("Upload failed: \(error.localizedDescription)")
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    print("Status: \(httpResponse.statusCode)")
                    self.updateResponseLabel("Status: \(httpResponse.statusCode)")
                }
            }

            if let responseData = responseData, let responseString = String(data: responseData, encoding: .utf8) {
                DispatchQueue.main.async {
                    print("Server response: \(responseString)")
                    self.updateResponseLabel("Server response: \(responseString)")
                }
            } else {
                DispatchQueue.main.async {
                    print("No response data received")
                    self.updateResponseLabel("No response data received")
                }
            }
        }
        task.resume()
    }

    private func updateResponseLabel(_ responseText: String) {
        responseLabel.stringValue = "Server Response: \(responseText)"
    }
}

extension ViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
        print("didJoinChannel: \(channel), uid: \(uid)")
    }
    
    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
        print("Agora Error: \(errorCode.rawValue)")
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        print("User \(uid) joined after \(elapsed) milliseconds")
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = remoteView
        videoCanvas.renderMode = .hidden
        agoraKit.setupRemoteVideo(videoCanvas)
    }

    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
        print("User \(uid) went offline due to \(reason)")
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = nil
        agoraKit.setupRemoteVideo(videoCanvas)
    }
}

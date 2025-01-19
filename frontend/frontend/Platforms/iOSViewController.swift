////
////  iOSViewController.swift
////  frontend
////
////  Created by Vincent Liu on 2025-01-19.
////
//
//import AgoraRtcKit
//import UIKit
//
//class ViewController: UIViewController {
//    static var shared: ViewController?
//    
//    // Local video view
//    var localView: UIView!
//    // Remote video view
//    var remoteView: UIView!
//    // RTC engine
//    var agoraKit: AgoraRtcEngineKit!
//
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        // Get screen frame
//        let screenFrame = view.bounds
//        
//        // Remote view (full screen)
//        remoteView.frame = CGRect(
//            x: 0,
//            y: 0,
//            width: screenFrame.width,
//            height: screenFrame.height
//        )
//        
//        // Local view (small preview in the top-right corner)
//        let localViewWidth: CGFloat = 135
//        let localViewHeight: CGFloat = 240
//        localView.frame = CGRect(
//            x: screenFrame.width - localViewWidth - 16, // Right margin
//            y: 16, // Top margin
//            width: localViewWidth,
//            height: localViewHeight
//        )
//    }
//
//    func initView() {
//        // Initialize remote video window
//        remoteView = UIView()
//        remoteView.backgroundColor = .black
//        self.view.addSubview(remoteView)
//        
//        // Initialize local video window
//        localView = UIView()
//        localView.backgroundColor = .lightGray
//        localView.layer.cornerRadius = 8
//        localView.layer.masksToBounds = true
//        self.view.addSubview(localView)
//
//        // Initialize the RTC instance
//        if let appId = ProcessInfo.processInfo.environment["APP_ID"] {
//            print(appId)
//            agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: self)
//        } else {
//            print("APP ID INVALID")
//        }
//    }
//
//    deinit {
//        agoraKit.stopPreview()
//        agoraKit.leaveChannel(nil)
//        AgoraRtcEngineKit.destroy()
//    }
//
//    func startPreview() {
//        let videoCanvas = AgoraRtcVideoCanvas()
//        videoCanvas.view = localView
//        videoCanvas.renderMode = .hidden
//        agoraKit.setupLocalVideo(videoCanvas)
//        agoraKit.startPreview()
//    }
//
//    func joinChannel() {
//        let options = AgoraRtcChannelMediaOptions()
//        // Set the channel scene to live broadcast
//        options.channelProfile = .liveBroadcasting
//        // Set the user role to broadcaster
//        options.clientRoleType = .broadcaster
//        // Publish the audio and video
//        options.publishMicrophoneTrack = true
//        options.publishCameraTrack = true
//        // Automatically subscribe to all streams
//        options.autoSubscribeAudio = true
//        options.autoSubscribeVideo = true
//
//        if let token = ProcessInfo.processInfo.environment["TEMP_TOKEN"],
//           let cId = ProcessInfo.processInfo.environment["CHANNEL_NAME"],
//           !cId.isEmpty,
//           !token.isEmpty {
//            print("Joining channel with token and channel ID")
//            agoraKit.joinChannel(byToken: token, channelId: cId, uid: 0, mediaOptions: options)
//        } else {
//            print("JOIN CHANNEL FAILED")
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .white
//        print("Loading the view")
//        initView()
//        agoraKit.enableVideo()
//        startPreview()
//        joinChannel()
//    }
//    
//    static func sharedInstance() -> ViewController {
//        if shared == nil {
//            shared = ViewController()
//        }
//        return shared!
//    }
//    
//    func startVideoCallButtonPressed() {
//        print("Start Video Call Button Pressed")
//        initView()
//        
//        guard agoraKit != nil else {
//            print("Error: Agora engine not initialized.")
//            return
//        }
//
//        agoraKit.enableVideo()
//        startPreview()
//        joinChannel()
//    }
//}
//
//extension ViewController: AgoraRtcEngineDelegate {
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinChannel channel: String, withUid uid: UInt, elapsed: Int) {
//        print("didJoinChannel: \(channel), uid: \(uid)")
//    }
//    
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didOccurError errorCode: AgoraErrorCode) {
//        print("Agora Error: \(errorCode.rawValue)")
//    }
//
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
//        print("User \(uid) joined after \(elapsed) milliseconds")
//        let videoCanvas = AgoraRtcVideoCanvas()
//        videoCanvas.uid = uid
//        videoCanvas.view = remoteView
//        videoCanvas.renderMode = .hidden
//        agoraKit.setupRemoteVideo(videoCanvas)
//    }
//
//    func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt, reason: AgoraUserOfflineReason) {
//        print("User \(uid) went offline due to \(reason)")
//        let videoCanvas = AgoraRtcVideoCanvas()
//        videoCanvas.uid = uid
//        videoCanvas.view = nil
//        agoraKit.setupRemoteVideo(videoCanvas)
//    }
//}

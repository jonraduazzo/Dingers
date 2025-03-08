
//
//  ContentView.swift
//  Dingers Prototype
//
//  Created by Dingers Incorporated on 12/15/24.
//
import FLAnimatedImage
import SwiftUI
import PhotosUI  // For video selection
import AVKit  // For video playback
import AVFoundation  // For audio session configuration
import Vision  // For YOLOv8 object detection
import CoreML  // For integrating the YOLOv8 Core ML model
import UIKit  // For landscape orientation control

class AudioManager {
    static let shared = AudioManager()
    private var musicPlayer: AVAudioPlayer?
    private var crowdPlayer: AVAudioPlayer?
    private var buttonPlayer: AVAudioPlayer?

    private init() {}

    func playBackgroundMusic() {
        // ✅ Load and play **Menu Music**
        if let musicURL = Bundle.main.url(forResource: "Menu Music", withExtension: "mp3") {
            do {
                musicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                musicPlayer?.volume = 0.2
                musicPlayer?.numberOfLoops = -1  // ✅ Loop indefinitely
                musicPlayer?.play()
            } catch {
                print("🚨 Error playing menu music: \(error.localizedDescription)")
            }
        } else {
            print("🚨 Menu Music file not found!")
        }

        // ✅ Load and play **Crowd Noise** separately
        if let crowdURL = Bundle.main.url(forResource: "Crowd Noise", withExtension: "mp3") {
            do {
                crowdPlayer = try AVAudioPlayer(contentsOf: crowdURL)
                crowdPlayer?.numberOfLoops = -1  // ✅ Loop indefinitely
                crowdPlayer?.volume = 0.2  // ✅ Lower volume for background effect
                crowdPlayer?.play()
            } catch {
                print("🚨 Error playing crowd noise: \(error.localizedDescription)")
            }
        } else {
            print("🚨 Crowd Noise file not found!")
        }
    }

    func stopBackgroundMusic() {
        musicPlayer?.pause()
        crowdPlayer?.pause()
    }

    func restartBackgroundMusic() {
        musicPlayer?.currentTime = 0
        crowdPlayer?.currentTime = 0
        musicPlayer?.play()
        crowdPlayer?.play()
    }

    func playButtonSound() {
        guard let url = Bundle.main.url(forResource: "Button Noise", withExtension: "mp3") else {
            print("🚨 Button click sound file not found!")
            return
        }

        do {
            buttonPlayer = try AVAudioPlayer(contentsOf: url)
            buttonPlayer?.volume = 0.1  // ✅ Adjust volume if needed
            buttonPlayer?.play()
        } catch {
            print("🚨 Error playing button sound: \(error.localizedDescription)")
        }
    }
   
    func playHomeRun() {
        guard let url = Bundle.main.url(forResource: "HOME RUN CELEBRATION", withExtension: "mp3") else {
            print("🚨 Home Run sound file not found!")
            return
        }
        
        do {
            buttonPlayer = try AVAudioPlayer(contentsOf: url)
            buttonPlayer?.volume = 0.5  // ✅ Adjust volume if needed
            buttonPlayer?.play()
        } catch {
            print("🚨 Error playing Home Run sound: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ContentView()
        .previewInterfaceOrientation(.landscapeLeft)  // ✅ Ensure it shows correctly
}

struct VideoBackgroundView: UIViewControllerRepresentable {
    let videoName: String

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill // ✅ Ensures full-screen video coverage
        
        if let path = Bundle.main.path(forResource: videoName, ofType: "mp4") {
            let url = URL(fileURLWithPath: path)
            let player = AVPlayer(url: url)
            player.isMuted = true
            player.rate = 6.0  // ✅ Play at 2x speed

            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }

            player.play()
            controller.player = player
        }
        
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}
}

struct ContentView: View {
    @State private var isShowingVideoPicker = false
    @State private var isShowingDifficultySelection = false
    @State private var videoURL: URL?
    @State private var isLiveModeSelected = false
    @State private var isVideoModeSelected = false
    @State private var isShowingLiveTracking = false
    @State private var isShowingModeSelection = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 📸 **Background Image**
                VideoBackgroundView(videoName: "CLOUD") // Replace with actual video name
                               .edgesIgnoringSafeArea(.all) // ✅ Ensures the video fully covers the screen
          .zIndex(0) // 🎥 Ensure it's behind everything
                
                
                Image("Welcome Screen")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                }
                
                // 🎯 **Buttons**
                customButton(title: "DIFFICULTY", color: Color("DarkBlue"), fontSize: 30, width: 170, height: 50) {
                    isShowingDifficultySelection = true
                }
                .sheet(isPresented: $isShowingDifficultySelection) {
                    DifficultySelectionView()
                }
                .position(x: geometry.size.width * 0.37, y: geometry.size.height * 0.50)

                customButton(title: "GAME MODE", color: Color("DarkBlue"), fontSize: 30, width: 170, height: 50) {
                    isShowingModeSelection = true
                }
                .sheet(isPresented: $isShowingModeSelection) {
                    ModeSelectionView()  // ✅ Present the correct view
                }
                .position(x: geometry.size.width * 0.37, y: geometry.size.height * 0.68)

                // 🎥 **Live Mode Button**
                customButton(title: "LIVE MODE",
                             color: isLiveModeSelected ? Color("DarkBlue") : Color.gray, // ✅ Turns blue when active
                             fontSize: 30, width: 170, height: 50) {
                    isLiveModeSelected = true
                    isVideoModeSelected = false // ✅ Reset Video Mode when Live Mode is selected
                }
                .position(x: geometry.size.width * 0.64, y: geometry.size.height * 0.50)

                // 🎥 **Video Mode Button**
                customButton(title: "VIDEO MODE",
                             color: isVideoModeSelected ? Color("DarkBlue") : Color.gray, // ✅ Turns blue when active
                             fontSize: 30, width: 170, height: 50) {
                    isVideoModeSelected = true
                    isLiveModeSelected = false // ✅ Reset Live Mode when Video Mode is selected
                    isShowingVideoPicker = true
                }
                .sheet(isPresented: $isShowingVideoPicker) {
                    VideoPicker(videoURL: $videoURL)
                }
                .position(x: geometry.size.width * 0.64, y: geometry.size.height * 0.68)

                // 🎾 **Play Ball Button**
                if isLiveModeSelected || videoURL != nil {
                    customButton(title: "PLAY BALL!", color: .green, fontSize: 30, width: 150, height: 50) {
                        AudioManager.shared.stopBackgroundMusic()

                        if isLiveModeSelected {
                            isShowingLiveTracking = true // ✅ Open Live Camera Mode
                        } else if let videoURL = videoURL {
                            let window = UIApplication.shared.windows.first
                            window?.rootViewController?.present(OverlayVideoPlayerController(videoURL: videoURL), animated: true)
                        }
                    }
                    .position(x: geometry.size.width * 0.5, y: geometry.size.height * 0.85)
                }
            }
        }
        .onAppear {
            AudioManager.shared.playBackgroundMusic() // ✅ Start background music
        }
        .fullScreenCover(isPresented: $isShowingLiveTracking) {  // ✅ Properly presents Live Mode
                    LiveTrackingView()
                }
    }

    // 🎯 **Custom Button Function**
    func customButton(title: String, color: Color, fontSize: CGFloat, width: CGFloat, height: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: {
            AudioManager.shared.playButtonSound() // ✅ Play button sound
            action()
        }) {
            Text(title)
                .font(.custom("Geared Slab", size: fontSize))
                .frame(width: width, height: height)
                .background(color.opacity(0.85))
                .foregroundColor(.white)
                .cornerRadius(0)
                .shadow(radius: 3)
        }
    }
}


struct LiveTrackingView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LiveTrackingViewController {
        return LiveTrackingViewController()
    }

    func updateUIViewController(_ uiViewController: LiveTrackingViewController, context: Context) {}

    // ✅ Add preview support by returning an empty UIViewController
    #if DEBUG
    struct LiveTrackingView_Previews: PreviewProvider {
        static var previews: some View {
            LiveTrackingView()
                .previewLayout(.fixed(width: 800, height: 450))  // 🔹 Adjust for UI testing
        }
    }
    #endif
}

import UIKit
import AVFoundation
import Vision


class TrackingViewController: UIViewController {
    var boundingBoxLayers: [CALayer] = []
    var parabolaLayer: CAShapeLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOverlay()
        setupParabolaLayer()
    }

    private func setupOverlay() {
        let overlayImageView = UIImageView(frame: view.bounds)
        overlayImageView.image = UIImage(named: "Righty Setup")  // ✅ Use the same setup image
        overlayImageView.contentMode = .scaleAspectFit
        overlayImageView.isUserInteractionEnabled = false
        view.addSubview(overlayImageView)
    }

    private func setupParabolaLayer() {
        parabolaLayer = CAShapeLayer()
        parabolaLayer.strokeColor = UIColor.systemBlue.cgColor
        parabolaLayer.lineWidth = 5
        parabolaLayer.fillColor = UIColor.clear.cgColor
        parabolaLayer.opacity = 1.0
        view.layer.addSublayer(parabolaLayer)
    }

    func updateBoundingBoxes(trackedPoints: [(CGPoint, Int)]) {
        boundingBoxLayers.forEach { $0.removeFromSuperlayer() }
        boundingBoxLayers.removeAll()

        let videoFrame = view.bounds

        for (point, _) in trackedPoints {
            let layer = CALayer()
            layer.frame = CGRect(
                x: point.x * videoFrame.width - 5,
                y: (1 - point.y) * videoFrame.height - 5,
                width: 7,
                height: 7
            )
            layer.backgroundColor = UIColor.red.cgColor
            layer.cornerRadius = 5
            view.layer.addSublayer(layer)
            boundingBoxLayers.append(layer)
        }
    }

    func updateParabola(with points: [(CGPoint, Int)]) {
        guard points.count >= 3 else { return }

        let path = UIBezierPath()
        let videoFrame = view.bounds
        let convertedPoints = points.map { (point, _) in
            CGPoint(
                x: point.x * videoFrame.width,
                y: (1 - point.y) * videoFrame.height
            )
        }
        
        if let coefficients = fitParabola(to: convertedPoints) {
            path.move(to: convertedPoints.first!)
            for x in stride(from: convertedPoints.first!.x, to: convertedPoints.last!.x, by: 1) {
                let y = coefficients.a * x * x + coefficients.b * x + coefficients.c
                path.addLine(to: CGPoint(x: x, y: y))
            }
        } else {
            print("❌ Parabola fitting failed.")
        }

        parabolaLayer.path = path.cgPath
        parabolaLayer.strokeColor = UIColor.systemYellow.cgColor
        parabolaLayer.fillColor = UIColor.clear.cgColor
        parabolaLayer.lineWidth = 5
    }
}
class LiveTrackingViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private let videoOutput = AVCaptureVideoDataOutput()
    private let modelHandler = ModelHandler()

    private var startButton: UIButton!
    private var exitButton: UIButton! // ✅ Declare exit button as a class property
    private var isTracking = false
    private var overlayView: UIView!  // 🔥 Full-screen overlay

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupOverlay()  // ✅ Add overlay on top of video feed
        setupUI()
    }

    private func setupCamera() {
        captureSession.sessionPreset = .hd1920x1080  // ✅ Ensures 1080p video resolution

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            print("🚨 Failed to access camera")
            return
        }

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }

        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "cameraFrameProcessingQueue"))
        videoOutput.alwaysDiscardsLateVideoFrames = true
        captureSession.addOutput(videoOutput)

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = view.bounds
        previewLayer.connection?.videoOrientation = .landscapeRight  // ✅ Ensures correct orientation
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    private func setupOverlay() {
        let overlayImageView = UIImageView(frame: view.bounds)
        overlayImageView.image = UIImage(named: "Righty Setup")  // ✅ Use "Righty Setup" image
        overlayImageView.contentMode = .scaleAspectFit;        
        overlayImageView.isUserInteractionEnabled = false  // ✅ Ensures taps go through
        view.addSubview(overlayImageView)
    }

    private func setupUI() {
        // ✅ **Ready Button (Centered)**
        startButton = UIButton(type: .system)
        startButton.setTitle("READY", for: .normal)
        startButton.setTitleColor(.white, for: .normal)
        startButton.titleLabel?.font = UIFont(name: "Geared Slab", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .bold)
        startButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)
        startButton.layer.cornerRadius = 10
        startButton.addTarget(self, action: #selector(toggleTracking), for: .touchUpInside)
        
        startButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(startButton)

        // ✅ **Exit Button (Top-Left)**
        exitButton = UIButton(type: .system) // ✅ Use the existing class property
        exitButton.setTitle("EXIT", for: .normal)
        exitButton.setTitleColor(.white, for: .normal)
        exitButton.titleLabel?.font = UIFont(name: "Geared Slab", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        exitButton.backgroundColor = UIColor(named: "DarkBlue")?.withAlphaComponent(0.7)
        exitButton.layer.cornerRadius = 10
        exitButton.addTarget(self, action: #selector(exitToHome), for: .touchUpInside)
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        

        // ✅ **Auto Layout Constraints**
        NSLayoutConstraint.activate([
            // 🎯 **Center Ready Button Horizontally & Position Near Bottom**
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            startButton.widthAnchor.constraint(equalToConstant: 100),
            startButton.heightAnchor.constraint(equalToConstant: 50),

            // 🎯 **Position Exit Button in Top-Left Corner**
            exitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exitButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            exitButton.widthAnchor.constraint(equalToConstant: 80),
            exitButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc private func startTracking() {
        isTracking = true
        startButton.isHidden = true  // ✅ Hide "READY" button after tracking starts

        // ✅ Remove setup overlay image
        for subview in view.subviews {
            if let imageView = subview as? UIImageView, imageView.image == UIImage(named: "Righty Setup") {
                imageView.removeFromSuperview()
            }
        }
    }
        // ✅ **Exit Button Function**
        @objc private func exitToHome() {
            print("🏠 Exiting to Home Screen...")
            dismiss(animated: true, completion: nil)
        }

    @objc private func toggleTracking() {
        isTracking.toggle()

        if isTracking {
            startButton.setTitle("STOP", for: .normal)
            startButton.backgroundColor = UIColor.systemRed.withAlphaComponent(0.8)
            
            // ✅ Hide overlay image when tracking starts
            for subview in view.subviews {
                if let imageView = subview as? UIImageView, imageView.image == UIImage(named: "Righty Setup") {
                    imageView.removeFromSuperview()
                }
            }

            // ✅ Use BallTracker for tracking (same logic as Video Mode)
            captureSession.startRunning()
        } else {
            startButton.setTitle("READY", for: .normal)
            startButton.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.8)

            captureSession.stopRunning()
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isTracking else { return }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            print("🚨 Failed to get pixel buffer")
            return
        }

        let frameCounter = Int(CACurrentMediaTime() * 1000)  // Milliseconds timestamp
        modelHandler.detectSportsBall(in: pixelBuffer, frameCounter: frameCounter) { allTrackedPoints, trackedPoints in
            DispatchQueue.main.async {
                self.updateBoundingBoxes(trackedPoints: trackedPoints)
            }
        }
    }

    private var boundingBoxLayers: [CALayer] = []

    private func updateBoundingBoxes(trackedPoints: [(CGPoint, Int)]) {
        boundingBoxLayers.forEach { $0.removeFromSuperlayer() }
        boundingBoxLayers.removeAll()

        let videoFrame = view.bounds

        for (point, _) in trackedPoints {
            let layer = CALayer()
            layer.frame = CGRect(
                x: point.x * videoFrame.width - 5,
                y: (1 - point.y) * videoFrame.height - 5,
                width: 7,
                height: 7
            )
            layer.backgroundColor = UIColor.red.cgColor
            layer.cornerRadius = 5
            view.layer.addSublayer(layer)
            boundingBoxLayers.append(layer)
        }
    }
}


struct DifficultySelectionView: View {
    @AppStorage("homeRunDistance") private var homeRunDistance: Int = 180  // Default to Little League
    @Environment(\.presentationMode) var presentationMode  // ✅ Allows dismissing the view

    let difficulties = [
        ("Pro", 400, "PRO"),
        ("Varsity", 300, "VARSITY"),
        ("Little League", 180, "LITTLE LEAGUE"),
        ("Rookie", 90, "ROOKIE")
    ]
    
    // ✅ Get the selected background image
    var selectedImage: String {
        difficulties.first(where: { $0.1 == homeRunDistance })?.2 ?? "Little League"
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 📸 **Dynamic Background Image**
                Image(selectedImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                // 📍 **Position Buttons in Left Half**
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Difficulty")
                        .frame(width: geometry.size.width * 0.25, height: 35)
                        .font(.custom("FenwayParkJF", size: 40, relativeTo: .title))                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 10)
                    
                    // 🎯 **Difficulty Buttons**
                    ForEach(difficulties, id: \.1) { difficulty in
                        Button(action: {
                            homeRunDistance = difficulty.1
                        }) {
                            Button(action: {
                                homeRunDistance = difficulty.1
                            }) {
                                Text(difficulty.0)
                                    .font(.custom("Geared Slab", size: 24))  // ✅ Updated font
                                    .frame(width: geometry.size.width * 0.25, height: 35)
                                    .background(homeRunDistance == difficulty.1 ? Color("Baseball") : Color("DarkBlue"))
                                    .foregroundColor(homeRunDistance == difficulty.1 ? Color("DarkBlue") : Color("Baseball"))
                                    .cornerRadius(10)
                                    .shadow(radius: 3)
                            }
                        }
                    }
                    
                    // ✅ **Submit Button**
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Submit")
                            .font(.custom("Geared Slab", size: 24))  // ✅ Updated font
                            .frame(width: geometry.size.width * 0.25, height: 35)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                }
                .frame(width: geometry.size.width * 0.5)  // ✅ Buttons stay on the left half
                .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.5)  // ✅ Centered left
            }
        }
    }
}

struct ModeSelectionView: View {
    @State private var selectedMode: String? = "Free Play"  // ✅ Default to "Free Play"
    @Environment(\.presentationMode) var presentationMode  // ✅ Allows dismissing the view

    let Modes = [
        ("Free Play", "Free Play"),
        ("Home Run Derby", "Home Run Derby"),
        ("Deepest Dinger", "Deepest Dinger"),
        ("Hardest Hit", "Hardest Hit"),
        ("Hit Parade", "Hit Parade")
    ]

    var selectedImage: String {
        return selectedMode ?? "Free Play"
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image(selectedImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 15) {
                    Text("Game Modes")
                        .frame(width: geometry.size.width * 0.25, height: 35)
                        .font(.custom("FenwayParkJF", size: 40, relativeTo: .title))
                        .bold()
                        .foregroundColor(.white)
                        .padding(.top, 10)

                    ForEach(Modes, id: \.1) { mode in
                        Button(action: {
                            selectedMode = mode.1
                        }) {
                            Text(mode.0)
                                .font(.custom("Geared Slab", size: 24))
                                .frame(width: geometry.size.width * 0.25, height: 35)
                                .background(selectedMode == mode.1 ? Color("Baseball") : Color("DarkBlue"))
                                .foregroundColor(selectedMode == mode.1 ? Color("DarkBlue") : Color("Baseball"))
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                    }

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Submit")
                            .font(.custom("Geared Slab", size: 24))
                            .frame(width: geometry.size.width * 0.25, height: 35)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                }
                .frame(width: geometry.size.width * 0.5)
                .position(x: geometry.size.width * 0.25, y: geometry.size.height * 0.5)
            }
        }
    }
}

struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.filter = .videos
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: VideoPicker

        init(_ parent: VideoPicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider else {
                print("No video selected")
                return
            }

            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { (tempURL, error) in
                    guard let tempURL = tempURL else {
                        print("Error loading file: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }

                    let fileManager = FileManager.default
                    let tempDir = fileManager.temporaryDirectory
                    let destinationURL = tempDir.appendingPathComponent(tempURL.lastPathComponent)

                    do {
                        if fileManager.fileExists(atPath: destinationURL.path) {
                            try fileManager.removeItem(at: destinationURL)
                        }
                        try fileManager.copyItem(at: tempURL, to: destinationURL)
                        DispatchQueue.main.async {
                            self.parent.videoURL = destinationURL
                        }
                    } catch {
                        print("Error copying video file: \(error.localizedDescription)")
                    }
                }
            } else {
                print("Selected item is not a video")
            }
        }
    }
}
class ModelHandler {
    private var model: VNCoreMLModel?
    private var lastObservation: VNDetectedObjectObservation?
    var previousPosition: CGPoint? = nil
    var currentDirection: Int = 0
    var smashPointDetected = false
    var smashPoint: CGPoint? = nil
    var trackedPoints: [(CGPoint, Int)] = []
    var allTrackedPoints: [(CGPoint, Int)] = []  // ✅ New: Stores **all** detected points

    func getSmashPoint() -> (CGPoint, Int)? {
        return trackedPoints.first
    }
    
    init() {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let coreMLModel = try yolo11s(configuration: MLModelConfiguration()).model
                let visionModel = try VNCoreMLModel(for: coreMLModel)
                
                DispatchQueue.main.async {
                    self.model = visionModel  // ✅ Now allowed since `model` is a `var`
                    print("✅ Model Loaded Successfully!")
                }
            } catch {
                print("🚨 Failed to load YOLOv8 model: \(error)")
            }
        }
    }
    
    func getFirstSpeedCalcPoint() -> (CGPoint, Int)? {
        guard trackedPoints.count > 1 else { return nil }

        var rightwardCandidates: [(CGPoint, Int)] = []

        for i in 1..<trackedPoints.count {
            let prev = trackedPoints[i - 1].0
            let current = trackedPoints[i].0
            let deltaX = current.x - prev.x

            if deltaX > 0 {  // ✅ Candidate for first movement rightward
                rightwardCandidates.append(trackedPoints[i])
            }
        }

        guard let firstCandidate = rightwardCandidates.first else { return nil }

        // ✅ Apply stability check (ensure it's not a false positive)
        let candidateIndex = trackedPoints.firstIndex(where: { $0.0 == firstCandidate.0 }) ?? 0
        let laterPoints = trackedPoints.suffix(from: candidateIndex + 1)
        let furtherLeftCount = laterPoints.filter { $0.0.x < firstCandidate.0.x }.count

        if furtherLeftCount < 1 {  // ✅ Ensure transition is stable
            return firstCandidate
        }

        return nil
    }
    
    

    func detectSportsBall(in pixelBuffer: CVPixelBuffer, frameCounter: Int, completion: @escaping ([(CGPoint, Int)], [(CGPoint, Int)]) -> Void) {
        guard let model = self.model else {
            completion([], [])
            return
        }
        let request = VNCoreMLRequest(model: model) { request, error in            guard let results = request.results as? [VNRecognizedObjectObservation] else {
                completion([], [])
                return
            }

            let filteredResults = results.filter {
                $0.labels.first?.identifier == "sports ball" && $0.confidence > 0.25
            }

            // ✅ Optional Debug: Uncomment to print **all** detected points before the smash point
                /*
                print("🟠 Pre-Smash Frame \(frameCounter) | Position: \(currentPosition) | Box Size: \(boxSize)")*/
            
            let detectedBall = filteredResults.first

            if let box = detectedBall?.boundingBox {
                let currentPosition = CGPoint(
                    x: (box.minX + box.maxX) / 2,
                    y: (box.minY + box.maxY) / 2
                )

                let boxSize = box.width * box.height  // Compute bounding box size

                self.allTrackedPoints.append((currentPosition, frameCounter))

                
                // ✅ Step 1: Identify the leftmost point before movement switches rightward
                if let previous = self.previousPosition {
                                let deltaX = currentPosition.x - previous.x
                                let isMovingRight = deltaX > 0

                    if !self.smashPointDetected {
                        // 🔹 Find the leftmost candidate point before movement switches rightward
                        let leftmostCandidate = self.allTrackedPoints.min(by: { $0.0.x < $1.0.x })

                        if let leftmost = leftmostCandidate {
                            // 🔹 Get all points that occur AFTER the candidate
                            let candidateIndex = self.allTrackedPoints.firstIndex(where: { $0.0 == leftmost.0 }) ?? 0
                            let laterPoints = self.allTrackedPoints.suffix(from: candidateIndex + 1)

                            // 🔹 Count how many of these points are **further left** than the candidate
                            let furtherLeftCount = laterPoints.filter { $0.0.x < leftmost.0.x }.count

                            // ✅ If 3 or more points after the candidate are further left, it's **not** the inflection point
                            if isMovingRight && furtherLeftCount < 3 {
                                self.smashPointDetected = true
                                self.smashPoint = leftmost.0
                                self.trackedPoints.append(leftmost)
                                
                                // ✅ Explicitly log the detected smash point
                                                    print("🔥 Smash Point Detected! Frame \(leftmost.1) | Position: \(leftmost.0) | Box Size: \(boxSize)")
                            }
                        }
                    }
                            }

                // ✅ Step 2: Continue tracking after the inflection point is detected
                if self.smashPointDetected {
                    if let lastTracked = self.trackedPoints.last, lastTracked.0 == currentPosition {
                           return  // 🚨 Skip duplicate frames (same location as last)
                       }
                    print("🟢 Frame \(frameCounter) | Position: \(currentPosition) | Box Size: \(boxSize)")
                    self.trackedPoints.append((currentPosition, frameCounter))
                }

                self.previousPosition = currentPosition
                completion(self.allTrackedPoints, self.trackedPoints)
            } else {
                completion([], [])
            }
        }

        request.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Error performing Vision request: \(error.localizedDescription)")
        }
    }
}

struct VideoPlayerView: UIViewControllerRepresentable {
    let videoURL: URL

    func makeUIViewController(context: Context) -> UIViewController {
        configureAudioSession()
        return OverlayVideoPlayerController(videoURL: videoURL)
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
}

class OverlayVideoPlayerController: UIViewController {
    
    @AppStorage("homeRunDistance") private var homeRunDistance: Int = 180  // Default to Little League
    private var lastValidLaunchAngle: CGFloat = 0.0
    private let videoURL: URL
    private var player: AVPlayer!
    private var videoOutput: AVPlayerItemVideoOutput!
    private var boundingBoxLayers: [CALayer] = []
    private var parabolaLayer: CAShapeLayer!
    private var heightOffsetLine: CAShapeLayer!  // 🔹 New layer for the horizontal reference line
    private var launchAngleLogged = false
    
    private let modelHandler = ModelHandler()
    private let conversionFactor: CGFloat = 6.0  // Feet per pixel
    private let frameRate: CGFloat = 240.0  // Frames per second
    private let mphConversionFactor: CGFloat = 0.681818  // 1 ft/s = 0.681818 mph
    private var frameCounter = 0
    
    private var finalSpeed: CGFloat = 0.0
    private var finalLaunchAngle: CGFloat = 0.0
    private var finalDistance: CGFloat = 0.0
    
    private var statsLabel: UILabel!
    private var dingerLabel: UILabel! //  Declare dingerLabel
    private var dingerFrameCounter = 0 // Frame counter for "DINGER" display
    private var homeRunCounterLabel: UILabel!  // Declare home run counter label
    
    private var homeRunCount = 0  // 🏆 Running tally of home runs
    
    private var lastDetectionFrame: Int? = nil
    private let detectionTimeoutFrames = 60  // Adjust as needed (60 = 1 second at 60 FPS)
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStatsOverlay()
        setupVideoPlayer()
        setupParabolaLayer()
        setupStopButton()  // ✅ Ensure button is added last so it appears on top
    }
    
    @objc private func handleExitToHome() {
        print("🎬 Stopping video and exiting to home screen.")
        
        // ✅ Stop video playback and reset everything
        player?.pause()
        player = nil
        dismiss(animated: true)
    }
    
    @objc private func handleStopButtonPress() {
        print("🛑 Stop button pressed. Ending session...")
        
        // ✅ Stop video playback
        player?.pause()
        player = nil
        
        AudioManager.shared.restartBackgroundMusic()
        
        // ✅ Stop tracking
        detectionTimeout?.invalidate()
        detectionTimeout = nil
        modelHandler.previousPosition = nil
        modelHandler.trackedPoints.removeAll()
        modelHandler.allTrackedPoints.removeAll()
        
        // ✅ Remove UI overlays
        DispatchQueue.main.async {
            self.boundingBoxLayers.forEach { $0.removeFromSuperlayer() }
            self.boundingBoxLayers.removeAll()
            self.parabolaLayer.path = nil
            self.statsLabel.isHidden = true
            self.homeRunCounterLabel.isHidden = true
        }
        
        // ✅ Calculate session stats
        let totalHits = storedPitchData.count
        let totalHomeRuns = homeRunCount
        let longestDistance = storedPitchData.map { $0.distance }.max() ?? 0
        let hardestExitVelocity = storedPitchData.map { $0.speed }.max() ?? 0
        let avgDistance = storedPitchData.map { $0.distance }.reduce(0, +) / CGFloat(max(1, storedPitchData.count))
        let avgExitVelocity = storedPitchData.map { $0.speed }.reduce(0, +) / CGFloat(max(1, storedPitchData.count))
        
        // ✅ Show Summary Screen
        DispatchQueue.main.async {
            let summaryView = SummaryView(
                totalHits: totalHits,
                totalHomeRuns: totalHomeRuns,
                longestDistance: longestDistance,
                hardestExitVelocity: hardestExitVelocity,
                avgDistance: avgDistance,
                avgExitVelocity: avgExitVelocity
            )
            
            let controller = UIHostingController(rootView: summaryView)
            controller.modalPresentationStyle = .fullScreen  // ✅ Required for dismiss to work
            self.present(controller, animated: true)
        }
    }
    
    private func setupStopButton() {
        let stopButton = UIButton(type: .system)
            stopButton.setTitle("Stop", for: .normal)
            stopButton.setTitleColor(.white, for: .normal)
            stopButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            stopButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            stopButton.layer.cornerRadius = 10
            stopButton.layer.masksToBounds = true
        // Ensure stop button is properly layered on top
        stopButton.layer.zPosition = 10  // ✅ Ensures button is above other UI elements

        // Stop button inside SwiftUI ZStack (wrapped in UIHostingController)
        let stopButtonView = UIHostingController(rootView:
            ZStack {
                VStack {
                    Spacer()  // Push to bottom
                    HStack {
                        Button(action: {
                            self.handleStopButtonPress()
                        }) {
                            Text("STOP")
                                .font(.custom("Geared Slab", size: 13)) // ✅ Uses your custom font
                                .foregroundColor(.white)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 15)
                                .background(Color.red)
                                .cornerRadius(90)
                        }
                        .padding(.leading, 39)  // ✅ Customizable padding from the left
                        .padding(.bottom, 8)  // ✅ Customizable bottom padding
                        .zIndex(1)  // ✅ Ensures it remains clickable
                        Spacer()
                    }
                }
            }
        )

        // ✅ Explicitly bring the stop button to the front
        DispatchQueue.main.async {
            self.view.bringSubviewToFront(stopButtonView.view)
        }
            
            stopButtonView.view.backgroundColor = .clear // Prevents unwanted backgrounds
            stopButtonView.view.frame = view.bounds
            addChild(stopButtonView)
            view.addSubview(stopButtonView.view)
            stopButtonView.didMove(toParent: self)
        }
  
    private func resetTracking() {
        lastValidLaunchAngle = 0.0
        launchAngleLogged = false
        finalResultsLogged = false

        speedValues.removeAll()
        launchAngleValues.removeAll()
        distanceValues.removeAll()
        estimatedBallHeight = nil

        DispatchQueue.main.async {
            self.boundingBoxLayers.forEach { $0.removeFromSuperlayer() }
            self.boundingBoxLayers.removeAll()
        }

        parabolaLayer.path = nil
        parabolaLayer.opacity = 1.0
        parabolaLayer.isHidden = false

        // ✅ **Reset Model Tracking Variables**
        modelHandler.previousPosition = nil
        modelHandler.smashPointDetected = false
        modelHandler.smashPoint = nil
        modelHandler.trackedPoints.removeAll()
        modelHandler.allTrackedPoints.removeAll()  // ✅ Reset **all** pitch data
        modelHandler.currentDirection = 0
    }

    private func shouldDetectNextPitch(_ points: [(CGPoint, Int)]) -> Bool {
        guard let lastPoint = points.last else { return false }

        let (currentPosition, _) = lastPoint

        if let previous = modelHandler.getSmashPoint() {
            let deltaX = currentPosition.x - previous.0.x
            let isNewPitch = deltaX > 0 && currentPosition.x > 0.1

            if isNewPitch {
                DispatchQueue.main.async {
                    self.statsLabel.isHidden = true  // ✅ Hide only when a new pitch is detected
                }
                hasResetForNextPitch = false  // ✅ Allow tracking reset for the next pitch
            }
            return isNewPitch
        }

        return true
    }

    private func setupStatsOverlay() {
        statsLabel = UILabel()
        statsLabel.textAlignment = .center
        statsLabel.textColor = .white
        statsLabel.backgroundColor = UIColor.gray.withAlphaComponent(0.3)  // 🔹 Matching background
        statsLabel.font = UIFont(name: "Geared Slab", size: 28) ?? UIFont.systemFont(ofSize: 28, weight: .bold)
        statsLabel.layer.cornerRadius = 10
        statsLabel.layer.masksToBounds = true
        statsLabel.isHidden = true
        view.addSubview(statsLabel)

        dingerLabel = UILabel()
        dingerLabel.text = "Dinger ! "
        dingerLabel.textAlignment = .center
        dingerLabel.textColor =  UIColor(named: "Baseball")
        dingerLabel.font = UIFont(name: "FenwayParkJF", size: 50) ?? UIFont.systemFont(ofSize: 18, weight: .bold)
        dingerLabel.isHidden = true
        view.addSubview(dingerLabel)

        // 🏆 Home Run Counter Label (Top Center)
        homeRunCounterLabel = UILabel()
        homeRunCounterLabel.text = "HRs: 0" // Default text
        homeRunCounterLabel.textAlignment = .center
        homeRunCounterLabel.textColor = .white
        homeRunCounterLabel.font = UIFont(name: "Geared Slab", size: 35) ?? UIFont.systemFont(ofSize: 35, weight: .bold);     homeRunCounterLabel.layer.cornerRadius = 10
        homeRunCounterLabel.layer.masksToBounds = true
        homeRunCounterLabel.isHidden = true  // ✅ Hidden initially
        view.addSubview(homeRunCounterLabel)

        statsLabel.translatesAutoresizingMaskIntoConstraints = false
        dingerLabel.translatesAutoresizingMaskIntoConstraints = false
        homeRunCounterLabel.translatesAutoresizingMaskIntoConstraints = false  // Enable auto-layout

        NSLayoutConstraint.activate([
            statsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statsLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30),
            statsLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.9),
            statsLabel.heightAnchor.constraint(equalToConstant: 40),

            dingerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dingerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            // 🏆 Position Home Run Counter in the **Top Center**
            homeRunCounterLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            homeRunCounterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),  // 🔹 Center it horizontally
            homeRunCounterLabel.widthAnchor.constraint(equalToConstant: 180),
            homeRunCounterLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private var hasResetForNextPitch = false  // ✅ Prevents multiple resets

    private func checkForTimeout() {
        guard let lastFrame = lastDetectionFrame else { return } // ✅ Skip if no detections yet

        if frameCounter - lastFrame > detectionTimeoutFrames, !hasResetForNextPitch {
            print("⏳ Timeout reached! Resetting tracking...")
            resetTracking()
            hasResetForNextPitch = true  // ✅ Ensures reset happens only once
        }
    }
    
    private func updateStatsOverlay() {
        let roundedSpeed = Int(finalSpeed.rounded())  // Round to whole number
        let roundedLaunchAngle = Int(finalLaunchAngle.rounded())
        let roundedDistance = Int(finalDistance.rounded())
        
        let formattedText = "Speed: \(roundedSpeed) mph | Launch Angle: \(roundedLaunchAngle)° | Distance: \(roundedDistance) ft"
        
        statsLabel.text = formattedText
        
        DispatchQueue.main.async {
                self.statsLabel.isHidden = false  // ✅ Make sure it reappears
                self.view.bringSubviewToFront(self.statsLabel)
            }
    }
    
    private func setupVideoPlayer() {
        player = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.videoGravity = .resizeAspect;
        playerViewController.showsPlaybackControls = false
        
        videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
        player.currentItem?.add(videoOutput)
        
        addChild(playerViewController)
        view.addSubview(playerViewController.view)
        playerViewController.view.frame = view.bounds
        playerViewController.didMove(toParent: self)
        
        player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 60), queue: .main) { time in
            self.frameCounter += 1
            guard let pixelBuffer = self.videoOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else { return }
            
            self.modelHandler.detectSportsBall(in: pixelBuffer, frameCounter: self.frameCounter) { allTrackedPoints, trackedPoints in
                DispatchQueue.main.async {
                    if !trackedPoints.isEmpty {
                        self.lastDetectionFrame = self.frameCounter  // ✅ Update last detected frame
                    }
                    
                    self.updateBoundingBoxes(pitchPoints: allTrackedPoints, hitPoints: trackedPoints)

                    if self.shouldDetectNextPitch(trackedPoints) {
                        self.logTrackedPoints(trackedPoints)
                        self.updateParabola(with: trackedPoints)
                    }

                    self.checkForTimeout()  // ✅ Check if a reset is needed
                }
            }
        }
        player.play()
    }
    
    private var speedValues: [CGFloat] = []
    private var launchAngleValues: [CGFloat] = []
    private var distanceValues: [CGFloat] = []
    private var finalResultsLogged = false
    private var detectionTimeout: Timer? // Timer to detect when tracking has stopped
    private var estimatedBallHeight: CGFloat? // Store estimated ball height for final logging
    
    private func logTrackedPoints(_ points: [(CGPoint, Int)]) {
        guard let lastPoint = points.last else { return }

        let (lastPosition, lastFrame) = lastPoint

        if finalResultsLogged {
            print("🔄 Clearing old tracking data before new pitch...")
            resetTracking() // Clear all tracked points
        }

        
        if let (firstSpeedCalcPoint, firstSpeedCalcFrame) = modelHandler.getFirstSpeedCalcPoint(), lastFrame > firstSpeedCalcFrame {
            
            if lastPosition == firstSpeedCalcPoint {
                print("⚠️ Skipping duplicate frame (no movement detected).")
                return
            }
            
            let deltaX = lastPosition.x - firstSpeedCalcPoint.x
            let deltaY = lastPosition.y - firstSpeedCalcPoint.y
            let distance = sqrt(deltaX * deltaX + deltaY * deltaY)

            let frameDifference = lastFrame - firstSpeedCalcFrame
            let speedFtPerFrame = (distance * conversionFactor) / CGFloat(frameDifference)
            let speedFtPerSec = speedFtPerFrame * frameRate
            let speedMph = speedFtPerSec * mphConversionFactor

            if !speedValues.contains(speedMph) {
                speedValues.append(speedMph)
            }
            
            let stablePoints = points.map { $0.0 }
            
            if stablePoints.count >= 3, let coefficients = fitParabola(to: stablePoints) {
                let finalX = stablePoints.last!.x
                let slope = (2 * coefficients.a * finalX + coefficients.b)
                let correctedSlope = slope * 0.7  // Perspective correction factor
                let newLaunchAngle = atan(correctedSlope) * 180 / .pi
                
                if launchAngleLogged {
                    let deltaAngle = abs(newLaunchAngle - lastValidLaunchAngle)
                    if deltaAngle <= 40 {  // Ensure we exclude unstable launch angles
                        lastValidLaunchAngle = newLaunchAngle
                        launchAngleValues.append(newLaunchAngle) // Store launch angle
                    }
                } else {
                    lastValidLaunchAngle = newLaunchAngle
                    launchAngleLogged = true
                    launchAngleValues.append(newLaunchAngle)
                }

                // ✅ More accurate distance calculation (preserved from old code)
                let speedFtPerSec = speedMph * 1.46667
                let launchAngleRad = newLaunchAngle * .pi / 180
                let gravity: CGFloat = 32.174
                let initialHeight: CGFloat = 4

                let speedSquared = pow(Double(speedFtPerSec), 2)
                let sinTwoTheta = sin(2 * Double(launchAngleRad))
                let sinThetaSquared = pow(sin(Double(launchAngleRad)), 2)
                let heightFactor = sqrt(1 + (2 * Double(gravity) * Double(initialHeight)) / (speedSquared * sinThetaSquared))
                let estimatedDistance = CGFloat((speedSquared * sinTwoTheta / Double(gravity)) * heightFactor)

                distanceValues.append(estimatedDistance) // Store estimated distance
            }

            // ✅ Keep everything consistent with how you log final results
            resetDetectionTimeout()
        }
    }
    
    // 🔹 This function starts or resets the timeout when detections stop
    private func resetDetectionTimeout() {
        detectionTimeout?.invalidate() // Cancel any existing timer
        detectionTimeout = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.logFinalResults()
        }
    }
    
    struct HomeRunCelebrationView: UIViewRepresentable {
        func makeUIView(context: Context) -> UIImageView {
            let imageView = UIImageView()

            if let gifURL = Bundle.main.url(forResource: "HomeRunCelebration", withExtension: "gif"),
               let gifData = try? Data(contentsOf: gifURL),
               let gifImage = UIImage.gif(data: gifData) {
                imageView.image = gifImage
                imageView.contentMode = .scaleAspectFit
                imageView.clipsToBounds = true
            } else {
                print("🚨 GIF not found in bundle!")
            }


            return imageView
        }

        func updateUIView(_ uiView: UIImageView, context: Context) {}
    }
    
    // 🔹 Compute and print final averages when detections have stopped
    private var storedPitchData: [(speed: CGFloat, angle: CGFloat, distance: CGFloat)] = []

    private func showHomeRunCelebration() {
        DispatchQueue.main.async {
            let gifView = HomeRunCelebrationView()
            let hostingController = UIHostingController(rootView: gifView)
            hostingController.view.backgroundColor = .clear
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let gifWidth: CGFloat = (screenWidth/500)
            let gifHeight: CGFloat = (screenWidth/500)

            // ✅ Manually set the frame size
            hostingController.view.frame = CGRect(
                x: (screenWidth - gifWidth) / 2,
                y: screenHeight * 0.5,
                width: gifWidth,
                height: gifHeight
            )

            self.view.addSubview(hostingController.view)

            // ✅ Remove the GIF after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                hostingController.view.removeFromSuperview()
            }
        }
    }
    
    private func logFinalResults() {
        guard !finalResultsLogged, !speedValues.isEmpty, !launchAngleValues.isEmpty, !distanceValues.isEmpty else {
            print("🚨 No valid results to log or already logged.")
            return
        }

        // ✅ Remove zero-speed values before averaging
          let validSpeeds = speedValues.filter { $0 > 0 }

          guard !validSpeeds.isEmpty, !launchAngleValues.isEmpty, !distanceValues.isEmpty else {
              print("🚨 No valid results to log.")
              return
          }
        
        finalResultsLogged = true

        let trimmedSpeedValues = Array(speedValues.prefix(3))
            let trimmedLaunchAngleValues = Array(launchAngleValues.prefix(3))
            let trimmedDistanceValues = Array(distanceValues.prefix(3))

        let avgSpeed = trimmedSpeedValues.reduce(0, +) / CGFloat(trimmedSpeedValues.count)
        let avgLaunchAngle = trimmedLaunchAngleValues.reduce(0, +) / CGFloat(trimmedLaunchAngleValues.count)
        let avgDistance = trimmedDistanceValues.reduce(0, +) / CGFloat(trimmedDistanceValues.count)

        finalSpeed = avgSpeed
        finalLaunchAngle = avgLaunchAngle
        finalDistance = avgDistance

        print("📊 FINAL RESULTS:")
        print("Launch Angles = \(launchAngleValues)")
        print("Average Angle = \(avgLaunchAngle.rounded())")
        print("Speeds = \(speedValues)")
        print("Average Speed = \(avgSpeed.rounded()) mph")
        print ("Average Distance = \(avgDistance.rounded()) ft")
        
        if avgDistance > CGFloat(homeRunDistance) {  // ✅ Uses selected home run distance
            homeRunCount += 1
             
            DispatchQueue.main.async {
                    self.homeRunCounterLabel.text = "HRs: \(self.homeRunCount)"
                    self.homeRunCounterLabel.isHidden = false  // ✅ Make sure it appears after the first HR
                    self.view.bringSubviewToFront(self.homeRunCounterLabel)
                }

            DispatchQueue.main.async {
                self.dingerLabel.isHidden = false  // ✅ Show "DINGER"
                    AudioManager.shared.playHomeRun()
                self.view.bringSubviewToFront(self.dingerLabel)
                self.showHomeRunCelebration()
            }

            // Hide "DINGER" after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(2.0)) {
                       self.dingerLabel.isHidden = true
                   }
               }
    
        storedPitchData.append((speed: avgSpeed, angle: avgLaunchAngle, distance: avgDistance))

        DispatchQueue.main.async {
            self.updateStatsOverlay()
            self.updateParabola(with: self.modelHandler.trackedPoints) // ✅ Ensure parabola is drawn

            // 🧹 **Clear all detection data immediately after visualization**
            self.resetTracking()
            
            // ✅ Metrics will still be visible for 4 seconds, but tracking data is already reset
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(4.0)) {
                self.statsLabel.isHidden = true  // ✅ Hide only the visualization
                self.resetTracking()  // ✅ Ensures the next pitch starts clean
            }
        }
    }

    private func removeOutliers(from points: [CGPoint]) -> [CGPoint] {
           guard points.count >= 3 else { return points } // Not enough points to detect outliers

           let meanY = points.map { $0.y }.reduce(0, +) / CGFloat(points.count)
           let meanX = points.map { $0.x }.reduce(0, +) / CGFloat(points.count)

           let stdDevY = sqrt(points.map { pow($0.y - meanY, 2) }.reduce(0, +) / CGFloat(points.count))
           let stdDevX = sqrt(points.map { pow($0.x - meanX, 2) }.reduce(0, +) / CGFloat(points.count))

        let zScoreThreshold: CGFloat = 2.0 // Adjust for stricter or looser filtering

           let filteredPoints = points.filter { point in
               let zScoreY = abs(point.y - meanY) / stdDevY
               let zScoreX = abs(point.x - meanX) / stdDevX

               // Accept points within a reasonable range
               return zScoreY < zScoreThreshold && zScoreX < zScoreThreshold
           }
   //       print("🛑 Removed \(points.count - filteredPoints.count) outlier(s)")
           return filteredPoints
       }
    
    private func setupParabolaLayer() {
        parabolaLayer = CAShapeLayer()
        parabolaLayer.strokeColor = UIColor.systemBlue.cgColor
        parabolaLayer.lineWidth = 5
        parabolaLayer.fillColor = UIColor.clear.cgColor
        parabolaLayer.opacity = 1.0  // Ensure opacity is set to 1
        parabolaLayer.isHidden = false // Ensure it's not hidden
        view.layer.addSublayer(parabolaLayer)
    }
    
    private func updateParabola(with points: [(CGPoint, Int)]) {
        guard points.count >= 3 else {
            return
        }
            
        let path = UIBezierPath()
        let videoFrame = view.bounds
        
        var convertedPoints = points.map { (point, _) in
            CGPoint(
                x: point.x * videoFrame.width,
                y: (1 - point.y) * videoFrame.height
            )
        }

        if let (inflectionPoint, _) = modelHandler.getSmashPoint() {
            let convertedInflection = CGPoint(
                x: inflectionPoint.x * videoFrame.width,
                y: (1 - inflectionPoint.y) * videoFrame.height
            )

            if !convertedPoints.contains(convertedInflection) {
                convertedPoints.insert(convertedInflection, at: 0)
            }
        }
        let filteredPoints = removeOutliers(from: convertedPoints)
        if let coefficients = fitParabola(to: convertedPoints) {
            path.move(to: convertedPoints.first!)
            for x in stride(from: convertedPoints.first!.x, to: convertedPoints.last!.x, by: 1) {
                let y = coefficients.a * x * x + coefficients.b * x + coefficients.c
                path.addLine(to: CGPoint(x: x, y: y))
            }
        } else {
            print("❌ Parabola fitting failed.")
        }

/*
        parabolaLayer.path = path.cgPath
        parabolaLayer.strokeColor = UIColor.systemYellow.cgColor
        parabolaLayer.fillColor = UIColor.clear.cgColor
        parabolaLayer.lineWidth = 5

        // 🔥 Glow Effect
        parabolaLayer.shadowColor = UIColor.yellow.cgColor
        parabolaLayer.shadowRadius = 8
        parabolaLayer.shadowOpacity = 0.8
*/
    }
     
    // ✅ Keep `private` only at the top level
    private func updateBoundingBoxes(pitchPoints: [(CGPoint, Int)], hitPoints: [(CGPoint, Int)]) {
        // ✅ **Clear previous layers** before drawing new points
        boundingBoxLayers.forEach { $0.removeFromSuperlayer() }
        boundingBoxLayers.removeAll()
        
        let videoFrame = view.bounds
        
        // ✅ Retrieve the **First Speed Calculation Point** from the ModelHandler
            guard let firstSpeedCalc = modelHandler.getFirstSpeedCalcPoint() else {
                return
            }

        // 🏁 Extract first **3 points** used for speed calculation
           let allSpeedCalcPoints = hitPoints.drop { $0.1 < firstSpeedCalc.1 }
           let speedCalculationPoints = allSpeedCalcPoints.prefix(3) // First 3 points only

           // 🔴 Draw **First Speed Calc & Two Additional Points** in Red
           for (point, _) in speedCalculationPoints {
               let redLayer = CALayer()
               redLayer.frame = CGRect(
                   x: point.x * videoFrame.width - 5,
                   y: (1 - point.y) * videoFrame.height - 5,
                   width: 7,
                   height: 7
               )
               redLayer.backgroundColor = UIColor.systemRed.cgColor
               redLayer.cornerRadius = 5
               view.layer.addSublayer(redLayer)
               boundingBoxLayers.append(redLayer)
           }
       
        /*
        // ✅ **Draw blue dots (pitch tracking) in real-time**
        for (point, _) in pitchPoints {
            let pitchLayer = CALayer()
            pitchLayer.frame = CGRect(
                x: point.x * videoFrame.width - 5,
                y: (1 - point.y) * videoFrame.height - 5,
                width: 7,
                height: 7
            )
            pitchLayer.backgroundColor = UIColor.systemBlue.cgColor
            pitchLayer.cornerRadius = 5
            view.layer.addSublayer(pitchLayer)
            boundingBoxLayers.append(pitchLayer)
        
        } */
         
            
        // 🟡 Draw **hit tracking** points in yellow
        for (point, _) in hitPoints {
            let hitLayer = CALayer()
            hitLayer.frame = CGRect(
                x: point.x * videoFrame.width - 5,
                y: (1 - point.y) * videoFrame.height - 5,
                width: 7,
                height: 7
            )
            hitLayer.backgroundColor = UIColor.systemYellow.cgColor
            hitLayer.cornerRadius = 5
            view.layer.addSublayer(hitLayer)
            boundingBoxLayers.append(hitLayer)
        }
          
    }
}

func fitParabola(to points: [CGPoint]) -> (a: CGFloat, b: CGFloat, c: CGFloat)? {
    guard points.count >= 3 else { return nil }

    var sumX: CGFloat = 0, sumY: CGFloat = 0, sumX2: CGFloat = 0
    var sumX3: CGFloat = 0, sumX4: CGFloat = 0, sumXY: CGFloat = 0
    var sumX2Y: CGFloat = 0

    for point in points {
        let x = point.x
        let y = point.y
        sumX += x
        sumY += y
        sumX2 += x * x
        sumX3 += x * x * x
        sumX4 += x * x * x * x
        sumXY += x * y
        sumX2Y += x * x * y
    }

    let n = CGFloat(points.count)
    let matrix = [
        [sumX4, sumX3, sumX2],
        [sumX3, sumX2, sumX],
        [sumX2, sumX, n]
    ]

    let rhs = [sumX2Y, sumXY, sumY]

    if let solution = solveLinearSystem(matrix, rhs) {
        return (a: solution[0], b: solution[1], c: solution[2])
    }

    return nil
}

func solveLinearSystem(_ matrix: [[CGFloat]], _ rhs: [CGFloat]) -> [CGFloat]? {
    var mat = matrix
    var result = rhs

    for i in 0..<mat.count {
        let pivot = mat[i][i]
        guard pivot != 0 else { return nil }

        for j in i..<mat[i].count {
            mat[i][j] /= pivot
        }
        result[i] /= pivot

        for k in 0..<mat.count where k != i {
            let factor = mat[k][i]
            for j in i..<mat[k].count {
                mat[k][j] -= factor * mat[i][j]
            }
            result[k] -= factor * result[i]
        }
    }

    return result
}

// ✅ Helper function to remove duplicate tracking points
extension Array where Element == CGPoint {
    func removingDuplicates() -> [CGPoint] {
        var uniquePoints: [CGPoint] = []
        for point in self {
            if !uniquePoints.contains(where: { $0.x == point.x && $0.y == point.y }) {
                uniquePoints.append(point)
            }
        }
        return uniquePoints
    }
}

import SwiftUI

struct SummaryView: View {
    let totalHits: Int
    let totalHomeRuns: Int
    let longestDistance: CGFloat
    let hardestExitVelocity: CGFloat
    let avgDistance: CGFloat
    let avgExitVelocity: CGFloat

    @Environment(\.presentationMode) var presentationMode  // ✅ Allows dismissing the view

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 🏟️ **Full-Screen Background Image**
                Image("Summary Screen")
                    .resizable()
                    .scaledToFill()  // Prevents cropping
                    .ignoresSafeArea()
                    
              
                // 🎯 **Custom Positions for Outputs**
                VStack {
                    Spacer()
                    
                    // Each output has its own manually adjustable position
                    statValue("\(totalHomeRuns)", x: 0.31, y: 0.63, width: geometry.size.width, height: geometry.size.height)  // Home Runs Box
                    statValue("\(totalHits)", x: 0.31, y: 0.670, width: geometry.size.width, height: geometry.size.height)  // Hits Box
                    statValue("\(Int(longestDistance.rounded()))", x: 0.51, y: 0.30, width: geometry.size.width, height: geometry.size.height)  // Longest Box
                    statValue("\(Int(hardestExitVelocity.rounded()))", x: 0.51, y: 0.335, width: geometry.size.width, height: geometry.size.height)  // Hardest Box
                    statValue("\(Int(avgDistance.rounded()))", x: 0.7, y: -0.034, width: geometry.size.width, height: geometry.size.height)  // Avg Distance Box
                    statValue("\(Int(avgExitVelocity.rounded()))", x: 0.7, y:0.0, width: geometry.size.width, height: geometry.size.height)  // Avg Speed Box
                }

                // ❌ **Exit Button Properly Below Scoreboard**
                Button(action: {
                    if let rootVC = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap({ $0.windows })
                        .first(where: { $0.isKeyWindow })?.rootViewController {
                        rootVC.dismiss(animated: true)
                    }
                }) {
                    Text("EXIT")
                        .font(.custom("Geared Slab", size: 30)) // ✅ Uses your custom font
                        .padding(.vertical, 10)
                        .padding(.horizontal, 40)
                        .background(Color("DarkBlue"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .position(x: geometry.size.width * 0.06, y: geometry.size.height * 0.15)  // ✅ Below the scoreboard
            }
        }
    }

    // 🎯 **Custom Placement for Stat Values**
    func statValue(_ value: String, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> some View {
        Text(value)
            .font(.system(size: width * 0.035, weight: .bold))  // ✅ Responsive font size
            .foregroundColor(.white)
            .position(x: width * x, y: height * y)  // ✅ Manually set each stat's position
    }
}

// 🔄 **Enable Preview in Xcode (Landscape Mode)**
struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView(
            totalHits: 10,
            totalHomeRuns: 4,
            longestDistance: 315,
            hardestExitVelocity: 78,
            avgDistance: 156,
            avgExitVelocity: 46
        )
        .previewInterfaceOrientation(.landscapeLeft)  // ✅ Rotates Preview in Xcode
    }
}



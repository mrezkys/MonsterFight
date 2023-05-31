//
//  MonsterFightApp.swift
//  MonsterFight
//
//  Created by Muhammad Rezky on 29/05/23.
//

import SwiftUI


@main
struct MonsterFightApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
//
////
////  ContentView.swift
////  MonsterFight
////
////  Created by Muhammad Rezky on 29/05/23.
////
//import SwiftUI
//import AVFoundation
//import Vision
//
//
//
//struct ContentView: View {
//    @State private var isCameraAuthorized = false
//    @State private var isShowingCamera = false
//    @State private var currentPoses: [VNHumanBodyPoseObservation] = []
//    
//    var body: some View {
//        VStack {
//            if isCameraAuthorized {
//                CameraView(isVisible: $isShowingCamera, poses: $currentPoses)
//            } else {
//                Text("Camera access denied.")
//                    .font(.headline)
//                    .foregroundColor(.red)
//            }
//        }
//        .onAppear {
//            checkCameraAuthorization()
//        }
//    }
//    
//    func checkCameraAuthorization() {
//        AVCaptureDevice.requestAccess(for: .video) { granted in
//            DispatchQueue.main.async {
//                isCameraAuthorized = granted
//            }
//        }
//    }
//}
//
//struct CameraView: View {
//    @Binding var isVisible: Bool
//    @Binding var poses: [VNHumanBodyPoseObservation]
//    
//    var body: some View {
//        ZStack {
//            CameraPreview(isVisible: $isVisible, poses: $poses)
//                .edgesIgnoringSafeArea(.all)
//                .ignoresSafeArea(.all)
//            
//            ForEach(poses.indices, id: \.self) { index in
//                PoseOverlayView(pose: poses[index])
//            }
//        }
//        .onAppear {
//            isVisible = true
//        }
//        .onDisappear {
//            isVisible = false
//        }
//    }
//}
//struct PoseOverlayView: View {
//    var pose: VNHumanBodyPoseObservation
//    
//    // Define the joint segments to connect
//    let jointSegments: [JointSegment] = [
//        JointSegment(jointA: .neck, jointB: .nose),
//        JointSegment(jointA: .leftHip, jointB: .leftShoulder),
//        JointSegment(jointA: .leftShoulder, jointB: .leftElbow),
//        JointSegment(jointA: .leftElbow, jointB: .leftWrist),
//        JointSegment(jointA: .leftHip, jointB: .leftKnee),
//        JointSegment(jointA: .leftKnee, jointB: .leftAnkle),
//        JointSegment(jointA: .rightHip, jointB: .rightShoulder),
//        JointSegment(jointA: .rightShoulder, jointB: .rightElbow),
//        JointSegment(jointA: .rightElbow, jointB: .rightWrist),
//        JointSegment(jointA: .rightHip, jointB: .rightKnee),
//        JointSegment(jointA: .rightKnee, jointB: .rightAnkle),
//        JointSegment(jointA: .leftShoulder, jointB: .rightShoulder),
//        JointSegment(jointA: .leftHip, jointB: .rightHip)
//    ]
//    
//    @State private var showBone = false
//    
//    var body: some View {
//        let screenSize = UIScreen.main.bounds
//        
//        ZStack {
//            
//            ForEach(jointSegments, id: \.self) { segment in
//                if let jointA = try? pose.recognizedPoint(segment.jointA),
//                   let jointB = try? pose.recognizedPoint(segment.jointB),
//                   jointA.confidence > 0, jointB.confidence > 0 {
//                    Path { path in
//                        let pointA = transformPoint(jointA.location, screenSize)
//                        let pointB = transformPoint(jointB.location, screenSize)
//                        path.move(to: pointA)
//                        path.addLine(to: pointB)
//                    }
//                    .stroke(Color.red, lineWidth: 2)
//                    
//                }
//            }
//        }
//        .ignoresSafeArea(.all)
//    }
//    
//    
//    func transformPoint(_ point: CGPoint, _ screenSize: CGRect) -> CGPoint {
//        let transformedX = point.x * screenSize.width
//        let transformedY = (1 - point.y) * screenSize.height
//        return CGPoint(x: transformedX, y: transformedY)
//    }
//}
//
//struct JointSegment: Hashable {
//    let jointA: VNHumanBodyPoseObservation.JointName
//    let jointB: VNHumanBodyPoseObservation.JointName
//}
//
//
//
//struct CameraPreview: View {
//    @Binding var isVisible: Bool
//    @Binding var poses: [VNHumanBodyPoseObservation]
//    
//    var body: some View {
//        if isVisible {
//            CameraPreviewView(poses: $poses)
//                .edgesIgnoringSafeArea(.all)
//                .ignoresSafeArea(.all)
//        }
//    }
//}
//
//struct CameraPreviewView: UIViewControllerRepresentable {
//    @Binding var poses: [VNHumanBodyPoseObservation]
//    
//    func makeUIViewController(context: Context) -> CameraViewController {
//        let controller = CameraViewController()
//        controller.delegate = context.coordinator
//        return controller
//    }
//    
//    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
//    
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//    
//    class Coordinator: NSObject, CameraViewControllerDelegate {
//        private var parent: CameraPreviewView
//        
//        init(_ parent: CameraPreviewView) {
//            self.parent = parent
//        }
//        
//        func didCaptureFrame(_ frame: CMSampleBuffer) {
//            guard let imageBuffer = CMSampleBufferGetImageBuffer(frame) else { return }
//            
//            let request = VNDetectHumanBodyPoseRequest { (request, error) in
//                guard let observations = request.results as? [VNHumanBodyPoseObservation] else {
//                    self.parent.poses = []
//                    return
//                }
//                
//                self.parent.poses = observations
//            }
//            
//            let handler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .down, options: [:])
//            do {
//                try handler.perform([request])
//            } catch {
//                print("Error: \(error)")
//            }
//        }
//    }
//}
//
//protocol CameraViewControllerDelegate: AnyObject {
//    func didCaptureFrame(_ frame: CMSampleBuffer)
//}
//
//
//class CameraViewController: UIViewController {
//    private var captureSession: AVCaptureSession?
//    private var previewLayer: AVCaptureVideoPreviewLayer?
//    weak var delegate: CameraViewControllerDelegate?
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupCaptureSession()
//    }
//    
//    private func currentVideoOrientation() -> AVCaptureVideoOrientation {
//        let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
//        
//        switch orientation {
//        case .landscapeLeft:
//            return .landscapeLeft
//        case .landscapeRight:
//            return .landscapeRight
//        case .portraitUpsideDown:
//            return .portraitUpsideDown
//        default:
//            return .portrait
//        }
//    }
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        
//        if let connection = previewLayer?.connection, connection.isVideoOrientationSupported {
//            connection.videoOrientation = currentVideoOrientation()
//        }
//        
//        previewLayer?.frame = view.bounds
//    }
//    
//    private func setupCaptureSession() {
//        captureSession = AVCaptureSession()
//        guard let captureSession = captureSession else { return }
//        
//        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
//              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice)
//        else { return }
//        
//        if captureSession.canAddInput(videoInput) {
//            captureSession.addInput(videoInput)
//        } else {
//            print("Failed to add video input to the capture session.")
//            return
//        }
//        
//        let videoOutput = AVCaptureVideoDataOutput()
//        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//        if captureSession.canAddOutput(videoOutput) {
//            captureSession.addOutput(videoOutput)
//            if let connection = videoOutput.connection(with: .video),
//               connection.isVideoOrientationSupported {
//                connection.videoOrientation =
//                AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue)!
//                connection.isVideoMirrored = true
//                
//                // Inverse the landscape orientation to force the image in the upward
//                // orientation.
//                if connection.videoOrientation == .landscapeLeft {
//                    connection.videoOrientation = .landscapeRight
//                } else if connection.videoOrientation == .landscapeRight {
//                    connection.videoOrientation = .landscapeLeft
//                }
//            }
//        } else {
//            print("Failed to add video output to the capture session.")
//            return
//        }
//        
//        
//        
//        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//        previewLayer?.frame = view.bounds
//        previewLayer?.videoGravity = .resizeAspectFill
//        
//        print("view bound: ", view.bounds)
//        view.layer.addSublayer(previewLayer!)
//        
//        captureSession.startRunning()
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        captureSession?.stopRunning()
//    }
//}
//
//extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        delegate?.didCaptureFrame(sampleBuffer)
//    }
//}
////struct ContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        ContentView()
////    }
////}
//

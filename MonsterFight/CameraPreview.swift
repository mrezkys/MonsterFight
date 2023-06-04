//
//  CameraPreview.swift
//  MonsterFight
//
//  Created by Muhammad Rezky on 29/05/23.
//

import SwiftUI
import Vision


struct CameraPreview: View {
    @Binding var poses: [VNHumanBodyPoseObservation]
    
    var body: some View {
            CameraPreviewView(poses: $poses)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.all)
       
    }
}

struct CameraPreviewView: UIViewControllerRepresentable {
    @Binding var poses: [VNHumanBodyPoseObservation]
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, CameraViewControllerDelegate {
        private var parent: CameraPreviewView
        private var currentOrientation: UIDeviceOrientation = UIDevice.current.orientation
        private var latestFrame: CMSampleBuffer?
        private var initialOrientation = UIDevice.current.orientation
        
        init(_ parent: CameraPreviewView) {
            self.parent = parent
            super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
             UIDevice.current.beginGeneratingDeviceOrientationNotifications()
         }
         
         deinit {
             NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
             UIDevice.current.endGeneratingDeviceOrientationNotifications()
         }
         
         
        
        @objc private func deviceOrientationDidChange() {
                switch UIDevice.current.orientation {
                case .landscapeLeft:
                    currentOrientation = .landscapeLeft
                case .landscapeRight:
                    currentOrientation = .landscapeRight
                    
                default:
                    
                    currentOrientation = .landscapeLeft
                }
                updatePoseWithNewOrientation()
        }
        

        

        
        private func updatePoseWithNewOrientation() {
            var orientations: CGImagePropertyOrientation = .up
            if(initialOrientation == .landscapeLeft){
                switch currentOrientation {
                case .landscapeLeft:
//                    print("left")
                    orientations = .up
                case .landscapeRight:
//                    print("right")
                    orientations = .down
                default:
//                    print("def")
                    orientations = .up
                }
            } else {
                switch currentOrientation {
                case .landscapeLeft:
//                    print("else left")
                    orientations = .down
                case .landscapeRight:
//                    print("else right")
                    orientations = .up
                default:
//                    print("else def")
                    orientations = .up
                }
            }
            
            
            
            if let frame = latestFrame {
                guard let imageBuffer = CMSampleBufferGetImageBuffer(frame) else { return }
                
                let request = VNDetectHumanBodyPoseRequest { (request, error) in
                    guard let observations = request.results as? [VNHumanBodyPoseObservation] else {
                        self.parent.poses = []
                        return
                    }
                    
                    self.parent.poses = observations
                }
                
                let handler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: orientations, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    print("Error: \(error)")
                }
            }
        }
        
        func didCaptureFrame(_ frame: CMSampleBuffer) {
            latestFrame = frame
            updatePoseWithNewOrientation()
        }
        
       
    }
}


// camera view
import AVFoundation


protocol CameraViewControllerDelegate: AnyObject {
    func didCaptureFrame(_ frame: CMSampleBuffer)
}


class CameraViewController: UIViewController {
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: CameraViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
               UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        setupCaptureSession()
    }
    
    @objc private func orientationDidChange() {
            if let connection = previewLayer?.connection, connection.isVideoOrientationSupported {
                connection.videoOrientation = currentVideoOrientation()
            }
        }
    
    deinit {
            NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
    
    private func currentVideoOrientation() -> AVCaptureVideoOrientation {
       var orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
        
        switch orientation {
        case .landscapeLeft:
            return .landscapeLeft
        case .landscapeRight:
            return .landscapeRight
        default:
            return .landscapeRight
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let connection = previewLayer?.connection, connection.isVideoOrientationSupported {
            connection.videoOrientation = currentVideoOrientation()
        }
        
        previewLayer?.frame = view.bounds
    }
    
    private func setupCaptureSession() {
        captureSession = AVCaptureSession()
        guard let captureSession = captureSession else { return }
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        else { return }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            print("Failed to add video input to the capture session.")
            return
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
            if let connection = videoOutput.connection(with: .video){
                connection.videoOrientation = currentVideoOrientation()
                connection.isVideoMirrored = true

            }
        } else {
            print("Failed to add video output to the capture session.")
            return
        }
        
        
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.frame = view.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        print("view bound: ", view.bounds)
        view.layer.addSublayer(previewLayer!)
        
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession?.stopRunning()
    }
}

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        delegate?.didCaptureFrame(sampleBuffer)
    }
}


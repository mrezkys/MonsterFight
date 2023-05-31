//
//  ContentView.swift
//  MonsterFight
//
//  Created by Muhammad Rezky on 29/05/23.
//
import SwiftUI
import AVFoundation
import Vision


struct ContentView: View {
    @State private var isCameraAuthorized = false
    @State private var currentPoses: [VNHumanBodyPoseObservation] = []
    
    var body: some View {
        VStack {
            if isCameraAuthorized {
                CameraView( poses: $currentPoses)
            } else {
                Text("Camera access denied.")
                    .font(.headline)
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            print("test")
            checkCameraAuthorization()
        }
    }
    
    func checkCameraAuthorization() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                isCameraAuthorized = granted
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

//
//  PoseOverlayView.swift
//  MonsterFight
//
//  Created by Muhammad Rezky on 29/05/23.
//

import SwiftUI
import Vision


struct PoseOverlayView: View {
    @State var eee: Int = 3
    var pose: VNHumanBodyPoseObservation
    
    // Define the joint segments to connect
    let jointSegments: [JointSegment] = [
        JointSegment(jointA: .neck, jointB: .nose),
        JointSegment(jointA: .leftHip, jointB: .leftShoulder),
        JointSegment(jointA: .leftShoulder, jointB: .leftElbow),
        JointSegment(jointA: .leftElbow, jointB: .leftWrist),
        JointSegment(jointA: .leftHip, jointB: .leftKnee),
        JointSegment(jointA: .leftKnee, jointB: .leftAnkle),
        JointSegment(jointA: .rightHip, jointB: .rightShoulder),
        JointSegment(jointA: .rightShoulder, jointB: .rightElbow),
        JointSegment(jointA: .rightElbow, jointB: .rightWrist),
        JointSegment(jointA: .rightHip, jointB: .rightKnee),
        JointSegment(jointA: .rightKnee, jointB: .rightAnkle),
        JointSegment(jointA: .leftShoulder, jointB: .rightShoulder),
        JointSegment(jointA: .leftHip, jointB: .rightHip)
    ]
    
    @State private var showBone = false
    @State private var isCollisionDetected = false
    @Binding var score: Int
    
    @Binding var monsterPosition : CGPoint
    @Binding var monsterSize: CGSize
    

    func detectCollision() {
        
        
            let screenSize = UIScreen.main.bounds
            if let leftWrist = try? pose.recognizedPoint(VNHumanBodyPoseObservation.JointName.leftWrist),
               let rightWrist = try? pose.recognizedPoint(VNHumanBodyPoseObservation.JointName.rightWrist) {
                
                let leftWristPosition = transformPoint(leftWrist.location, screenSize)
                let rightWristPosition = transformPoint(rightWrist.location, screenSize)
                
//                let rectanglePosition = CGPoint(x: screenSize.width - 200, y: screenSize.height/2)
//                let rectangleSize = CGSize(width: 400, height: screenSize.height)
                let monsterRect = CGRect(origin: CGPoint(x: monsterPosition.x - monsterSize.width, y: monsterPosition.y - monsterSize.height), size: monsterSize)
                
                let leftWristRect = CGRect(origin: leftWristPosition, size: CGSize(width: 32, height: 32))
                let rightWristRect = CGRect(origin: rightWristPosition, size: CGSize(width: 32, height: 32))
                
                if (monsterRect.intersects(leftWristRect) || monsterRect.intersects(rightWristRect) ){
                    if(isCollisionDetected != true) {
                        score += 1
                    }
                    isCollisionDetected = true
                    print("detect")
                } else {
                    isCollisionDetected = false
                    print("not detect")
                }
            }
        }
    
    var body: some View {
        let screenSize = UIScreen.main.bounds
        
        ZStack {
            if let leftWrist = try? pose.recognizedPoint(VNHumanBodyPoseObservation.JointName.leftWrist) {
                Rectangle()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.yellow)
                    .position(transformPoint(leftWrist.location, screenSize))
                    .onChange(of: leftWrist){ _ in
                        detectCollision()
                    }
                
            }
            if let rightWrist = try? pose.recognizedPoint(VNHumanBodyPoseObservation.JointName.rightWrist) {
                Rectangle()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.yellow)
                    .position(transformPoint(rightWrist.location, screenSize))
                    .onChange(of: rightWrist){ _ in
                        detectCollision()
                    }
            }
            
            
            ForEach(jointSegments, id: \.self) { segment in
                if let jointA = try? pose.recognizedPoint(segment.jointA),
                   let jointB = try? pose.recognizedPoint(segment.jointB),
                   jointA.confidence > 0, jointB.confidence > 0 {
                    Path { path in
                        let pointA = transformPoint(jointA.location, screenSize)
                        let pointB = transformPoint(jointB.location, screenSize)
                        path.move(to: pointA)
                        path.addLine(to: pointB)
                    }
                    .stroke(Color.red, lineWidth: 2)
                    
                }
            }
            
        }
        .ignoresSafeArea(.all)
    }
    
    
    func transformPoint(_ point: CGPoint, _ screenSize: CGRect) -> CGPoint {
        let transformedX = point.x * screenSize.width
        let transformedY = (1 - point.y) * screenSize.height
        return CGPoint(x: transformedX, y: transformedY)
    }
}

struct JointSegment: Hashable {
    let jointA: VNHumanBodyPoseObservation.JointName
    let jointB: VNHumanBodyPoseObservation.JointName
}



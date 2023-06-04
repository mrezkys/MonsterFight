//
//  PoseOverlayView.swift
//  MonsterFight
//
//  Created by Muhammad Rezky on 29/05/23.
//

import SwiftUI
import Vision


struct PoseOverlayView: View {
    var pose: VNHumanBodyPoseObservation
    @State private var showBone = false
    @State private var isCollisionDetected = false
    @Binding var score: Int
    
    var handBoxSize: CGSize = CGSize(width: 100, height: 100)
    var monsterSize: CGSize
    var monsterPosition : CGPoint
    
    @State private var leftWristPosition: CGPoint = .zero
    @State private var rightWristPosition: CGPoint = .zero
      
      init(pose: VNHumanBodyPoseObservation, score: Binding<Int>, monsterSize: CGSize, monsterPosition: CGPoint) {
          self.pose = pose
          _score = score
          self.monsterSize = monsterSize
          self.monsterPosition = monsterPosition
      }
       
       var body: some View {
           let screenSize = UIScreen.main.bounds
//           print(leftWristPosition)
           return ZStack {
               if leftWristPosition != .zero {
                   Image("hand")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: handBoxSize.width, height: handBoxSize.height)
                       .position(transformPoint(leftWristPosition, screenSize))
                   Path { path in
                       let rect = CGRect(x: transformPoint(leftWristPosition, screenSize).x - 50, y: transformPoint(leftWristPosition, screenSize).y - 50, width: 100, height: 100)
                       path.addRect(rect)
                   }
                   .stroke(Color.red, lineWidth: 2)
               } else {
                   EmptyView()
               }
               
               if rightWristPosition != .zero {
                   Image("hand")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: handBoxSize.width, height: handBoxSize.height)
                       .position(transformPoint(rightWristPosition, screenSize))
                   Path { path in
                       let rect = CGRect(x: transformPoint(rightWristPosition, screenSize).x - 50, y: transformPoint(rightWristPosition, screenSize).y - 50, width: 100, height: 100)
                       path.addRect(rect)
                   }
                   .stroke(Color.red, lineWidth: 2)
               } else {
                   EmptyView()
               }
           }
           .onAppear {
               updateHandPositions()
           }
           .onChange(of: pose) { _ in
               updateHandPositions()
           }
           .ignoresSafeArea(.all)
       }
       
    
    func detectCollision() {
        let screenSize = UIScreen.main.bounds
        let leftHandBoundingBox = CGRect(x: transformPoint(leftWristPosition, screenSize).x - handBoxSize.width/2, y: transformPoint(leftWristPosition, screenSize).y - handBoxSize.width/2, width: handBoxSize.width, height: handBoxSize.height)
        let rightHandBoundingBox = CGRect(x: transformPoint(rightWristPosition, screenSize).x - handBoxSize.width/2, y: transformPoint(rightWristPosition, screenSize).y - handBoxSize.width/2, width: handBoxSize.width, height: handBoxSize.height)
        let monsterRect = CGRect(origin: CGPoint(x: monsterPosition.x - monsterSize.width/2, y: monsterPosition.y - monsterSize.height/2), size: monsterSize)
        
        if (monsterRect.intersects(leftHandBoundingBox) || monsterRect.intersects(rightHandBoundingBox) ){
            if(isCollisionDetected != true) {
                score -= 5
            }
            isCollisionDetected = true
        } else {
            isCollisionDetected = false
        }
    }
    
    func updateHandPositions() {
        if let leftWrist = try? pose.recognizedPoint(VNHumanBodyPoseObservation.JointName.leftWrist).location {
            leftWristPosition = leftWrist
        } else {
            leftWristPosition = .zero
        }
        
        if let rightWrist = try? pose.recognizedPoint(VNHumanBodyPoseObservation.JointName.rightWrist).location {
            rightWristPosition = rightWrist
        } else {
            rightWristPosition = .zero
        }
        
        detectCollision()
    }
    
    func transformPoint(_ point: CGPoint, _ screenSize: CGRect) -> CGPoint {
        let transformedX = point.x * screenSize.width
        let transformedY = (1 - point.y) * screenSize.height
        return CGPoint(x: transformedX, y: transformedY)
    }
}

//struct JointSegment: Hashable {
//    let jointA: VNHumanBodyPoseObservation.JointName
//    let jointB: VNHumanBodyPoseObservation.JointName
//}
//
//let jointSegments: [JointSegment] = [
//    JointSegment(jointA: .neck, jointB: .nose),
//    JointSegment(jointA: .leftHip, jointB: .leftShoulder),
//    JointSegment(jointA: .leftShoulder, jointB: .leftElbow),
//    JointSegment(jointA: .leftElbow, jointB: .leftWrist),
//    JointSegment(jointA: .leftHip, jointB: .leftKnee),
//    JointSegment(jointA: .leftKnee, jointB: .leftAnkle),
//    JointSegment(jointA: .rightHip, jointB: .rightShoulder),
//    JointSegment(jointA: .rightShoulder, jointB: .rightElbow),
//    JointSegment(jointA: .rightElbow, jointB: .rightWrist),
//    JointSegment(jointA: .rightHip, jointB: .rightKnee),
//    JointSegment(jointA: .rightKnee, jointB: .rightAnkle),
//    JointSegment(jointA: .leftShoulder, jointB: .rightShoulder),
//    JointSegment(jointA: .leftHip, jointB: .rightHip)
//]

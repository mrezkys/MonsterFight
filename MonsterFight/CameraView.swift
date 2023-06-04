//
//  CameraView.swift
//  MonsterFight
//
//  Created by Muhammad Rezky on 29/05/23.
//

import SwiftUI
import Vision

struct CropMonsterHealth: Shape {
    let isActive: Bool
    @Binding var score: Int
    
    func path(in rect: CGRect) -> Path {
        guard isActive else { return Path(rect) } // full rect for non active
        var width: CGFloat = CGFloat(200.0 * (CGFloat(score) / 100.0))
        print(width)
        return Path(CGRect(origin: CGPoint(x: UIScreen.main.bounds.width - 220, y: 36-19), size: CGSize(width: width, height: 38.17)))
    }
}

struct CropPlayerHealth: Shape {
    let isActive: Bool
    @Binding var score: Int
    
    func path(in rect: CGRect) -> Path {
        guard isActive else { return Path(rect) } // full rect for non active
        let width: CGFloat = CGFloat(200.0 * (CGFloat(score) / 100.0))
        print(width)
        return Path(CGRect(origin: CGPoint(x: 60, y: 36-19), size: CGSize(width: width, height: 38.17)))
    }
}




struct CameraView: View {
    @Binding var poses: [VNHumanBodyPoseObservation]
    @State var monsterPosition = CGPoint(x: UIScreen.main.bounds.width - 100, y: UIScreen.main.bounds.height / 2)
    @State var monsterSize = CGSize(width: 200, height: 200)
    @State private var score = 100
    @State private var health = 100
    @State private var timer: Timer?
    
    
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if health > 0 {
                health -= 5
            } else {
                timer?.invalidate()
            }
        }
    }
    
    
    var body: some View {
        ZStack {
            CameraPreview(poses: $poses)
                .edgesIgnoringSafeArea(.all)
                .ignoresSafeArea(.all)
//            Text("Health : \(health) \n kill monster before your health 0")
//                .padding(32)
//                .background(.white.opacity(0.3))
//
//                .position(x: UIScreen.main.bounds.width/2, y: 30)
            Image("player-health")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 38.17)
                .position(x: 160, y: 36)
                .clipShape(
                    CropPlayerHealth(isActive: true, score: $health)
                ).onAppear{
                                        startTimer()
                                    }
            if(timer?.isValid ?? true){
                
                ZStack{
                    Image("monster-health")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200, height: 38.17)
                        .position(x: UIScreen.main.bounds.width - 120, y: 36)
                        .clipShape(
                            CropMonsterHealth(isActive: true, score: $score)
                                    )
                    
                    Image("fire-background")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width)
                        .offset(x: 0, y: UIScreen.main.bounds.height / 2 - 24)
                    
                    Image("fire-monster")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    //                        .background(.yellow.opacity(0.3))
                        .frame( width: monsterSize.width, height:  monsterSize.height)
                        .position(monsterPosition)
                }
                
            }
            
            
            ForEach(poses.indices, id: \.self) { index in
                PoseOverlayView(pose: poses[index], score: $score, monsterSize: monsterSize, monsterPosition: monsterPosition)
            }
            
            
            if(score == 0){
                Text("END")
                    .font(.title)
                    .padding(24)
                    .background(.white.opacity(0.3))
                    .onAppear{
                        timer?.invalidate()
                    }
            }
        }
    }
}

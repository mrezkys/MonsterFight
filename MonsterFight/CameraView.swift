//
//  CameraView.swift
//  MonsterFight
//
//  Created by Muhammad Rezky on 29/05/23.
//

import SwiftUI
import Vision


struct CameraView: View {
    @Binding var poses: [VNHumanBodyPoseObservation]
    @State var monsterPosition = CGPoint(x: UIScreen.main.bounds.width - 150, y: UIScreen.main.bounds.height / 2)
    @State var monsterSize = CGSize(width: 300, height: 300)
    @State private var score = 0
    @State private var health = 100
    @State private var timer: Timer?

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if health > 0 {
                health -= 1
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
                Text("Health : \(health) \n kill monster before your health 0")
                .padding(32)
                .background(.white.opacity(0.3))
                .onAppear{
                    startTimer()
                }
                .position(x: UIScreen.main.bounds.width/2, y: 30)
            if(timer?.isValid ?? true){
                ZStack{
                    Image("fire-background")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width)
                        .offset(x: 0, y: UIScreen.main.bounds.height / 2 - 24)
                
                    Image("fire-monster")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .background(.yellow.opacity(0.3))
                        .frame( width: monsterSize.width, height:  monsterSize.height)
                        .position(monsterPosition)
                }
                
            }
            

            ForEach(poses.indices, id: \.self) { index in
                PoseOverlayView(pose: poses[index], score: $score, monsterPosition: $monsterPosition, monsterSize: $monsterSize)
            }
            
            
            if(score <= 20){
                Text("Score : \(score)")
                    .font(.title)
                    .padding(24)
                    .background(.white.opacity(0.3))
            } else {
                
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

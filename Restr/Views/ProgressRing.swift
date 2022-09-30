//
//  ProgressRing.swift
//  Restr
//
//  Created by Amin  Bagheri  on 2022-09-30.
//

import SwiftUI

struct ProgressRing: View {
    // here we are saying that this progress ring will take in a fasting manager class through an environment object. we MUST initialize it where we use it
    // we are going to be using ONE manager throughout the app, so we will pass in the same fasting manager that we use in content view
    @EnvironmentObject var fastingManager: FastingManager
    
    let timer = Timer
        .publish(every: 1, on: .main, in: .common)
        .autoconnect()
    
    var body: some View {
        ZStack {
            //MARK: Placeholder Ring
            Circle()
                .stroke(lineWidth: 20)
                .foregroundColor(.gray)
                .opacity(0.1)
            //MARK: Colored Ring
            Circle()
            // min function caps the progress value to 1.0
                .trim(from: 0.0, to: min(fastingManager.progress, 1.0))
                .stroke(AngularGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.3882352941, green: 0.5176470588, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.9960784314, green: 0.4431372549, blue: 0.7137254902, alpha: 1)), Color(#colorLiteral(red: 0.8470588235, green: 0.6862745098, blue: 0.8470588235, alpha: 1)), Color(#colorLiteral(red: 0.5921568627, green: 0.8509803922, blue: 0.8823529412, alpha: 1)), Color(#colorLiteral(red: 0.3882352941, green: 0.5176470588, blue: 1, alpha: 1))]), center: .center), style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round))
                .rotationEffect(Angle(degrees: 270))
            // When progress changes, animate this view
                .animation(.easeInOut(duration: 1.0), value: fastingManager.progress)
            VStack(spacing: 30) {
                if fastingManager.fastingState == .notStarted {
                    // MARK: Upcoming Fast
                    VStack(spacing: 5) {
                        Text("Upcoming fast")
                            .opacity(0.7)
                        Text("\(fastingManager.fastingPlan.fastingPeriod.formatted()) Hours")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                } else {
                    // MARK: Elapsed Time
                    VStack(spacing: 5) {
                        Text("Elapsed time (\(fastingManager.progress.formatted(.percent)))")
                            .opacity(0.7)
                        Text(fastingManager.startTime, style: .timer)
                            .font(.title)
                            .fontWeight(.bold)
                    }.padding(.top)
                    // MARK: Remaining Time
                    VStack(spacing: 5) {
                        if !fastingManager.elapsed {
                            Text("Remaining time")
                                .opacity(0.7)
                        } else {
                            Text("Extra time")
                                .opacity(0.7)
                        }
                        
                        Text(fastingManager.endTime, style: .timer)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }

            }
        }
        .frame(width: 250, height: 250)
        .padding()
        .onReceive(timer) { _ in // when timer publishes a new value
            fastingManager.track()
        }
    }
}

struct ProgressRing_Previews: PreviewProvider {
    static var previews: some View {
        ProgressRing()
            .environmentObject(FastingManager())
    }
}

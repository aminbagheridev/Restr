//
//  FastingManager.swift
//  Restr
//
//  Created by Amin  Bagheri  on 2022-09-30.
//

import Foundation

enum FastingState {
    case notStarted
    case fasting
    case feeding
}

enum FastingPlan: String {
    case beginner = "12:12"
    case intermediate = "16:8"
    case advanced = "20:4"
    
    var fastingPeriod: Double {
        switch self {
        case .beginner:
            return 12
        case .intermediate:
            return 16
        case .advanced:
            return 20
        }
    }
}

// This class is a publisher, and all dependent views know of all changes to the properties.
class FastingManager: ObservableObject {
    // Tghe views using this state will be updated when this changes
    @Published private(set) var fastingState: FastingState = .notStarted
    @Published private(set) var fastingPlan: FastingPlan = .intermediate
    @Published private(set) var startTime: Date {
        didSet {
            if fastingState == .fasting {
                endTime = startTime.addingTimeInterval(fastingTime)
            } else {
                endTime = startTime.addingTimeInterval(feedingTime)
            }
        }
    }
    @Published private(set) var endTime: Date
    @Published private(set) var elapsed: Bool = false
    @Published private(set) var elapsedTime: Double = 0.0
    @Published private(set) var progress: Double = 0.0
    
    var fastingTime: Double {
        return fastingPlan.fastingPeriod * 60 * 60
    }
    var feedingTime: Double {
        return 24 - fastingPlan.fastingPeriod * 60 * 60
    }
    
    init() {
        let calendar = Calendar.current
        
        // get the next time it hits 8 pm
        let components = DateComponents(hour: 20) // 8 pm
        let scheduledTime = calendar.nextDate(after: .now, matching: components, matchingPolicy: .nextTime)!
        
        startTime = scheduledTime
        endTime = scheduledTime.addingTimeInterval(FastingPlan.intermediate.fastingPeriod  * 60 * 60)
    }
    
    func toggleFastingState() {
        fastingState = (fastingState == .fasting) ? .feeding : .fasting
        startTime = Date()
        elapsedTime = 0.0
    }
    
    func track() {
        // make sure fasting has actually started
        guard fastingState != .notStarted else {
            return
        }
        if endTime >= Date() {
            print("Not elapsed")
            elapsed = false
        } else {
            print("Elapsed")
            elapsed = true
        }
        
        elapsedTime += 1
        
        print("elapsedTime: ", elapsedTime)
        
        let totalTime = (fastingState == .fasting) ? fastingTime : feedingTime
        progress = (elapsedTime / totalTime * 100).rounded() / 100
        print("progress", progress)
    }
}

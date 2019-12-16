//
//  TimeInterval+Missions.swift
//  missions
//
//  Created by Umar Qattan on 10/25/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import Foundation

extension TimeInterval {
    func toTime() -> String {
        let seconds = TimeInterval(self)
        let hours = floor(seconds / 3600) // 1.67 hours
        var remainingSeconds = seconds.truncatingRemainder(dividingBy: 3600) // 57 sec
        let remainingMinutes = floor(remainingSeconds / 60) // 40 min
        remainingSeconds = remainingSeconds.truncatingRemainder(dividingBy: 60) // 0 seconds
        
        print("hours: \(hours), minutes: \(remainingMinutes), seconds: \(remainingSeconds)")
        
        if hours < 1 && remainingMinutes < 1 {
            return String(format: "00:%02.0f", arguments: [remainingSeconds])
        } else if hours < 1 {
            return String(format: "%02.0f:%02.0f", arguments: [remainingMinutes, remainingSeconds])
        } else {
            return String(format: "%.0f:%02.0f:%02.0f", arguments: [hours, remainingMinutes, remainingSeconds])
        }
    }
}

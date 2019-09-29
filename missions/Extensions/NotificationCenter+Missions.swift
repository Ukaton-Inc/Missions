//
//  NotificationCenter+Missions.swift
//  missions
//
//  Created by Umar Qattan on 9/29/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import Foundation


extension NotificationCenter {
    
    static func postSensorValues(side: BLEDeviceSide, string: String, values: [Int]) {
        
        let name = side.rawValue
        self.default.post(
            name: NSNotification.Name(rawValue: name),
            object: nil,
            userInfo: ["string": string,
                       "values": values]
        )
    }
    
}

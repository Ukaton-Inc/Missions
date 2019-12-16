//
//  Session.swift
//  missions
//
//  Created by Umar Qattan on 10/20/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import Foundation

class Session: Codable {
    var times: [Date]
    var sensors: [Sensor]
    var stances: [String]
    var activities: [String]
    var values: [Float]
    
    convenience init(rows: [[String: String]]) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var _times: [Date] = []
        var _sensors: [Sensor] = []
        var _stances: [String] = []
        var _activities: [String] = []
        var _values: [Float] = []
        for row in rows {
            _times.append(dateFormatter.date(from: row["time"] ?? "") ?? Date())
            _sensors.append(Sensor(sensor: row))
            _stances.append(row["stance"] ?? "")
            _activities.append(row["activity"] ?? "")
            if let stringValue = row["value"], let intValue = Int(stringValue) {
                _values.append(Float(intValue))
            }
        }
        
        self.init(sensors: _sensors, times: _times, stances: _stances, activities: _activities, values: _values)
    }
    
    init(sensors: [Sensor], times: [Date], stances: [String], activities: [String], values: [Float]) {
        self.sensors = sensors
        self.times = times
        self.stances = stances
        self.activities = activities
        self.values = values
    }
}

extension Session {
    
    func timeCreated() -> String {
        guard let created = self.times.first else { return ""}
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        return dateFormatter.string(from: created)
    }
    
    func duration() -> Double {
        guard let start = self.times.first, let end = self.times.last else { return 0 }

        let elapsedTime = end.timeIntervalSince(start)
        return Double(elapsedTime)
    }
    
    func refreshRate() -> Double {
        return self.duration() / Double(self.sensors.count)
    }
    
    func description() -> String {
        var desc = ""
        for i in 0..<self.times.count {
            desc += """
            
            \(self.times[i])
            \(self.sensors[i].description())
            
            """
        }
        return desc
    }
}

class Sensor: Codable {
    // left sensors
    var l0: Int
    var l1: Int
    var l2: Int
    var l3: Int
    var l4: Int
    var l5: Int
    
    // right sensors
    var r0: Int
    var r1: Int
    var r2: Int
    var r3: Int
    var r4: Int
    var r5: Int
    

    
    convenience init(sensor: [String: String]) {

        let leftValues: [Int] = [
            Int(sensor["l_0"] ?? "0") ?? 0,
            Int(sensor["l_1"] ?? "0") ?? 0,
            Int(sensor["l_2"] ?? "0") ?? 0,
            Int(sensor["l_3"] ?? "0") ?? 0,
            Int(sensor["l_4"] ?? "0") ?? 0,
            Int(sensor["l_5"] ?? "0") ?? 0
        ]
        
        let rightValues: [Int] = [
            Int(sensor["r_0"] ?? "0") ?? 0,
            Int(sensor["r_1"] ?? "0") ?? 0,
            Int(sensor["r_2"] ?? "0") ?? 0,
            Int(sensor["r_3"] ?? "0") ?? 0,
            Int(sensor["r_4"] ?? "0") ?? 0,
            Int(sensor["r_5"] ?? "0") ?? 0
        ]

        
        self.init(values: leftValues + rightValues)
    }
    
    init(values: [Int]) {
        self.l0 = values[0]
        self.l1 = values[1]
        self.l2 = values[2]
        self.l3 = values[3]
        self.l4 = values[4]
        self.l5 = values[5]
        self.r0 = values[6]
        self.r1 = values[7]
        self.r2 = values[8]
        self.r3 = values[9]
        self.r4 = values[10]
        self.r5 = values[11]
    }
}

extension Sensor {
    func description() -> String {
        return """
        [l0: \(l0), l1: \(l1), l2: \(l2), l3: \(l3), l4: \(l4), l5: \(l5)]
        [r0: \(r0), r1: \(r1), r2: \(r2), r3: \(r3), r4: \(r4), r5: \(r5)]
        """
    }
    
    func leftValues() -> [Int] {
        return [
            self.l0,
            self.l1,
            self.l2,
            self.l3,
            self.l4,
            self.l5
        ]
    }
    
    func rightValues() -> [Int] {
        return [
            self.r0,
            self.r1,
            self.r2,
            self.r3,
            self.r4,
            self.r5
        ]
    }
    
    func values() -> [Int] {
        return [
            self.l0,
            self.l1,
            self.l2,
            self.l3,
            self.l4,
            self.l5,
            self.r0,
            self.r1,
            self.r2,
            self.r3,
            self.r4,
            self.r5
        ]
    }
}



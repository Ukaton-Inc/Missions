//
//  Array+Missions.swift
//  missions
//
//  Created by Umar Qattan on 12/19/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import Foundation


extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

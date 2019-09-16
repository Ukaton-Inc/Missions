//
//  Missions.swift
//  missions
//
//  Created by Umar Qattan on 8/18/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import Foundation
import UIKit


class Missions {
    
    func getValues(data: [Any]) -> [Int] {
        guard let stringData = data.first as? String else { return []}
        
        guard let jsonData = stringData.toJSON() as? [String: Any],
        let _ = jsonData["type"] as? String, let values = jsonData["values"] as? [Int] else { return [] }
        
        return values
    }
    
    func getSliderValue(values: [Int]) -> Float {
        let values_ = values.map({map(minRange: 0, maxRange: 255, minDomain: 0, maxDomain: 100, value: $0)})
        let topSensors = [0, 1, 3]
        let bottomSensors = [2, 4, 5]
        
        var topSum: CGFloat = 1
        var bottomSum: CGFloat = 1
        
        for i in topSensors {
            topSum += CGFloat(values_[i])
        }
        
        for j in bottomSensors {
            bottomSum += CGFloat(values_[j])
        }
        
        return Float(topSum / (topSum + bottomSum))

    }
    
    func getPrediction(model: SmartShoeInsoleClassifier, _ values: [Double], success: @escaping (_ classifier: SmartShoeInsoleClassifierOutput?) -> Void) {
        guard let classifier = try? model.prediction(
            s_0: values[0],
            s_1: values[1],
            s_2: values[2],
            s_3: values[3],
            s_4: values[4],
            s_5: values[5],
            s_6: values[6],
            s_7: values[7],
            s_8: values[8],
            s_9: values[9],
            s_10: values[10],
            s_11: values[11],
            s_12: values[12],
            s_13: values[13],
            s_14: values[14],
            s_15: values[15]
            ) else {
                success(nil)
                fatalError("Unexpected runtime error")
        }
        
        success(classifier)
    }
    
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

func map(minRange:Int, maxRange:Int, minDomain:Int, maxDomain:Int, value:Int) -> Int {
    return minDomain + (maxDomain - minDomain) * (value - minRange) / (maxRange - minRange)
}


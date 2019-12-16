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
    
    func getValuePrediction(model: SmartShoeInsoleStanceValue, _ values: [Double], success: @escaping (_ output: SmartShoeInsoleStanceValueOutput?) -> Void) {
        guard let regressor = try? model.prediction(
        l_0: values[0],
        l_1: values[1],
        l_2: values[2],
        l_3: values[3],
        l_4: values[4],
        l_5: values[5],
        r_0: values[6],
        r_1: values[7],
        r_2: values[8],
        r_3: values[9],
        r_4: values[10],
        r_5: values[11]
        ) else {
            success(nil)
            fatalError("Unexpected runtime error")
        }
        
        success(regressor)
    }
    
    func getStancePrediction(model: SmartShoeInsoleStanceClassifier, _ values: [Double], success: @escaping (_ output: SmartShoeInsoleStanceClassifierOutput?) -> Void) {
        guard let classifier = try? model.prediction(
        l_0: values[0],
        l_1: values[1],
        l_2: values[2],
        l_3: values[3],
        l_4: values[4],
        l_5: values[5],
        r_0: values[6],
        r_1: values[7],
        r_2: values[8],
        r_3: values[9],
        r_4: values[10],
        r_5: values[11]
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


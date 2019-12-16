//
//  ActivityPredictionViewController.swift
//  missions
//
//  Created by Umar Qattan on 11/29/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import Foundation
import UIKit

class ActivityPredictionViewController: UIViewController {
    
    private var currentStance: Stance = .neutral
    private var currentActivity: Activity = .stand
    private var currentValue: Float = 0
    @IBOutlet weak var stanceLabel: UILabel!
    @IBOutlet weak var stanceSlider: UISlider!
    @IBOutlet weak var missionsView: MissionsView!
    
    private var freq: [String: Int] = [
        "left" : 0,
        "semi_left": 0,
        "neutral": 0,
        "semi_right": 0,
        "right": 0
    ]
    private var sampleFreq: Int = 20
    
    private var predictions: Int = 0
    
    let classifierModel = SmartShoeInsoleStanceClassifier()
    let regressorModel = SmartShoeInsoleStanceValue()
    
    var values = [Double](repeating: 0, count: 12)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension ActivityPredictionViewController {
    func addObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(update(_:)), name: NSNotification.Name(rawValue: BLEDeviceSide.left.rawValue), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(update(_:)), name: NSNotification.Name(rawValue: BLEDeviceSide.right.rawValue), object: nil)
        }
    
    @objc func update(_ notification: Notification) {
        
        guard
            let userInfo = notification.userInfo,
            let values = userInfo["values"] as? [Int]
        else { return }
        
        var left: [Int] = [Int](repeating: 0, count: 6)
        var right: [Int] = [Int](repeating: 0, count: 6)
        switch notification.name.rawValue {
        case BLEDeviceSide.left.rawValue:
            self.missionsView.updateLeftSensors(values: values)
                left = values

        case BLEDeviceSide.right.rawValue:
            self.missionsView.updateRightSensors(values: values)
                right = values
            
        default: break
        }
        
        self.updateValuesFromMissions(left: left, right: right)
        
    }

    func updateValuesFromMissions(left: [Int], right: [Int]) {
        
        for (i, lval) in left.enumerated() {
            self.values[i] = Double(lval)
        }
        for (i, rval) in right.enumerated() {
            self.values[i+left.count] = Double(rval)
        }
        
        
        Missions().getStancePrediction(model: self.classifierModel, self.values, success: {
            [weak self] (stanceString) in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if let stanceString = stanceString?.stance {
                    self.freq[stanceString] = (self.freq[stanceString] ?? 0) + 1
                    self.predictions += 1
                    if self.predictions >= self.sampleFreq {
                        if let val = self.freq.max(by: { a, b in a.value < b.value }) {
                            let stance = Stance.stanceFromString(val.key)
                            self.stanceLabel.text = stance.stanceLabelString
                            self.stanceSlider.value = stance.valueForStance
                            print("Stance Label: \(stance.stanceLabelString)")
                        }
                        self.predictions = 0
                        self.freq = [
                            "left" : 0,
                            "semi_left": 0,
                            "neutral": 0,
                            "semi_right": 0,
                            "right": 0
                        ]
                    }
                }
            }
        })
        
//        Missions().getValuePrediction(model: self.regressorModel, self.values, success: {
//            [weak self] (stanceValue) in
//            guard let `self` = self else { return }
//            DispatchQueue.main.async {
//                if let value = stanceValue?.value {
//                    print("Slider value: \(value)")
//                    let fvalue = Float(value)
//                    self.currentStance = Stance.stanceForValue(fvalue)
//                    if Stance.shouldUpdateStanceForValue(stance: self.currentStance, value: fvalue) {
//                        self.stanceSlider.value = fvalue
//                    }
//                }
//            }
//        })
    }
}

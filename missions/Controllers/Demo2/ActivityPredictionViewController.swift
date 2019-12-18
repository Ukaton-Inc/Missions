//
//  ActivityPredictionViewController.swift
//  missions
//
//  Created by Umar Qattan on 11/29/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

@available(iOS 13, *)
class ActivityPredictionViewController: UIViewController {
    
    private var currentStance: Stance = .neutral
    private var currentActivity: Activity = .stand
    private var currentValue: Float = 0
    @IBOutlet weak var stanceLabel: UILabel!
    @IBOutlet weak var stanceSlider: UISlider!
    @IBOutlet weak var soundSlider: UISlider!
    @IBOutlet weak var missionsView: MissionsView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var countUpLabel: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    
    private var playbackState: PlaybackState = .pause
    private var updater: CADisplayLink! = nil

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
        self.setUpButtons()
        self.resetSoundSlider()
        AudioPlayback.shared.setPanValue(stanceSlider.value)
        soundSlider.addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside])
        soundSlider.addTarget(self, action: #selector(handleTouchDown), for: [.touchDown])

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

@available(iOS 13, *)
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

// Implemented by Elina

@available(iOS 13, *)
extension ActivityPredictionViewController {
    
    func setUpButtons() {
        
        setUpBackwardButton()
        setUpForwardButton()
        
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        
        if AudioPlayback.shared.audioPlayer.currentTime == AudioPlayback.shared.audioPlayer.duration {
            AudioPlayback.shared.audioPlayer.currentTime = 0.00
        } else {
            self.playbackState = self.playbackState.toggle
            self.playButton.setImage(self.playbackState.image, for: .normal)
            updateRunLoop()
        }
        
        AudioPlayback.shared.play(pan: stanceSlider.value)
      
      }
    
    @IBAction func onStanceChanged(_ sender: UISlider) {
        
        self.currentStance = Stance.stanceForValue(sender.value)
        self.stanceLabel.text = self.currentStance.stanceLabelString
        AudioPlayback.shared.setPanValue(sender.value)

    }
    
    func updateRunLoop() {
        
        if updater == nil {
            updater = CADisplayLink(target: self, selector: #selector(trackAudio(_:)))
            updater.preferredFramesPerSecond = 10
            updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        }
        
    }
    
    func setUpBackwardButton() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(backwardTap(_:)))
        backwardButton.addGestureRecognizer(tap)
        
    }
    
    func setUpForwardButton() {
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(forwardTap(_:)))
        forwardButton.addGestureRecognizer(tap)

    }
    
    @objc func backwardTap(_ sender: UITapGestureRecognizer) {
        
        if playbackState == .play {
            AudioPlayback.shared.skipToStart()
        } else {
            AudioPlayback.shared.audioPlayer.currentTime = 0.0
        }

    }
    
    @objc func forwardTap(_ sender: UITapGestureRecognizer) {
        
        // skip to end
        if playbackState == .play {
            self.playbackState = .pause
            self.playButton.setImage(self.playbackState.image, for: .normal)
        }
        
        AudioPlayback.shared.skipToEnd()
        
    }
    
    func resetSoundSlider() {
        
        soundSlider.isContinuous = false
        soundSlider.value = 0.0
        
    }
    
    @objc func trackAudio(_ displayLink: CADisplayLink) {
        
        let normalizedTime = Float(AudioPlayback.shared.audioPlayer.currentTime * 1 / AudioPlayback.shared.audioPlayer.duration)
            soundSlider.setValue(normalizedTime, animated: true)
        
        let timeTaken: String = String(Int(floor(AudioPlayback.shared.audioPlayer.currentTime)) / 60) + ":" +  String(format: "%02d", Int(floor(AudioPlayback.shared.audioPlayer.currentTime)) % 60)
        
        let timeLeft: String = String(Int(floor(AudioPlayback.shared.audioPlayer.duration - AudioPlayback.shared.audioPlayer.currentTime)) / 60) + ":" + String(format: "%02d", Int(floor(AudioPlayback.shared.audioPlayer.duration - AudioPlayback.shared.audioPlayer.currentTime)) % 60)
        
        countUpLabel.text = timeTaken
        countDownLabel.text = "-" + timeLeft
        
        if countDownLabel.text == "-0:00" &&
            self.playbackState == .play {
            self.playbackState = self.playbackState.toggle
            self.playButton.setImage(self.playbackState.image, for: .normal)
        }
        
    }
    
    @IBAction func onSoundChanged(_ sender: UISlider) {
        
        AudioPlayback.shared.audioPlayer.pause()
        
        let currentTime = Double(sender.value) * AudioPlayback.shared.audioPlayer.duration
        AudioPlayback.shared.audioPlayer.currentTime = currentTime
        
        if playbackState == .play {
            AudioPlayback.shared.audioPlayer.play()
        }
        
        updateRunLoop()
         
    }
    
    @objc func handleTouchUp() {
        
        updateRunLoop()
        
    }
    
    @objc func handleTouchDown() {
        
        if updater != nil {
            updater.invalidate()
            updater = nil
        }
        
    }
    
    
    
}

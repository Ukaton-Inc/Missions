//
//  RightMissionsViewController.swift
//  missions
//
//  Created by Umar Qattan on 9/24/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit
import CoreML

class RightMissionsViewController: UIViewController {
    
    @IBOutlet var sensors: [UIView]!
    
    private var missions: Missions = Missions()

    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    private lazy var slider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0.5
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addObservers()
        self.setupViews()
        self.applyConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.removeObservers()
    }
    
    private func updateMissions(_ values: [Int]) {
        for (i, sensor) in self.sensors.enumerated() {
            sensor.backgroundColor = UIColor.green.withAlphaComponent(CGFloat(values[i])/100.0)
        }
        
        self.slider.value = self.missions.getSliderValue(values: values)
    }
}

extension RightMissionsViewController {
    private func setupViews() {
        self.view.addSubview(self.slider)
        self.slider.transform = CGAffineTransform(rotationAngle: -.pi/2)
    }
    
    private func applyConstraints() {
        self.slider.widthAnchor.constraint(equalToConstant: UIScreen.main
            .bounds.width * 0.6).isActive = true
        self.slider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        self.slider.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        self.slider.centerXAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50).isActive = true
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(update(_:)), name: NSNotification.Name(rawValue: BLEDeviceSide.left.rawValue), object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func update(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let values = userInfo["values"] as? [Int]
        else { return }
        
        if notification.name.rawValue == BLEDeviceSide.right.rawValue {
            self.updateMissions(values)
        }
    }
}

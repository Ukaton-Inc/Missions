//
//  HomeViewController.swift
//  missions
//
//  Created by Umar Qattan on 8/18/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    private var activeTextField: UITextField?
    @IBOutlet weak var insoleButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var sensorLabel: UILabel!
    @IBOutlet weak var samplingRateSegmentedControl: UISegmentedControl!
    
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.addObservers()
    }
    
    @IBAction func onSamplingRateChanged(_ sender: UISegmentedControl) {
        var samplingRate: UInt8 = 50
        switch sender.selectedSegmentIndex {
        case 0:
            samplingRate = 50
        case 1:
            samplingRate = 100
        case 2:
            samplingRate = 200
        default: break
        }
        
        self.appDelegate?.ble.updatePeripheral(samplingRate: &samplingRate)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.addObservers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeObservers()
    }
}

extension HomeViewController {
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabels(_:)), name: NSNotification.Name(rawValue: BLEDeviceSide.left.rawValue), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabels(_:)), name: NSNotification.Name(rawValue: BLEDeviceSide.right.rawValue), object: nil)
    }
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateLabels(_ notification: Notification) {
        
        guard
            let userInfo = notification.userInfo,
            let values = userInfo["values"] as? [Int]
        else { return }
        
        switch notification.name.rawValue {
        case BLEDeviceSide.left.rawValue:
            self.sensorLabel.text = "\(values)"

        case BLEDeviceSide.right.rawValue:
            self.sensorLabel.text = "\(values)"

        default: break
        }
    }
}


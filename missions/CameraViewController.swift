//
//  CameraViewController.swift
//  missions
//
//  Created by Umar Qattan on 9/8/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit
// http://10.0.0.214:3000
class CameraViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var previewView: UIView!
    private var camera: Camera = Camera()
    private var missions: Missions = Missions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addObservers()
        self.camera.setupSession()
        self.camera.setupPreviewLayer(self.view.bounds)
        self.previewView.layer.addSublayer(self.camera.videoPreviewLayer)
        self.previewView.layer.insertSublayer(self.segmentedControl.layer, above: self.camera.videoPreviewLayer)
        self.camera.startRunning()
        self.segmentedControl.selectedSegmentIndex = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.camera.stopRunning()
        self.removeObservers()
    }
    
    @IBAction func updateControl(_ sender: UISegmentedControl) {

    }
    
}

extension CameraViewController {
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(update(_:)), name: NSNotification.Name(rawValue: "NotifyLeft"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(update(_:)), name: NSNotification.Name(rawValue: "NotifyRight"), object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func update(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let leftValues = userInfo["value_left"] as? [Int] {
                self.updateHelper(leftValues)
            }
        }
    }
    
    func updateHelper(_ values: [Int]) {
        switch self.segmentedControl.selectedSegmentIndex {
        case 0:
            self.camera.updateZoomFactor(values)
        case 1:
            self.camera.updateLensFactor(values)
        default: break
        }
    }
}

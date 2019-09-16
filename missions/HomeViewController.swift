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

    override func viewDidLoad() {
        super.viewDidLoad()

        self.addObservers()
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabels(_:)), name: NSNotification.Name(rawValue: "NotifyLeft"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabels(_:)), name: NSNotification.Name(rawValue: "NotifyRight"), object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func updateLabels(_ notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let leftValue = userInfo["string"] as? String {
                self.sensorLabel.text = leftValue
            }
            
            if let rightValue = userInfo["value_right"] as? String {
                
            }
        }
    }
}


//
//  MissionsView.swift
//  missions
//
//  Created by Umar Qattan on 10/7/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit

class MissionsView: UIView {

    @IBOutlet var contentView: UIView!
    var nibName: String = "MissionsView"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet var leftSensors: [UIView]!
    @IBOutlet var rightSensors: [UIView]!
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed(self.nibName, owner: self, options: nil)
        self.addSubview(self.contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    func updateLeftSensors(values: [Int]) {
        for (i, sensor) in self.leftSensors.enumerated() {
            sensor.backgroundColor = UIColor.green.withAlphaComponent(CGFloat(values[i])/4500)
        }
    }
    
    func updateRightSensors(values: [Int]) {
        for (i, sensor) in self.rightSensors.enumerated() {
            sensor.backgroundColor = UIColor.green.withAlphaComponent(CGFloat(values[i])/4500)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

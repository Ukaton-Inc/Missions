//
//  SelectDeviceTableVIewCell.swift
//  missions
//
//  Created by Umar Qattan on 9/23/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit

struct SelectDeviceTableViewCellModel {
    var image: String
    var label: String
}

class SelectDeviceTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var deviceLabel: UILabel!
    @IBOutlet weak var deviceImageView: UIImageView!
    
    
    func configure(cellModel: SelectDeviceTableViewCellModel) {
        self.deviceImageView.image = UIImage(named: cellModel.image)
        self.deviceLabel.text = cellModel.label
    }
    
}



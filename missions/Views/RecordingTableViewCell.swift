//
//  RecordingTableViewCell.swift
//  missions
//
//  Created by Umar Qattan on 10/6/19.
//  Copyright © 2019 ukaton. All rights reserved.
//

import UIKit

struct RecordingTableViewCellModel {
    var title: String
    var date: String
    var time: String
    var description: String
    
    init(title: String, date: String, time: String, description: String) {
        self.title = title
        self.date = date
        self.time = time
        self.description = description
    }
}

class RecordingTableViewCell: UITableViewCell {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func bind(with cellModel: RecordingTableViewCellModel) {
        self.titleLabel.text = cellModel.title
        self.dateLabel.text = cellModel.date
        self.timeLabel.text = cellModel.time
        self.descriptionLabel.text = cellModel.description
    }
    

}

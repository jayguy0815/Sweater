//
//  ActivityListCell.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/20.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit

class ActivityListCell: UITableViewCell {
    @IBOutlet weak var sportTypeImageView: UIImageView!
    @IBOutlet weak var activityNameLabel: UILabel!
    @IBOutlet weak var courtNameLabel: UILabel!
    @IBOutlet weak var peopleCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sportTypeImageView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

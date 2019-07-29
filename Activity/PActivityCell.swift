//
//  PActivityCell.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/19.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit

class PActivityCell: UITableViewCell {

    @IBOutlet weak var sportTypeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var unreadLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        sportTypeImageView.layer.cornerRadius = 5
        sportTypeImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  DetailCell.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/23.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit

class DetailCell: UITableViewCell {

    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var detail2Label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isUserInteractionEnabled = false
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

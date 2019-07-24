//
//  MemberCell.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/23.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit

class MemberCell: UITableViewCell {
    @IBOutlet weak var accountImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

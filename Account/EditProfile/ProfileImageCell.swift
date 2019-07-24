//
//  ProfileImageCell.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/20.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit

class ProfileImageCell: UITableViewCell {
    @IBOutlet weak var profileImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.backgroundColor = .gray
        profileImage.clipsToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

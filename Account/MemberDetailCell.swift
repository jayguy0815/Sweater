//
//  MemberDetailCell.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/16.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase

class MemberDetailCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hobbyLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        profileImage.layer.cornerRadius = profileImage.frame.width/2
        profileImage.backgroundColor = .gray
        profileImage.clipsToBounds = true
        profileImage.image = UIImage(named: "defaultAccountImage")
        nameLabel.text = "nickname"
        hobbyLabel.text = "yourhobby"
        emailLabel.text = "example@123.com"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

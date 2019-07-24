//
//  EditPasswordCell.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/21.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit

class EditPasswordCell: UITableViewCell {

    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: UIScreen.main.bounds.width)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  MemberCenterViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/16.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit

class MemberCenterViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "會員中心"
        // Do any additional setup after loading the view.
    }
}

extension MemberCenterViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "account") as! MemberDetailCell
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "resetPassword")
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "logout")
        if indexPath.section == 0{
            
            return cell
        }else if indexPath.section == 1{
            return cell1!
        }else{
            return cell2!
        }
    }
    
    
}

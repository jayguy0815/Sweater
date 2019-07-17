//
//  TabbarViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/13.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit

class TabbarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.barTintColor = UIColor(named: "barGreen")
        // Do any additional setup after loading the
        self.tabBar.unselectedItemTintColor = UIColor(named: "松柏綠")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

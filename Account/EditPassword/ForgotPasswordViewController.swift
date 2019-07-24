//
//  ForgotPasswordViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/22.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "忘記密碼"
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = UIColor(named: "backGreen")
        // Do any additional setup after loading the view.
    }
}

extension ForgotPasswordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "emailCell") as! EmailCell
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "sendCell")
        if indexPath.section == 0 {
            return cell
        }
        return cell1!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "寄送驗證信"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 10, y: 5, width: 320, height: 10)
        myLabel.font = UIFont.boldSystemFont(ofSize: 10)
        myLabel.textColor = .lightGray
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        let headerView = UIView()
        headerView.addSubview(myLabel)
        return headerView
        
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 1 {
            let index = IndexPath(row:0, section: 0)
            let cell = tableView.cellForRow(at:index) as! EmailCell
            guard cell.emailTextField.text != "" else {
                let alertCon = UIAlertController(title: "錯誤", message: "請輸入信箱", preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .default, handler: nil)
                alertCon.addAction(action)
                self.present(alertCon,animated: true,completion: nil)
                return
            }
            guard let email = cell.emailTextField.text else {
                return
            }
                Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                guard error != nil else {
                    print(error)
                    return
                }
                let alertCon = UIAlertController(title: "已寄出驗證信", message: "請至信箱更改密碼\n更改後請用新密碼重新登入", preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .default, handler: { (_) in
                        self.navigationController?.popToRootViewController(animated: true)
                    })
                alertCon.addAction(action)
                self.present(alertCon,animated: true,completion: nil)
                return
            }
        }
    }
}

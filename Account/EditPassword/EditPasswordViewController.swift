//
//  EditPasswordViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/21.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase


class EditPasswordViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = "更改密碼"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor(named: "backGreen")
        // Do any additional setup after loading the view.
    }
}

extension EditPasswordViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "editPasswordCell") as! EditPasswordCell
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "confrimCell")
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "forgotPasswordCell")
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.editLabel.text = "請輸入舊密碼："
                
               cell.passwordTextField.borderStyle = .none
               cell.passwordTextField.isSecureTextEntry = true
                cell.passwordTextField.placeholder = "舊密碼"
                return cell
            }else if indexPath.row == 1 {
                cell.editLabel.text = "請輸入新密碼："
               cell.passwordTextField.borderStyle = .none
               cell.passwordTextField.isSecureTextEntry = true
                cell.passwordTextField.placeholder = "新密碼"
                return cell
            }
        }else if indexPath.section == 1 {
            return cell1!
        }
        return cell2!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "修改密碼"
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
            let index1 = IndexPath(row: 1, section: 0)
            let cell = tableView.cellForRow(at:index) as! EditPasswordCell
            guard cell.passwordTextField.text != "" else {
                let alertCon = UIAlertController(title: "錯誤", message: "請輸入舊密碼", preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .default, handler: nil)
                alertCon.addAction(action)
                self.present(alertCon,animated: true,completion: nil)
                return
            }
            let oldPassword = cell.passwordTextField.text
            let cell1 = tableView.cellForRow(at:index1) as! EditPasswordCell
            
            
            
            guard cell1.passwordTextField.text != "" else {
                let alertCon = UIAlertController(title: "錯誤", message: "請輸入新密碼", preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .default, handler: nil)
                alertCon.addAction(action)
                self.present(alertCon,animated: true,completion: nil)
                return
            }
            
            let newPassword = cell1.passwordTextField.text
            
            guard let email = Auth.auth().currentUser?.email else{
                return
            }
            
            let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword!)
            
            Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (result, error) in
                guard error == nil else{
                    let alertCon = UIAlertController(title: "錯誤", message: "舊密碼不正確", preferredStyle: .alert)
                    let action = UIAlertAction(title: "好", style: .default, handler: nil)
                    alertCon.addAction(action)
                    self.present(alertCon,animated: true,completion: nil)
                    return
                }
                if let authResult = result {
                    
                    guard newPassword!.count >= 6 else{
                        let alertCon = UIAlertController(title: "錯誤", message: "新密碼需6字以上", preferredStyle: .alert)
                        let action = UIAlertAction(title: "好", style: .default, handler: nil)
                        alertCon.addAction(action)
                        self.present(alertCon,animated: true,completion: nil)
                        return
                    }
                    
                    guard oldPassword != newPassword else {
                        let alertCon = UIAlertController(title: "錯誤", message: "新舊密碼不可相同", preferredStyle: .alert)
                        let action = UIAlertAction(title: "好", style: .default, handler: nil)
                        alertCon.addAction(action)
                        self.present(alertCon,animated: true,completion: nil)
                        return
                    }
                    Auth.auth().currentUser?.updatePassword(to: newPassword!, completion: { (error) in
                        if let err = error {
                            print(err)
                        }
                        let alertCon = UIAlertController(title: "完成", message: "密碼修改成功", preferredStyle: .alert)
                        let action = UIAlertAction(title: "好", style: .default, handler: nil)
                        alertCon.addAction(action)
                        self.present(alertCon,animated: true,completion: nil)
                    })
                }
            })
           
            
        }
        
        if indexPath.section == 2 {
            
        }
    }
    
}

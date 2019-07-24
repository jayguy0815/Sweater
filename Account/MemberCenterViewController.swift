//
//  MemberCenterViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/16.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase


class MemberCenterViewController: UIViewController {

    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.titleView?.tintColor = .white
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
        self.navigationItem.title = "會員中心"
        
        tableView.backgroundColor = UIColor(named: "backGreen")
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProfileSegue"{
            let editVC = segue.destination as! EditProfileViewController
            let imageData = UserDefaults.standard.data(forKey: "profileImageData")
            let pimage = UIImage(data: imageData!)
            let name = UserDefaults.standard.string(forKey: "nickname")
            let hobby = UserDefaults.standard.string(forKey: "hobby")
            editVC.image = pimage!
            editVC.name = name!
            editVC.hobby = hobby!
        }
    }
}

extension MemberCenterViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "account") as! MemberDetailCell
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "editProfile")
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "resetPassword")
        let cell3 = tableView.dequeueReusableCell(withIdentifier: "logout")
        
        let imagedata = UserDefaults.standard.data(forKey: "profileImageData")
        let image = UIImage(data: imagedata!)
        let name = UserDefaults.standard.string(forKey: "nickname")
        let hobby = UserDefaults.standard.string(forKey: "hobby")
        let email = Auth.auth().currentUser?.email!
        
        if indexPath.section == 0{
            cell.profileImage.image = image
            cell.nameLabel.text = name
            cell.hobbyLabel.text = hobby
            cell.emailLabel.text = email
            cell.isUserInteractionEnabled = false
            
            return cell
        }else if indexPath.section == 1{
            return cell1!
        }else if indexPath.section == 2{
            return cell2!
        }
        return cell3!
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 430
        }
        return 45
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }else if section == 3{
            return 0
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3{
            guard let uid = UserDefaults.standard.string(forKey: "uid")else {
                return
            }
            Firestore.firestore().collection("user_data").document(uid).updateData(["issignin":false]) { (error) in
                if let err = error {
                    print("Error updating issignin: \(err)")
                } else {
                    print("issignin successfully updated")
                    try? Auth.auth().signOut()
                    self.tabBarController?.selectedIndex = 0
                }
            }
        }else if indexPath.section == 1{
            performSegue(withIdentifier: "editProfileSegue", sender: nil)
        }else if indexPath.section == 2{
            performSegue(withIdentifier: "editPasswordSegue", sender: nil)
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 20
        }
        else if section == 1{
            return 20
        }else if section == 3{
            return 20
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "個人資訊"
        }
        else if section == 1{
            return "編輯"
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
    
}

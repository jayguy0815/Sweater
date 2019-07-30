//
//  MemberViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/23.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class MemberViewController: UIViewController, ManagerDelegate {
    func didFinishListen() {
        self.tableView.reloadData()
    }
    

    @IBOutlet weak var tableView: UITableView!
    
    var activity : Activity!
    var members : [Account]!
    var activityListener : ListenerRegistration?
    var accountListener : ListenerRegistration?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.members.sort { (a1, a2) -> Bool in
            a1.postTime>a2.postTime
        }
        self.activityListener = Firestore.firestore().collection("activities").document(self.activity.key).addSnapshotListener({ (snapshot, error) in
            if let err = error {
                print(err)
            }
            guard let queryActivity = snapshot?.data() else {
                return
            }
            let count = queryActivity["participateCounter"] as! Int
            let participates = queryActivity["participates"] as! [String]
            var accounts = [Account]()
            for participate in participates {
                var account = Manager.shared.querySpecificAccount(uid: participate)
                accounts.append(account)
            }
            accounts.sort(by: { (a1, a2) -> Bool in
                a1.postTime > a2.postTime
            })
            if self.members == accounts{
                return
            }else{
                self.members = accounts
                self.tableView.reloadData()
            }
        })
        
//        self.accountListener = Firestore.firestore().collection("user_data").addSnapshotListener({ (snapshot, error) in
//            if let err = error {
//                print(err)
//            }
//            guard let queryAccounts = snapshot?.documentChanges else {
//                return
//            }
//            queryAccounts.forEach({ (diff) in
//                for i in 0..<self.members.count {
//                    if self.members[i].uid == diff.document.data()["uid"] as! String {
//                        if self.members[i].accountImageURL != diff.document.data()["accountImageURL"] as! String{
//                            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
//                                self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
//                            })
//                        }
//                    }
//                }
//            })
//        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Manager.shared.delegate = self
        let backButton = UIBarButtonItem()
        backButton.title = "返回"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.navigationItem.title = "成員"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(named: "backGreen")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.activityListener?.remove()
    }
}

extension MemberViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "memberCell") as! MemberCell
        cell.accountImageView.layer.cornerRadius = cell.accountImageView.frame.height/2
        let imagedata = members[indexPath.row].image
        if let image = UIImage(data: imagedata){
            cell.accountImageView.image = image
        }
        cell.nameLabel.text = members[indexPath.row].nickname
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "成員\(members.count)"
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
    }
    
}

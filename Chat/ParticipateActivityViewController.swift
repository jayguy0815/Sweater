//
//  ParticipateActivityViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/4.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase
import CoreData

class ParticipateActivityViewController: UIViewController {

    @IBOutlet weak var participateActivitiesTableView: UITableView!
    
    //var activity = Activity()
    var activities = [Activity]()
    var listener : ListenerRegistration?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
        self.activities = Manager.shared.loadMyActivityFromCoreData()
        self.activities.sort { (a1, a2) -> Bool in
            a1.latestPostTime>a2.latestPostTime
        }
        participateActivitiesTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.listener = Firestore.firestore().collection("activities").addSnapshotListener({ (snapshot, error) in
            guard error == nil else{
                print(error!)
                return
            }
            guard let queryActivities = snapshot?.documentChanges else{
                return
            }
            queryActivities.forEach({ (diff) in
                for i in 0..<self.activities.count {
                    if diff.document.documentID == self.activities[i].key{
//                        guard self.activities[i].latestPost != diff.document.data()["lastMessage"] as! String else{
//                            return
//                        }
//                        self.activities[i].latestPost = diff.document.data()["lastMessage"] as! String
//                        self.activities[i].latestPostTime = diff.document.data()["lastMessageTime"] as! Double
//                        self.activities[i].modifiedTime = diff.document.data()["modifiedTime"] as! Double
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                            self.activities.sort(by: { (a1, a2) -> Bool in
                                a1.latestPostTime>a2.latestPostTime
                            })
                            
                            self.participateActivitiesTableView.reloadData()
                        })
                        
                    }
                }
            })
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.navigationController?.navigationBar.topItem?.title = "已參加活動"
        self.participateActivitiesTableView.backgroundColor = UIColor(named: "backGreen")
        //self.participateActivitiesTableView.register(UINib(nibName: "ActivityListCell", bundle: nil), forCellReuseIdentifier: "activity")
        participateActivitiesTableView.delegate = self
        participateActivitiesTableView.dataSource = self
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            self.participateActivitiesTableView.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let channelVC = segue.destination as? ChatRoomViewController else {
            return
        }
        guard let indexPath = self.participateActivitiesTableView.indexPathForSelectedRow else {
            return
        }
        
        channelVC.activity = activities[indexPath.row]
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        self.listener?.remove()
    }
}

extension ParticipateActivityViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "participateActivity") as! PActivityCell
        
        cell.nameLabel.text = "\(activities[indexPath.row].name)(\(activities[indexPath.row].participantCounter))"
        cell.messageLabel.text = activities[indexPath.row].latestPost
//        if activities[indexPath.row].unread != true{
//            cell.unreadLabel.isHidden = true
//        }
        let timeInterval = activities[indexPath.row].latestPostTime
        let dateText = Manager.shared.timeIntervaltoDatetoString(timeInterval: timeInterval, format: "HH:mm")
        cell.timeLabel.text = dateText
        cell.unreadLabel.layer.cornerRadius = 10
        if self.activities[indexPath.row].unread == false{
            cell.unreadLabel.isHidden = true
        }else if self.activities[indexPath.row].unread == true{
            cell.unreadLabel.isHidden = false
        }
        
        if self.activities[indexPath.row].type == "籃球"{
            cell.sportTypeImageView.image = UIImage(named: "circle-basketball")!
        }else if self.activities[indexPath.row].type == "健身"{
            cell.sportTypeImageView.image = UIImage(named: "circle-workout")!
        }else if self.activities[indexPath.row].type == "棒球"{
            cell.sportTypeImageView.image = UIImage(named: "circle-baseball")!
        }else if self.activities[indexPath.row].type == "游泳"{
            cell.sportTypeImageView.image = UIImage(named: "circle-swim")!
        }else if self.activities[indexPath.row].type == "網球"{
            cell.sportTypeImageView.image = UIImage(named: "circle-tennis")!
        }else if self.activities[indexPath.row].type == "足球"{
            cell.sportTypeImageView.image = UIImage(named: "circle-soccer")!
        }else if self.activities[indexPath.row].type == "排球"{
            cell.sportTypeImageView.image = UIImage(named: "circle-volleyball")!
        }else if self.activities[indexPath.row].type == "羽球"{
            cell.sportTypeImageView.image = UIImage(named: "circle-badminton")!
        }
        cell.backgroundColor = UIColor(named: "backGreen")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        request.predicate = NSPredicate(format:"(key = %@)", (activities[indexPath.row].key))
        
        do {
            let results = try CoreDataHelper.shared.managedObjectContext().fetch(request)  as! [Activity]
            
            if results.count > 0 {
                results[0].unread = false
                CoreDataHelper.shared.saveContext()
                
            }
        } catch {
            fatalError("\(error)")
        }
        performSegue(withIdentifier: "intoChat", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}

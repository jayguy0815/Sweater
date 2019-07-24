//
//  ParticipateActivityViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/4.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase

class ParticipateActivityViewController: UIViewController {

    @IBOutlet weak var participateActivitiesTableView: UITableView!
    
    //var activity = Activity()
    var activities = [Activity]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.tabBarController?.tabBar.isHidden = false
        self.activities = Manager.shared.loadMyActivityFromCoreData()
        participateActivitiesTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "已參加活動"
        self.participateActivitiesTableView.backgroundColor = UIColor(named: "backGreen")
        self.participateActivitiesTableView.register(UINib(nibName: "ActivityListCell", bundle: nil), forCellReuseIdentifier: "activity")
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
   

}

extension ParticipateActivityViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activity") as! ActivityListCell
        
        cell.activityNameLabel.text = "\(activities[indexPath.row].name)(\(activities[indexPath.row].participantCounter))"
        cell.courtNameLabel.text = activities[indexPath.row].courtName
        let df = DateFormatter()
        df.dateFormat = "MM/dd HH:mm"
        let dateString = df.string(from: activities[indexPath.row].date)
        cell.peopleCountLabel.text = dateString
        cell.sportTypeImageView.image = UIImage(named: "basketballCellIcon")
        cell.backgroundColor = UIColor(named: "backGreen")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "intoChat", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
}

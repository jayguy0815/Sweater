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
        channelVC.channelID = self.activities[indexPath.row].key
    }
   

}

extension ParticipateActivityViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activity") as! ActivityListCell
        
        cell.activityNameLabel.text = activities[indexPath.row].name
        cell.courtNameLabel.text = activities[indexPath.row].courtName
        cell.peopleCountLabel.text = "人數  \(activities[indexPath.row].participantCounter)/ \(activities[indexPath.row].peopleCounter)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "intoChat", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

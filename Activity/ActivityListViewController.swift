//
//  ActivityListViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/20.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit



class ActivityListViewController: UIViewController {
    
    @IBOutlet weak var activityTableView: UITableView!
    var activityData = [Activity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityTableView.register(UINib(nibName: "ActivityListCell", bundle: nil), forCellReuseIdentifier: "activity")
        activityTableView.delegate = self
        activityTableView.dataSource = self
        
        // Do any additional setup after loading the view.
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

extension ActivityListViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Activity.shared.activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activity") as! ActivityListCell
        cell.activityNameLabel.text = Activity.shared.activities[indexPath.row].name
        cell.courtNameLabel.text = Activity.shared.activities[indexPath.row].courtName
        cell.peopleCountLabel.text = "人數 \(Activity.shared.activities[indexPath.row].participantCounter)/\(Activity.shared.activities[indexPath.row].peopleCounter)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}

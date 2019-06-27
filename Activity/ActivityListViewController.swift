//
//  ActivityListViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/20.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase



class ActivityListViewController: UIViewController {
   
    
    
    @IBOutlet weak var activityTableView: UITableView!
    
    let methods = Methods()
    let manager = Manager()
   // var delegate : ActivityListVCDelegate?
    var reFreshControl : UIRefreshControl!
    //var ref : DatabaseReference!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //manager.loadActivities()
        
        self.activityTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.activityTableView.register(UINib(nibName: "ActivityListCell", bundle: nil), forCellReuseIdentifier: "activity")
        activityTableView.delegate = self
        activityTableView.dataSource = self
        reFreshControl = UIRefreshControl()
        reFreshControl.addTarget(self, action: #selector(reloadActivities), for: .valueChanged)
        activityTableView.addSubview(reFreshControl)
        // Do any additional setup after loading the view.
    }
    
    @objc func reloadActivities(){
        
            Manager.shared.loadActivities()
        // 這邊我們用一個延遲讀取的方法，來模擬網路延遲效果（延遲3秒）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 停止 refreshControl 動畫
            self.reFreshControl.endRefreshing()
            self.activityTableView.reloadData()
        }
        
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
        return Manager.shared.activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activity") as! ActivityListCell
        
        cell.activityNameLabel.text = Manager.shared.activities[indexPath.row].name
        cell.courtNameLabel.text = Manager.shared.activities[indexPath.row].courtName
        cell.peopleCountLabel.text = "人數  \(Manager.shared.activities[indexPath.row].participantCounter)/ \(Manager.shared.activities[indexPath.row].peopleCounter)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let currentActivity = Manager.shared.activities[indexPath.row]
        if currentActivity.participantCounter < currentActivity.peopleCounter {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            performSegue(withIdentifier: "activityDetail", sender: nil)
        }else{
            methods.newAlert(Title: "人數已滿", Message: "欲參加的揪團已滿/n請選擇其他揪團", actionTitle: "好")
        }
    }
    
}

extension ActivityListViewController : MapVCDelegate {
    func didFinishCreateActivity() {
       // manager.loadActivities()
        
    }
    
}

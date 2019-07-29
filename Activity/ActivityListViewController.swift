//
//  ActivityListViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/20.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase
import CoreData


class ActivityListViewController: UIViewController, NSFetchRequestResult ,ActivityDetailViewControllerDelegate {
    func didParticipate() {
        reloadActivities()
    }

    
    @IBOutlet weak var activityTableView: UITableView!
    //let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var activities = [Activity]()
    let methods = Methods()
    let manager = Manager()
    
   

    var selectedIndexPath : IndexPath?
    //let moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext()
    //var listener : ListenerRegistration?
    var flag = true
    var refreshControl = UIRefreshControl()
    
    //var ref : DatabaseReference!
    
    @IBAction func refresh(){
        refreshControl.beginRefreshing()
        // 使用 UIView.animate 彈性效果，並且更改 TableView 的 ContentOffset 使其位移
        // 動畫結束之後使用 loadData()
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.activityTableView.contentOffset = CGPoint(x: 0, y: -self.refreshControl.bounds.height)
        }) {(finish) in
            self.reloadActivities()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.flag = true
        let cloudFireStore = Firestore.firestore()
        super.viewWillAppear(true)
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.activities.removeAll()
        queryFromCoredata()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        self.navigationController?.navigationBar.topItem?.title = "活動列表"
        self.activityTableView.backgroundColor = UIColor(named: "backGreen")
        self.activityTableView.register(UINib(nibName: "ActivityListCell", bundle: nil), forCellReuseIdentifier: "activity")
        activityTableView.delegate = self
        activityTableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(reloadActivities), for: .valueChanged)
        activityTableView.addSubview(refreshControl)
        refresh()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    deinit {
        //self.listener?.remove()
        print("deinit")
    }
    
    @objc func reloadActivities(){
//        Manager.shared.loadMoreActivities()
            self.queryFromCoredata()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // 停止 refreshControl 動畫
            
            self.refreshControl.endRefreshing()
            self.activityTableView.reloadData()
        }
        
    }
    

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "activityDetail" {
            let DetailVC = segue.destination as! ActivityDetailViewController
            if let indexPath = self.selectedIndexPath{
                DetailVC.activity = self.activities[indexPath.row]
            }
        }
    }
    
}

extension ActivityListViewController : UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "activity") as! ActivityListCell
        
        cell.activityNameLabel.text = self.activities[indexPath.row].name
        cell.courtNameLabel.text = self.activities[indexPath.row].courtName
        cell.peopleCountLabel.text = "人數  \(self.activities[indexPath.row].participantCounter)/ \(self.activities[indexPath.row].peopleCounter)"
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectedIndexPath = indexPath
        let currentActivity = self.activities[indexPath.row]
        if currentActivity.participantCounter < currentActivity.peopleCounter {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            performSegue(withIdentifier: "activityDetail", sender: nil)
        }else{
            let alertController = UIAlertController(title: "人數已滿", message: "請選擇其他揪團", preferredStyle: .alert)
            let action = UIAlertAction(title: "好", style: .cancel, handler: nil)
            alertController.addAction(action)
            present(alertController,animated: true,completion: nil)
        }
    }
    
    func queryFromCoredata(){
        
        let moc = CoreDataHelper.shared.managedObjectContext()
        let request = NSFetchRequest<Activity>(entityName: "Activity")
        //排序,ascending true由小到大排序，false:由大到小
        let sort = NSSortDescriptor(key: "postTime", ascending: false)
        //可以針對多個欄位做排序，所以接受的是陣列
        request.sortDescriptors = [sort]
        //新增欄位到Note上，比如叫sequence
        
        //等待查詢結束，才會往下執行
        moc.performAndWait {
            
            
            do{
                self.activities = try moc.fetch(request)
            }catch{
                print("error \(error)")
                self.activities = []
            }
        }
    }
    
}

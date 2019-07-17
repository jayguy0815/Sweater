//
//  MainViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/11.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift


class MainViewController: UIViewController,UINavigationControllerDelegate{
    
    
    @IBOutlet weak var chooseTableView: UITableView!
    @IBOutlet weak var IV1: UIImageView!
    
 
    @IBOutlet weak var logout: UIButton!

    @IBOutlet weak var basketballBtn: UIButton!
    
    @IBAction func basketballBtnPressed(_ sender: Any) {
        
    }
    
    let methods = Methods()
    var ref : DatabaseReference!
    var mapData = MapData()
    var mapDataArr : [MapData] = []
    var typeArr : [String] = ["basketball","workout","baseball","swim","tennis","vollyball","soccer","badminton"]
    
    @IBAction func logoutBtn(_ sender: Any) {
        if Auth.auth().currentUser != nil{
            do{
                UserDefaults.standard.removeObject(forKey: "userProfilePicture")
                try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "nav")
                self.present(vc,animated: true,completion: nil)
            }catch{
                    print("logout failed:\(error.localizedDescription)")
            }
        }
    }
    
    
    
    @IBAction func check(_ sender: Any) {
        print(Manager.shared.activities.count)
        let user = Auth.auth().currentUser
        if (user != nil) {
            print("1")
        } else {
            print("0")
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.chooseTableView.backgroundColor = UIColor(named: "backGreen")
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user == nil {
                self.switchStoryboard()
            }
        }
        
        
       
        ref = Database.database().reference()
        
    }
    
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.chooseTableView.dataSource = self
        self.chooseTableView.delegate = self
//        if let imgdata = UserDefaults.standard.object(forKey: "userProfileImage") as? Data {
//                 let image = UIImage(data: imgdata)
//                IV1.contentMode = .scaleAspectFill
//                self.IV1.image = image
//        }
        self.navigationController?.navigationBar.topItem?.title = "Sweater"
        print(self.mapData.distList.count)
        //self.basketballBtn.setTitle("", for: .normal)
        
        // Do any additional setup after loading the view.
    }
    
    func switchStoryboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "nav")
        self.present(vc,animated: true,completion: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        print("main deinit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let createVC = segue.destination as! CreateActivityViewController
        if let indexPath = chooseTableView.indexPathForSelectedRow{
            if indexPath.section == 0{
                createVC.sportType = "籃球"
            }else if indexPath.section == 1{
                createVC.sportType = "健身"
            }else if indexPath.section == 2{
                createVC.sportType = "棒球"
            }else if indexPath.section == 3{
                createVC.sportType = "游泳"
            }else if indexPath.section == 4{
                createVC.sportType = "排球"
            }else if  indexPath.section == 5{
                createVC.sportType = "羽球"
            }else if indexPath.section == 6{
                createVC.sportType = "網球"
            }else if indexPath.section == 7{
                createVC.sportType = "足球"
            }
        }
        
        
    }
    
    
}

extension MainViewController : UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return typeArr.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basketball") as! BasketballTableViewCell
        
        if indexPath.section == 0{
            cell.basketballImageView.image = UIImage(named: "basketballBack")
            return cell
        }else if indexPath.section == 1{
            cell.basketballImageView.image = UIImage(named: "workoutBack")
            return cell
        }else if indexPath.section == 2{
            cell.basketballImageView.image = UIImage(named: "baseballBack")
            return cell
        }else if indexPath.section == 3{
            cell.basketballImageView.image = UIImage(named: "swimBack")
            return cell
        }else if indexPath.section == 4{
            cell.basketballImageView.image = UIImage(named: "volleyballBack")
            return cell
        }else if  indexPath.section == 5{
            cell.basketballImageView.image = UIImage(named: "badmintonBack")
            return cell
        }else if indexPath.section == 6{
            cell.basketballImageView.image = UIImage(named: "tennisBack")
            return cell
        }else if indexPath.section == 7{
            cell.basketballImageView.image = UIImage(named: "soccerBack")
            return cell
        }
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(integerLiteral: 2)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        performSegue(withIdentifier: "basketball", sender: nil)
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0{
           let imageview = UIImageView()
            imageview.backgroundColor = .black
            return imageview
        }
        return nil
    }
    
}



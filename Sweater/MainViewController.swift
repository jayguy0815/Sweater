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
    
    
    
    @IBOutlet weak var logout: UIButton!

    @IBOutlet weak var basketballBtn: UIButton!
    
    @IBAction func basketballBtnPressed(_ sender: Any) {
        
    }
    
    let methods = Methods()
    var ref : DatabaseReference!
    var mapData = MapData()
    var mapDataArr : [MapData] = []
    
    
    @IBAction func logoutBtn(_ sender: Any) {
        if Auth.auth().currentUser != nil{
            do{
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
//        ref = Database.database().reference()
//        ref.child("activities").child("-LiGoSvp1cVttL-u4og8").observe(.value, with: { (snapshot) in
//            guard let newSnapshot = snapshot.value as? [String:Any] else {
//                return
//            }
//
//            let postTimestamp = newSnapshot["postTime"] as! Double
//            var date = Date(timeIntervalSince1970: ((postTimestamp) / 1000))
//
//            print(date)
//        })
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user == nil {
                self.switchStoryboard()
            }
        }
        
        if let img = UIImage(named: "background"){
            self.view.backgroundColor = UIColor(patternImage: img)
        }
        
       
        ref = Database.database().reference()
    }
    
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Sweater"
        print(self.mapData.distList.count)
        self.basketballBtn.setTitle("", for: .normal)
        
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
        if segue.identifier == "basketball"{
            let createVC = segue.destination as! CreateActivityViewController
            createVC.sportType = "籃球"
        }
    }
    
    
}



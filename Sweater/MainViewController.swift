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



class MainViewController: UIViewController,UINavigationControllerDelegate {
    
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
        let user = Auth.auth().currentUser
        
        if (user != nil) {
            print("1")
        } else {
            print("0")
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadFromFile()
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user == nil {
                self.switchStoryboard()
            }
        }
        
        if let img = UIImage(named: "background"){
            self.view.backgroundColor = UIColor(patternImage: img)
        }
        
        guard methods.checkFile(fileName: "mapData.archive") == false else{
            return
        }
        ref = Database.database().reference()
        
        ref.child("maps_basketball").observeSingleEvent(of: .value) { (snapshot) in
            for distdata in snapshot.children {
                guard let distSnapshot = distdata as? DataSnapshot else {
                    continue
                }
                let dist = distSnapshot.key
                
                //self.distList.append(dist)
                self.mapData.distList.append(dist)
            }
            for dist in self.mapData.distList{
                self.ref.child("maps_basketball").child(dist).observeSingleEvent(of: .value) { (snapshot) in
                    for courtdata in snapshot.children{
                        guard let courtSnapshot = courtdata as? DataSnapshot else{
                            continue
                        }
                        let court = courtSnapshot.key
                        //self.courtList.append(court)
                        self.mapData.courtList.append(court)
                    }
                    for court in self.mapData.courtList{
                        self.ref.child("maps_basketball").child(dist).child(court).child("coordinates").observeSingleEvent(of: .value) { (snapshot) in
                            
                            let coordinate = snapshot.value as? [String:Double]
                            let latitude = coordinate?["latitude"]
                            if latitude != nil{
                                //self.latitudeList.append(latitude!)
                                self.mapData.latitudeList.append(latitude!)
                            }
                            let longitude = coordinate?["longitude"]
                            if longitude != nil{
                                //self.longitudeList.append(longitude!)
                                self.mapData.longitudeList.append(longitude!)
                            }
                        }
                        self.ref.child("maps_basketball").child(dist).child(court).observeSingleEvent(of: .value) { (addsnapshot) in
                            guard addsnapshot.value != nil else {
                                return
                            }
                            let addressData = addsnapshot.value as? [String:Any]
                            let address = addressData?["address"]
                            if address != nil{
                                //self.addressList.append(address! as! String)
                                self.mapData.addressList.append(address! as! String)
                            }
                        self.saveToFile()
                        }
                    }
                }
            }
        }
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
    
    func saveToFile(){
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("mapData.archive")
        do{
            //把[Note]轉乘data刑事
            let data = try NSKeyedArchiver.archivedData(withRootObject: self.mapData, requiringSecureCoding: false)
            //寫到檔案
            try data.write(to: fileURL, options: [.atomicWrite])
        }catch{
            print("error\(error)")
        }
        
    }
    func loadFromFile(){
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("mapData.archive")
        do{
            //把檔案轉成Data形式
            let fileData = try Data(contentsOf: fileURL)
            //從Data轉回MapData陣列
            self.mapData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! MapData
        }catch{
            print("error\(error)")
        }
    }
}

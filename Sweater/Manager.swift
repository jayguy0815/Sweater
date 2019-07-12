//
//  Manager.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/26.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Manager {
    var userAccount = Account()
    var activities = [Activity]()
    var accounts = [Account]()
    static var shared = Manager()
    static var mapData = MapData()
    var ref : DatabaseReference!
    
    
    func loadUserData(){
        let databaseRef = Database.database().reference().child("user_account")
        let storageRef = Storage.storage().reference().child("account")
        var userData = [String:Any]()
        guard let userUid = Auth.auth().currentUser?.uid else {
            return
        }
        databaseRef.observe(.value) { (snapshot) in
            if let userData = snapshot.value as? [String:Any] {
                
                let users = Array(userData.keys)
                for i in 0..<users.count {
                    let dic = userData[users[i]] as! [String:Any]
                    let account = Account()
                    let uid = dic["uid"] as! String
                    account.uid = uid
                    account.email = dic["email"] as! String
                    account.nickname = dic["nickname"] as! String
                    if uid == userUid{
                        UserDefaults.standard.set(account.nickname, forKey: "userNickName")
                    }
                    account.url = dic["accountImageUrl"] as! String
                    storageRef.child("\(uid).jpg").getData(maxSize: 1*1024*1024, completion: { (data, error) in
                        if let error = error {
                            print("*** ERROR DOWNLOAD IMAGE : \(error)")
                        } else {
                            // Success
                            if let imageData = data {
                                // 3 - Put the image in imageview
                                account.image = UIImage(data: imageData)
                            }
                        }
                    })
                    self.accounts.append(account)
                }
            }
        }
    }
    
    
    
    func loadActivities() {
        let manager = Manager()
        
        var ref : DatabaseReference!
        ref = Database.database().reference()
        
        
        
        ref.child("activities").queryOrdered(byChild: "postTime").observe(.value) { (snapshot) in
            self.activities.removeAll()
            if let activityIDDic = snapshot.value as? [String:Any]{
                let activityDic = activityIDDic
                
                print("111")
                let array = Array(activityDic.keys)
               
                for i in 0..<array.count {
                    let dic = activityDic[array[i]] as! [String:Any]
                    //print(dic)
                    let activity = Activity()
                    
                    guard let dateString = dic["date"] as? String else{
                        continue
                    }
                    
                    let date = manager.stringToDate(from: dateString)
                    activity.key = dic["key"] as! String
                    activity.name = dic["activityName"] as! String
                    activity.date = date
                    activity.creater = dic["creator"] as! String
                    activity.content = dic["content"] as! String
                    activity.address = dic["address"] as! String
                    activity.courtName = dic["courtName"] as! String
                    activity.latitue = dic["latitude"] as! Double
                    activity.longitue = dic["longitude"] as! Double
                    activity.peopleCounter = dic["peopleCounter"] as! Int
                    activity.participantCounter = dic["participateCounter"] as! Int
                    guard let array1 = dic["participates"] as? [Any] else{
                        continue
                    }
                    for j in 1..<array1.count{
                        print(array1[j] as! String)
                        activity.participates.append(array1[j] as! String)
                    }
                    activity.postTime = dic["postTime"] as! Double
                    self.activities.append(activity)
                    self.activities.sort(by: { (activity1, activity2) -> Bool in
                        activity1.postTime > activity2.postTime
                    })
                }
            }
        }
    }
    
    func loadMapData(){
        var ref : DatabaseReference!
        ref = Database.database().reference()
        ref.child("maps_basketball").observeSingleEvent(of: .value) { (snapshot) in
            for distdata in snapshot.children {
                guard let distSnapshot = distdata as? DataSnapshot else {
                    continue
                }
                let dist = distSnapshot.key
                
                //self.distList.append(dist)
                Manager.mapData.distList.append(dist)
            }
            for dist in Manager.mapData.distList {
                ref.child("maps_basketball").child(dist).observeSingleEvent(of: .value) { (snapshot) in
                    for courtdata in snapshot.children{
                        guard let courtSnapshot = courtdata as? DataSnapshot else{
                            continue
                        }
                        let court = courtSnapshot.key
                        //self.courtList.append(court)
                        Manager.mapData.courtList.append(court)
                    }
                    for court in Manager.mapData.courtList{
                        ref.child("maps_basketball").child(dist).child(court).child("coordinates").observeSingleEvent(of: .value) { (snapshot) in
                            
                            let coordinate = snapshot.value as? [String:Double]
                            let latitude = coordinate?["latitude"]
                            if latitude != nil{
                                //self.latitudeList.append(latitude!)
                                Manager.mapData.latitudeList.append(latitude!)
                            }
                            let longitude = coordinate?["longitude"]
                            if longitude != nil{
                                //self.longitudeList.append(longitude!)
                                Manager.mapData.longitudeList.append(longitude!)
                            }
                        }
                        ref.child("maps_basketball").child(dist).child(court).observeSingleEvent(of: .value) { (addsnapshot) in
                            guard addsnapshot.value != nil else {
                                return
                            }
                            let addressData = addsnapshot.value as? [String:Any]
                            let address = addressData?["address"]
                            if address != nil{
                                //self.addressList.append(address! as! String)
                                Manager.mapData.addressList.append(address! as! String)
                            }
                            
                        }
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                Manager.shared.saveToFile(fileName: "mapData.archive")
            })
        }
    }
    
    
    func stringToDate2(from:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 28400)
        let convertedDate = dateFormatter.date(from: from)
        return convertedDate!
    }
    
    func stringToDate(from:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 28400)
        let convertedDate = dateFormatter.date(from: from)
        return convertedDate!
    }
    
    func dateToString(_ date:Date, dateFormat:String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_TW")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: date)
        return date
    }
    
    //MARK: func - check file in app.
    func checkFile(fileName :String) -> Bool {
        let fileManager = FileManager.default
        let filePath = NSHomeDirectory()+"/Documents/"+fileName
        let exist = fileManager.fileExists(atPath: filePath)
        return exist
    }
    
    func saveToFile(fileName : String){
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent(fileName)
        do{
            //把[Note]轉乘data刑事
            let data = try NSKeyedArchiver.archivedData(withRootObject: Manager.mapData, requiringSecureCoding: false)
            //寫到檔案
            try data.write(to: fileURL, options: [.atomicWrite])
        }catch{
            print("error\(error)")
        }
        
    }
    func loadFromFile(fileName:String){
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent(fileName)
        do{
            //把檔案轉成Data形式
            let fileData = try Data(contentsOf: fileURL)
            //從Data轉回MapData陣列
            Manager.mapData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! MapData
        }catch{
            print("error\(error)")
        }
    }

}



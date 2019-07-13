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
import CoreData

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
        let moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let cloudFireStore = Firestore.firestore()
        cloudFireStore.collection("activities").order(by: "postTime", descending: true).getDocuments { (snapshot, error) in
            if let querySnapshot = snapshot {
                for document in querySnapshot.documents {
                    let activity = Activity(context: moc)
                    activity.key = document.get("key") as! String
                    activity.name = document.get("activityName") as! String
                    let dateString = document.get("date") as! String
                    let date = Manager.shared.stringToDate(from: dateString)
                    activity.date = date
                    activity.courtName = document.get("courtName") as! String
                    activity.latitue = document.get("latitude") as! Double
                    activity.longitue = document.get("longitude") as! Double
                    activity.address = document.get("address") as! String
                    activity.content = document.get("content") as! String
                    activity.creater = document.get("creator") as! String
                    activity.participantCounter = document.get("participateCounter") as! Int
                    activity.peopleCounter = document.get("peopleCounter") as! Int
                    activity.participants = document.get("participates") as! [String]
                    activity.postTime = document.get("postTime") as! Double
                    
                    appdelegate.saveContext()
                }
            }
        }
        UserDefaults.standard.set(Double(Date().timeIntervalSince1970), forKey: "lastUpdated")
        
    }
    func loadMoreActivities(){
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let cloudFireStore = Firestore.firestore()
    }
    
    func coreDataRemoveAll(){
        // delete
        let moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        
        do {
            let results =
                try moc.fetch(request)
                    as! [Activity]
            
            for result in results {
                moc.delete(result)
                do{
                    try moc.save()
                }catch{
                    fatalError("\(error)")
                }
            }
            
            
        } catch {
            fatalError("\(error)")
        }
    }
        
        
//            if let querySnapshot = snapshot {
//                for document in querySnapshot.documentChanges {
//
//                    let activity = Activity(context: moc)
//                    activity.key = document.document.get("key") as! String
//                    activity.name = document.document.get("activityName") as! String
//                    let dateString = document.document.get("date") as! String
//                    let date = Manager.shared.stringToDate(from: dateString)
//                    activity.date = date
//                    activity.courtName = document.document.get("courtName") as! String
//                    activity.latitue = document.document.get("latitude") as! Double
//                    activity.longitue = document.document.get("longitude") as! Double
//                    activity.address = document.document.get("key") as! String
//                    activity.content = document.document.get("content") as! String
//                    activity.creater = document.document.get("creator") as! String
//                    activity.participantCounter = document.document.get("participateCounter") as! Int
//                    activity.peopleCounter = document.document.get("peopleCounter") as! Int
//                    activity.participants = document.document.get("participates") as! [String]
//                    activity.postTime = document.document.get("postTime") as! Double
//                    print("added")
//                    appdelegate.saveContext()
//                }
//            }
        
    
    
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
    
    func checkSQLite() -> Bool {
        let fileManager = FileManager.default
        let filePath = NSHomeDirectory()+"/Library/Application Support/Sweater.sqlite"
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
    
    func getCurrentUserData(){
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        UserDefaults.standard.set(uid, forKey: "uid")
    }
    
    
    func updateActivity (key : String, count : Int, uids : [String]) {
        let moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        request.predicate = NSPredicate(format:"(key = %@)", (key))
            
            do {
                let results = try moc.fetch(request)  as! [Activity]
                
                if results.count > 0 {
                    
                    results[0].participantCounter = count
                    results[0].participants.removeAll()
                    for uid in uids{
                        results[0].participants.append(uid)
                    }
                    
                    do {
                        try moc.save()
                    }catch  let error as NSError {
                        print("\(error)")
                    }
                    
                }
            } catch {
                fatalError("\(error)")
            }
        
    }
    
    func loadMyActivityFromCoreData() -> [Activity]{
        var activities = [Activity]()
        let uid = UserDefaults.standard.string(forKey: "uid")!
        let moc = (UIApplication.shared.delegate as! AppDelegate).managedObjectContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        do{
            let results = try moc.fetch(request) as! [Activity]
            if results.count > 0 {
                for result in results{
                    if result.participants.contains(uid){
                        activities.append(result)
                    }
                }
            }
        }catch{
            fatalError()
        }
        return activities
    }
    
}



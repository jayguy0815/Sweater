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
    static var accounts = [Account]()
    static var shared = Manager()
    static var mapData = MapData()
    var ref : DatabaseReference!
    
    func loadImage(ref : StorageReference , imageName : String) -> Data{
        
        var newData = UIImage(named: "defaultAccountImage")!.jpegData(compressionQuality: 1)!
        ref.child("\(imageName).jpg").getData(maxSize: 1*1024*1024, completion: { (data, error) in
            if let error = error {
                print("*** ERROR DOWNLOAD IMAGE : \(error)")
            } else {
                
                    if let imageData = data {
                        newData = imageData
                    }
                
            }
        })
        return newData
    }
    
    func timeIntervaltoDatetoString(timeInterval : TimeInterval, format : String) -> String{
        let date = Date(timeIntervalSince1970: timeInterval)
        let df = DateFormatter()
        df.dateFormat = format
        let dateString = df.string(from: date)
        return dateString
    }
    
    
    func checkAuthState(uid:String, vc : AuthTestViewController){
        Firestore.firestore().collection("user_data").document(uid).getDocument { (snapshot, error) in
            if let err = error{
                print(err)
            }
            guard let userData = snapshot?.data() else{
                return
            }
            let state = userData["issignin"] as! Bool
            if state == true{
                let alert =  UIAlertController(title: "Oops", message: "您已重複登入", preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .default, handler: { (_) in
                    do{
                       try Auth.auth().signOut()
                    }catch{
                        fatalError()
                    }
                })
                alert.addAction(action)
                vc.present(alert,animated: true, completion: nil)
            }else{
               
                let nickname = userData["nickname"] as! String
                let hobby = userData["hobby"] as! String
                Storage.storage().reference().child("account").child("\(uid).jpg").getData(maxSize: 1*800*800, completion: { (data, error) in
                    if let err = error{
                        print(err)
                    }
                    guard let imagedata = data else{
                        return
                    }
                    UserDefaults.standard.set(imagedata, forKey: "profileImageData")
                })
                UserDefaults.standard.set(uid, forKey: "uid")
                UserDefaults.standard.set(nickname, forKey: "nickname")
                
                UserDefaults.standard.set(hobby, forKey: "hobby")
                Firestore.firestore().collection("user_data").document(uid).updateData(["issignin" : true])
                let alert =  UIAlertController(title: "成功", message: "登入成功", preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .default, handler: { (_) in
                    vc.dismiss(animated: true, completion: nil)
                })
                alert.addAction(action)
                vc.present(alert,animated: true, completion: nil)
            }
        }
    }
    
    
    func loadUserData(){
        let fireRef = Firestore.firestore().collection("user_data")
        let storageRef = Storage.storage().reference().child("account")
        
        fireRef.getDocuments { (snapshot, error) in
            if let error = error {
                print(error)
            }
            guard let users = snapshot?.documents else{
                print("failed to get user documents!")
                return
            }
            for user in users{
                
                Storage.storage().reference().child("account").child("\(user.data()["uid"] as! String).jpg").getData(maxSize: 1*800*800, completion: { (data, error) in
                    if let error = error {
                        print("*** ERROR DOWNLOAD IMAGE : \(error)")
                    } else {
                        let account = Account(context: CoreDataHelper.shared.managedObjectContext())
                        account.uid = user.data()["uid"] as! String
                        account.name = user.data()["username"] as! String
                        account.nickname = user.data()["nickname"] as! String
                        account.hobby = user.data()["hobby"] as! String
                        account.email = user.data()["email"] as! String
                        account.accountImageURL = user.data()["accountImageURL"] as! String
                        if let imageData = data {
                            account.image = imageData
                        }
//                        account.image = Manager.shared.loadImage(ref: storageRef, imageName: user.documentID)
                        account.postTime = user.data()["postTime"] as! Double
                        account.modifiedTime = user.data()["modifiedTime"] as! Double
                        print("account saved")
                        CoreDataHelper.shared.saveContext()
                    }
                })
                
            }
            Manager.accounts = Manager.shared.queryAccountFromCoreData()
        }
    }
    
    
    
    func loadActivities() {
        let cloudFireStore = Firestore.firestore()
        cloudFireStore.collection("activities").order(by: "postTime", descending: true).getDocuments { (snapshot, error) in
            if let querySnapshot = snapshot {
                for document in querySnapshot.documents {
                    let activity = Activity(context: CoreDataHelper.shared.managedObjectContext())
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
                    activity.modifiedTime = document.get("modifiedTime") as! Double
                    CoreDataHelper.shared.saveContext()
                }
            }
        }
        UserDefaults.standard.set(Double(Date().timeIntervalSince1970), forKey: "lastUpdated")
    }
   
    func coreDataRemoveAll(){
        // delete
        let moc = CoreDataHelper.shared.managedObjectContext()
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
    
    func dateToString2(_ date:Date, dateFormat:String = "yyyy-MM-dd HH:mm:ss Z") -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 28800)
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
    
    func addAccount(diff : DocumentChange){
        Storage.storage().reference().child("account").child("\(diff.document.documentID).jpg").getData(maxSize: 1*800*800, completion: { (data, error) in
            if let error = error {
                print("*** ERROR DOWNLOAD IMAGE : \(error)")
            } else {
                let account = Account(context: CoreDataHelper.shared.managedObjectContext())
                account.uid = diff.document.data()["uid"] as! String
                account.name = diff.document.data()["username"] as! String
                account.nickname = diff.document.data()["nickname"] as! String
                account.hobby = diff.document.data()["hobby"] as! String
                account.email = diff.document.data()["email"] as! String
                account.accountImageURL = diff.document.data()["accountImageURL"] as! String
                if let imageData = data {
                    account.image = imageData
                }
                account.postTime = diff.document.data()["postTime"] as! Double
                account.modifiedTime = diff.document.data()["modifiedTime"] as! Double
                print("account saved")
                CoreDataHelper.shared.saveContext()
            }
        })
    }
    
    func addActivity(diff : DocumentChange){
        let activity = Activity(context: CoreDataHelper.shared.managedObjectContext())
        activity.key = diff.document.get("key") as! String
        activity.name = diff.document.get("activityName") as! String
        let dateString = diff.document.get("date") as! String
        let date = Manager.shared.stringToDate(from: dateString)
        activity.date = date
        activity.courtName = diff.document.get("courtName") as! String
        activity.latitue = diff.document.get("latitude") as! Double
        activity.longitue = diff.document.get("longitude") as! Double
        activity.address = diff.document.get("address") as! String
        activity.content = diff.document.get("content") as! String
        activity.creater = diff.document.get("creator") as! String
        activity.participantCounter = diff.document.get("participateCounter") as! Int
        activity.peopleCounter = diff.document.get("peopleCounter") as! Int
        activity.participants = diff.document.get("participates") as! [String]
        activity.postTime = diff.document.get("postTime") as! Double
        CoreDataHelper.shared.saveContext()
    }
    
    func updateAccount(uid : String, nickname : String, hobby : String, url : String){
        
        let storageRef = Storage.storage().reference().child("account")
        storageRef.child("\(uid).jpg").getData(maxSize: 1*800*800) { (data, error) in
            if let err = error{
                print(err)
            }
            if let imgdata = data{
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
                request.predicate = NSPredicate(format:"(uid = %@)", (uid))
                
                do {
                    let results = try CoreDataHelper.shared.managedObjectContext().fetch(request)  as! [Account]
                    
                    if results.count > 0 {
                        results[0].nickname = nickname
                        results[0].hobby = hobby
                        if url != results[0].accountImageURL{
                            results[0].image = imgdata
                            results[0].accountImageURL = url
                        }
                        CoreDataHelper.shared.saveContext()
                    }
                } catch {
                    fatalError("\(error)")
                }
            }
            
        }
        
        
       
        
    }
    
    func updateActivity (key : String, count : Int, uids : [String]) {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        request.predicate = NSPredicate(format:"(key = %@)", (key))
            
            do {
                let results = try CoreDataHelper.shared.managedObjectContext().fetch(request)  as! [Activity]
                
                if results.count > 0 {
                    
                    results[0].participantCounter = count
                    results[0].participants.removeAll()
                    for uid in uids{
                        results[0].participants.append(uid)
                    }
                    CoreDataHelper.shared.saveContext()
                    
                }
            } catch {
                fatalError("\(error)")
            }
        
    }
    
    func removeActivity(key : String){
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        request.predicate = NSPredicate(format:"(key = %@)", (key))
        
        do {
            let results = try CoreDataHelper.shared.managedObjectContext().fetch(request)  as! [Activity]
            
            for result in results{
                CoreDataHelper.shared.managedObjectContext().delete(result)
            }
            CoreDataHelper.shared.saveContext()
        } catch {
            fatalError("\(error)")
        }
    }
    
    func dailyRemove(){
        let currentActivities = Manager.shared.queryActivityFromCoreData()
        for activity in currentActivities{
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: activity.date)
            if tomorrow! < Date(){
                Firestore.firestore().collection("activities").document(activity.key).delete { (error) in
                    if let err = error {
                        print("Error removing document: \(err)")
                    } else {
                        print("Document successfully removed!")
                    }
                }
            }
        }
    }
    
    func loadMyActivityFromCoreData() -> [Activity]{
        var activities = [Activity]()
        let uid = Auth.auth().currentUser?.uid
        let moc = CoreDataHelper.shared.managedObjectContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        do{
            let results = try moc.fetch(request) as! [Activity]
            if results.count > 0 {
                for result in results{
                    if result.participants.contains(uid!){
                        activities.append(result)
                        activities.sort { (a1, a2) -> Bool in
                            a1.postTime>a2.postTime
                        }
                    }
                }
            }
        }catch{
            fatalError()
        }
        return activities
    }
    
    func setNavigationBar() -> UIView {
        //your custom view for back image with custom size
        let view = UIView(frame: CGRect(x: -5, y: 10, width: 50, height: 60))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 11, width: 20, height: 20))
        if let imgBackArrow = UIImage(named: "backArrowIcon") {
            imageView.image = imgBackArrow
        }
        view.addSubview(imageView)
        let text = UILabel(frame: CGRect(x: 20, y: 1, width: 60, height: 40))
        text.text = "返回"
        text.font = text.font.withSize(17)
        //        text.font = text.font.withSize(20)
        text.textColor = UIColor.white
        view.addSubview(text)
        
        return view
    }
    
    func accountListener() -> ListenerRegistration{
        let listener = Firestore.firestore().collection("user_data").whereField("modifiedTime", isGreaterThan: UserDefaults.standard.double(forKey: "lastLoadModifiedTime")).addSnapshotListener { (snapshot, error) in
            let accounts = Manager.shared.queryAccountFromCoreData()
            if let err = error {
                print(err)
            }
            guard let documents = snapshot else {
                return
            }
            documents.documentChanges.forEach({ (diff) in
                if diff.type == .added{
                    let postTime = diff.document.get("postTime") as! Double
                    let updateTime = UserDefaults.standard.double(forKey: "lastLoadModifiedTime")
                    let id = diff.document.documentID
                    for account in accounts{
                        if id == account.uid{
                            let modTime = diff.document.get("modifiedTime") as! Double
                            if updateTime < modTime{
                                let url = diff.document.get("accountImageURL") as! String
                                let nickname = diff.document.get("nickname") as! String
                                let hobby = diff.document.get("hobby") as! String
                                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                                    Manager.shared.updateAccount(uid: id, nickname: nickname, hobby: hobby, url: url)
                                })
                                print("user: \(id) modified")
                                
                            }
                        }
                    }
                    if postTime > updateTime {
                        print("user:\(id) added")
                        Manager.shared.addAccount(diff: diff)
                    }
                }
                else if diff.type == .modified{
                    let url = diff.document.get("accountImageURL") as! String
                    let nickname = diff.document.get("nickname") as! String
                    let hobby = diff.document.get("hobby") as! String
                    Manager.shared.updateAccount(uid: diff.document.documentID, nickname: nickname, hobby: hobby, url: url)
                    print("user: \(diff.document.documentID) modified")
                }
            })
            Manager.accounts = Manager.shared.queryAccountFromCoreData()
        }
        return listener
    }
    
    func activityListener() -> ListenerRegistration{
       
        let listener = Firestore.firestore().collection("activities").whereField("modifiedTime", isGreaterThan: UserDefaults.standard.double(forKey: "lastLoadModifiedTime")).addSnapshotListener({ (snapshot, error) in
            print("activity listening")
            let activities = Manager.shared.queryActivityFromCoreData()
            
            if let err = error {
                print(err)
            }
            guard let documents = snapshot else {
                return
            }
            documents.documentChanges.forEach({ (diff) in
                let fileManager = FileManager()
                let filePath = NSHomeDirectory()+"/Documents/"+diff.document.documentID+".archive"
                if diff.type == .added{
                    let id = diff.document.documentID
                    let postTime = diff.document.get("postTime") as! Double
                    let updateTime = UserDefaults.standard.double(forKey: "lastLoadModifiedTime")
                    for activity in activities{
                        if id == activity.key{
                            let modTime = diff.document.get("modifiedTime") as! Double
                            let dateString = diff.document.get("date") as! String
                            let date = Manager.shared.stringToDate(from: dateString)
                            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)
                            if tomorrow! < Date(){
                                Manager.shared.removeActivity(key: diff.document.documentID)
                                if Manager.shared.checkFile(fileName: "\(activity.key).archive") == true{
                                    do{
                                        try fileManager.removeItem(atPath: filePath)
                                    }catch{
                                        print("no such file")
                                    }
                                }
                            }else {
                                if updateTime < modTime{
                                    let uidArray = diff.document.get("participates") as! [String]
                                    let count = diff.document.get("participateCounter") as! Int
                                    print("modified")
                                    Manager.shared.updateActivity(key: diff.document.documentID, count: count, uids: uidArray)
                                }
                            }
                        }
                    }
                    if postTime > updateTime {
                        print("added")
                        Manager.shared.addActivity(diff: diff)
                    }
                }
                if diff.type == .modified{
                    let uidArray = diff.document.get("participates") as! [String]
                    let count = diff.document.get("participateCounter") as! Int
                    print("modified")
                    Manager.shared.updateActivity(key: diff.document.documentID, count: count, uids: uidArray)
                }
                if diff.type == .removed{
                    let key = diff.document.documentID
                    print("removed")
                    Manager.shared.removeActivity(key: key)
                    if Manager.shared.checkFile(fileName: "\(diff.document.documentID).archive") == true{
                        do{
                            try fileManager.removeItem(atPath: filePath)
                        }catch{
                            print("no such file")
                        }
                    }
                }
            })
        })
        
        return listener
    }
    
    func queryActivityFromCoreData()->[Activity]{
        var activities = [Activity]()
        let moc = CoreDataHelper.shared.managedObjectContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        do{
            let results = try moc.fetch(request) as! [Activity]
            if results.count > 0 {
                for result in results{
                        activities.append(result)
                    }
                }
        }catch{
            fatalError()
        }
        return activities
    }
    
    func queryAccountFromCoreData()->[Account]{
        var accounts = [Account]()
        let moc = CoreDataHelper.shared.managedObjectContext()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        do{
            let results = try moc.fetch(request) as! [Account]
            if results.count > 0 {
                for result in results{
                    accounts.append(result)
                }
            }
        }catch{
            fatalError()
        }
        return accounts
    }
    
    func saveMessage(key : String , messages : [Message]){
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("\(key).archive")
        do{
            //把[Note]轉成Data型式
            let data = try NSKeyedArchiver.archivedData(withRootObject: messages, requiringSecureCoding: false)
            //寫到檔案
            try data.write(to: fileURL, options: [.atomicWrite])
            
        }catch{
            print("error \(error)")
        }
    }
    
    func loadMessage(key : String) -> [Message]{
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("\(key).archive")
        
        var messages : [Message] = []
        do{
            //把檔案轉成Data型式
            let fileData = try Data(contentsOf: fileURL)
            //從Data轉回Note陣列
            do {
                messages = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! [Message]
            }catch{
                print("error2 \(error)")
            }
        }
        catch{
            print("error \(error)")
        }
        return messages
    }
    
}



//
//  AppDelegate.swift
//  Sweater
//
//  Created by Leo Huang on 2019/4/23.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import FirebaseAuth
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var ref : DatabaseReference!
    var methods : Methods!
   
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        ref = Database.database().reference()
        
        ref.child("activities").observe(.value) { (snapshot) in
            if let activityIDDic = snapshot.value as? [String:Any]{
                let activityDic = activityIDDic
                print(activityDic)
                let array = Array(activityDic.keys)
                print(array)
                for i in 0..<array.count {
                    let dic = activityDic[array[i]] as! [String:Any]
                    print(dic)
                    let activity = Activity()
                    
                    guard let dateString = dic["date"] as? String else{
                        continue
                    }
                    
                    let date = Activity.shared.convertdate(from: dateString)
                    activity.name = dic["activityName"] as! String
                    activity.date = date
                    activity.creater = dic["creator"] as! String
                    activity.content = dic["content"] as! String
                    activity.address = dic["address"] as! String
                    activity.courtName = dic["courtName"] as! String
                    activity.latitue = dic["latitude"] as! Double
                    activity.longitue = dic["longitude"] as! Double
                    activity.peopleCounter = dic["peopleCounter"] as! Int
                    activity.participantCounter = 1
                    Activity.shared.activities.append(activity)
                }
            }
        }
        
        
        ref.child("maps_basketball").observeSingleEvent(of: .value) { (snapshot) in
            for distdata in snapshot.children {
                guard let distSnapshot = distdata as? DataSnapshot else {
                    continue
                }
                let dist = distSnapshot.key
                
                //self.distList.append(dist)
                MapData.shared.distList.append(dist)
            }
            for dist in MapData.shared.distList {
                self.ref.child("maps_basketball").child(dist).observeSingleEvent(of: .value) { (snapshot) in
                    for courtdata in snapshot.children{
                        guard let courtSnapshot = courtdata as? DataSnapshot else{
                            continue
                        }
                        let court = courtSnapshot.key
                        //self.courtList.append(court)
                        MapData.shared.courtList.append(court)
                    }
                    for court in MapData.shared.courtList{
                        self.ref.child("maps_basketball").child(dist).child(court).child("coordinates").observeSingleEvent(of: .value) { (snapshot) in
                            
                            let coordinate = snapshot.value as? [String:Double]
                            let latitude = coordinate?["latitude"]
                            if latitude != nil{
                                //self.latitudeList.append(latitude!)
                                MapData.shared.latitudeList.append(latitude!)
                            }
                            let longitude = coordinate?["longitude"]
                            if longitude != nil{
                                //self.longitudeList.append(longitude!)
                                MapData.shared.longitudeList.append(longitude!)
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
                                MapData.shared.addressList.append(address! as! String)
                            }
                            
                        }
                    }
                }
            }
        }
        //methods.saveToFile()
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


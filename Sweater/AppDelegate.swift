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
import CoreData

protocol AppDelegateDelegate{
    func didEnterBackground()
    func didEnterForeground()
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    var activities : [Activity] = []
    var accounts : [Account] = []
    var activityListener : ListenerRegistration?
    var accountListner : ListenerRegistration?
    var maplistener : ListenerRegistration?
    var delegate : AppDelegateDelegate?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
//        UINavigationBar.appearance().barTintColor = UIColor(red: 234.0/255.0, green: 46.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        print(NSHomeDirectory())
        //let moc = CoreDataHelper.shared.managedObjectContext()
//        Auth.auth().addStateDidChangeListener() { auth, user in
//            if user == nil {
//                return
//            } else {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil{
                 Manager.shared.getCurrentUserData()
            }
        }

        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore == false{
            Manager.shared.fireStoreMap()
            Database.database().reference().child("mapdata").observeSingleEvent(of: .value) { (snapshot) in
                guard let mapdata = snapshot.value else {
                    return
                }
            }
            if let uid = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("user_data").document(uid).updateData(["issignin":false]) { (error) in
                    if let err = error{
                        print(err)
                    }
                    do{
                        try Auth.auth().signOut()
                    }catch{
                        print(error)
                    }
                }
               
            }

            Manager.shared.loadActivities()
            Manager.shared.loadUserData()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            UserDefaults.standard.set(Double(Date().timeIntervalSince1970)+Double(2), forKey: "lastLoadModifiedTime")
        }
        
        self.activities = Manager.shared.queryActivityFromCoreData()
        self.accounts = Manager.shared.queryAccountFromCoreData()
        self.activityListener = Manager.shared.activityListener()
        self.accountListner = Manager.shared.accountListener()
        
        
        
       
//        self.maplistener = Database.database().reference().child("mapdata")


        
        if Manager.shared.checkFile(fileName: "mapData.archive") == false {
            Manager.shared.loadMapData()
        } else if Manager.shared.checkFile(fileName: "mapData.archive") == true {
            Manager.shared.loadFromFile(fileName: "mapData.archive")
        
        
        }
        


        return true
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
//       self.activityListener?.remove()
//        self.isFirstLoad = true
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        //self.activityListener?.remove()
        //UserDefaults.standard.set(true, forKey: "isFirstLoadModified")
        self.delegate?.didEnterBackground()
        self.activityListener?.remove()
        self.accountListner?.remove()
        UserDefaults.standard.set(Double(Date().timeIntervalSince1970), forKey: "lastLoadModifiedTime")
//        do{
//            try Auth.auth().signOut()
//        }catch{
//            print(error)
//        }
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        self.delegate?.didEnterForeground()
        self.activityListener = Manager.shared.activityListener()
        self.accountListner = Manager.shared.accountListener()
    }
        
        

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.activityListener?.remove()
        self.accountListner?.remove()
        UserDefaults.standard.set(Double(Date().timeIntervalSince1970), forKey: "lastLoadModifiedTime")
        CoreDataHelper.shared.saveContext()
    }
}
    


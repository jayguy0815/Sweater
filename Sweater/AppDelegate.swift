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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var methods = Methods()
    
    var isFirstLoad = true
    
    var isFirstLoadModified = true
    var activities = [Activity]()
    var activityListener : ListenerRegistration?
    var modifiedListner : ListenerRegistration?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        IQKeyboardManager.shared.enable = true
        
        print(NSHomeDirectory())
        let moc = self.managedObjectContext()
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user == nil {
                return
            } else {
                Manager.shared.getCurrentUserData()
                let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
                if launchedBefore == false {
                    Manager.shared.loadActivities()
                    UserDefaults.standard.set(true, forKey: "launchedBefore")
                }
                Firestore.firestore().collection("activities").whereField("postTime", isGreaterThan: UserDefaults.standard.double(forKey:"lastUpdated")).getDocuments{ (snapshot, error) in
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
                            print("load1")
                            self.saveContext()
                        }
                    }
                    UserDefaults.standard.set(Double(Date().timeIntervalSince1970), forKey: "lastUpdated")
                }
                let moc = self.managedObjectContext()
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
                
                
                self.activityListener = Firestore.firestore().collection("activities").addSnapshotListener({ (snapshot, error) in
                    guard let Querysnapshot = snapshot else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    print("a: \(Querysnapshot.documentChanges.count)")
                    Querysnapshot.documentChanges.forEach({ diff in
                        if diff.type == .added{
                            if self.isFirstLoad == true{
                                for i in 0..<self.activities.count{
                                    if diff.document.documentID == self.activities[i].key{
                                        if (diff.document.get("participateCounter") as! Int) != self.activities[i].participantCounter{
                                            print("founded")
                                            let uidArray = diff.document.get("participates") as! [String]
                                            let count = diff.document.get("participateCounter") as! Int
                                            Manager.shared.updateActivity(key: diff.document.documentID, count: count, uids: uidArray)
                                        }
                                    }
                                }
                            }
                            else {
                                let activity = Activity(context: self.managedObjectContext())
                                activity.key = diff.document.get("key") as! String
                                activity.name = diff.document.get("activityName") as! String
                                let dateString = diff.document.get("date") as! String
                                let date = Manager.shared.stringToDate(from: dateString)
                                activity.date = date
                                activity.courtName = diff.document.get("courtName") as! String
                                activity.latitue = diff.document.get("latitude") as! Double
                                activity.longitue = diff.document.get("longitude") as! Double
                                activity.address = diff.document.get("key") as! String
                                activity.content = diff.document.get("content") as! String
                                activity.creater = diff.document.get("creator") as! String
                                activity.participantCounter = diff.document.get("participateCounter") as! Int
                                activity.peopleCounter = diff.document.get("peopleCounter") as! Int
                                activity.participants = diff.document.get("participates") as! [String]
                                activity.postTime = diff.document.get("postTime") as! Double
                                print("added")
                                self.saveContext()
                            }

                        }
                        if diff.type == .modified{
                            let uidArray = diff.document.get("participates") as! [String]
                            let count = diff.document.get("participateCounter") as! Int
                            print("modified")
                            Manager.shared.updateActivity(key: diff.document.documentID, count: count, uids: uidArray)
                        }
                    })
                })
                    UserDefaults.standard.set(Double(Date().timeIntervalSince1970), forKey: "lastUpdated")
//                    let timeInterval:TimeInterval = Date().timeIntervalSince1970
//                    let lastUpdateActivityTime = Double(timeInterval)
//                    UserDefaults.standard.setValue(lastUpdateActivityTime, forKeyPath: "activiyLastUpdateTime")
//                    self.isFirstLoad = false
                Manager.shared.loadUserData()
                
                if Manager.shared.checkFile(fileName: "mapData.archive") == false {
                    Manager.shared.loadMapData()
                } else if Manager.shared.checkFile(fileName: "mapData.archive") == true {
                    Manager.shared.loadFromFile(fileName: "mapData.archive")
                }
                
            }
        }
        return true
    }
        
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
        self.activityListener?.remove()
        self.isFirstLoad = true
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }
    
    func managedObjectContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Sweater")
        //let description = NSPersistentStoreDescription()
        //設定sqlite存放位置
//        var sqlUrl = URL(fileURLWithPath: NSHomeDirectory())
//        sqlUrl.appendPathComponent("Documents")
//        sqlUrl.appendPathComponent("sweater.sqlite")
//        description.url = sqlUrl
        //如果要關閉journal mode，只產生一個sqlite檔案，可以打開這個選項
        //description.setOption(["journal_mode":"DELETE"] as NSDictionary, forKey: NSSQLitePragmasOption)
//        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    


}


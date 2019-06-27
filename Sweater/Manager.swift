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
    var activities = [Activity]()
    static var shared = Manager()
    var ref : DatabaseReference!
    
    func loadActivities() {
        let manager = Manager()
        activities.removeAll()
        ref = Database.database().reference()
        ref.child("activities").queryOrdered(byChild: "postTime").observeSingleEvent(of: .value)  { (snapshot) in
            if let activityIDDic = snapshot.value as? [String:Any]{
                let activityDic = activityIDDic
                
                print("111")
                let array = Array(activityDic.keys)
                print(array)
                for i in 0..<array.count {
                    let dic = activityDic[array[i]] as! [String:Any]
                    //print(dic)
                    let activity = Activity()
                    
                    guard let dateString = dic["date"] as? String else{
                        continue
                    }
                    
                    let date = manager.convertDate(from: dateString)
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
                    activity.postTime = dic["postTime"] as! Double
                    self.activities.append(activity)
                    self.activities.sort(by: { (activity1, activity2) -> Bool in
                        activity1.postTime > activity2.postTime
                        
                    })
                }
            }
        }
        
    }
    
    func convertDate(from:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 28400)
        let convertedDate = dateFormatter.date(from: from)
        return convertedDate!
    }
}

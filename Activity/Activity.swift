//
//  Activity.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/20.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import Foundation
import Firebase

class Activity {
    static var shared = Activity()
    var activities = [Activity]()
    var name : String = ""
    var date : Date = Date()
    var creater : String = ""
    var participants : [String] = []
    var courtName : String = ""
    var latitue : Double = 0.0
    var longitue : Double = 0.0
    var address : String = ""
    var peopleCounter : Int = 0
    var content : String = ""
    var participantCounter = 1
    
    func convertdate(from:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 28400)
        let convertedDate = dateFormatter.date(from: from)
        return convertedDate!
    }
}

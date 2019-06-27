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
    var postTime : Double = 0.0
    
}

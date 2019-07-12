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
    
    var key : String = ""
    var name : String = ""
    var date : Date = Date()
    var creater : String = ""
    var participates : [String] = []
    var courtName : String = ""
    var address : String = ""
    var content : String = ""
    var latitue : Double = 0.0
    var longitue : Double = 0.0
    var peopleCounter : Int = 0
    var participantCounter : Int = 0
    var postTime : Double = 0.0
    
}

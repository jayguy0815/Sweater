//
//  Activity.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/20.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import Foundation
import Firebase
import CoreData

class Activity : NSManagedObject{
    
    @NSManaged var key : String
    @NSManaged var name : String
    @NSManaged var date : Date
    @NSManaged var creater : String
    @NSManaged var participants : [String]
    @NSManaged var courtName : String
    @NSManaged var address : String
    @NSManaged var content : String
    @NSManaged var latitue : Double
    @NSManaged var longitue : Double
    @NSManaged var peopleCounter : Int
    @NSManaged var participantCounter : Int
    @NSManaged var postTime : Double
    
}

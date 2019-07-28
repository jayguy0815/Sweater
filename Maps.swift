//
//  Maps.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/25.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import Foundation
import Firebase
import CoreData
import CoreLocation

class Maps : NSManagedObject{
    @NSManaged var dist : String
    @NSManaged var name : String
    @NSManaged var latitude : Double
    @NSManaged var longitude : Double
    @NSManaged var address : String
    @NSManaged var type : String
}

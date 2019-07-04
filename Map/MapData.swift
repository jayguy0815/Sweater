//
//  MapData.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/18.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MapKit
import CoreLocation

class MapData : NSObject,NSCoding {
    
    
    
    required init?(coder aDecoder: NSCoder) {
        self.distList = aDecoder.decodeObject(forKey: "distList") as! [String]
        //noteid必須先有值才能呼叫super
        super.init()
        self.courtList = aDecoder.decodeObject(forKey: "courtList") as! [String]
        self.latitudeList = aDecoder.decodeObject(forKey: "latitudeList") as! [Double]
        self.longitudeList = aDecoder.decodeObject(forKey: "longitudeList") as! [Double]
        self.addressList = aDecoder.decodeObject(forKey: "address") as! [String]
    }
    override init() {
        
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.distList, forKey: "distList")
        aCoder.encode(self.courtList, forKey: "courtList")
        aCoder.encode(self.latitudeList, forKey: "latitudeList")
        aCoder.encode(self.longitudeList, forKey: "longitudeList")
        aCoder.encode(self.addressList, forKey: "address")
    }
    
    var distList : [String] = []
    var courtList : [String] = []
    var latitudeList : [Double] = []
    var longitudeList : [Double] = []
    var addressList : [String] = []
}

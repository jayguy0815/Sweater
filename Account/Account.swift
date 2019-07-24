//
//  Account.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/10.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Account : NSManagedObject , Comparable{
    static func < (lhs: Account, rhs: Account) -> Bool {
        return lhs.modifiedTime < rhs.modifiedTime
    }
    
    static func == (lhs: Account, rhs: Account) -> Bool {
        return lhs.accountImageURL == rhs.accountImageURL
    }
    
    @NSManaged var accountImageURL : String
    @NSManaged var uid : String
    @NSManaged var nickname : String
    @NSManaged var email : String
    @NSManaged var image : Data
    @NSManaged var name : String
    @NSManaged var hobby : String
    @NSManaged var postTime : Double
    @NSManaged var modifiedTime : Double
}

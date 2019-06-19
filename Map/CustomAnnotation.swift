//
//  CustomAnnotation.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/19.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import Foundation
import MapKit

class customAnnotation : MKPointAnnotation{
    var Id : String = ""
}

extension DispatchQueue {
    private static var _onceTokens = [String]()
    public class func once(token: String, block:()->Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if _onceTokens.contains(token) {
            return
        }
        _onceTokens.append(token)
        block()
    }
}

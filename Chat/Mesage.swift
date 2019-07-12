//
//  Mesage.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/4.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import Foundation
import UIKit
import MessageKit
import Firebase






struct Message : Comparable , MessageType{
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.postTime < rhs.postTime
    }
    
   
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
  
    var senderID : String
    let senderName : String
    let text: String
    let sendTime : Date
    var messageId : String
    var postTime : Double
 
    
    
    var sender: SenderType {
        return Sender(id: senderID, displayName: senderName)
    }

    var sentDate: Date {
        return Date()
    }
    
    var kind: MessageKind {
        
        
        return .text(text)

    }
}
//
//extension Message: DatabaseRepresentation {
//
//    var representation: [String : Any] {
//        var rep: [String : Any] = [
//            "created": sentDate,
//            "senderID": sender.senderId,
//            "senderName": sender.displayName
//        ]
//        return rep
//    }
//
//}

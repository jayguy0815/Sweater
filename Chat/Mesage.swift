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
import CoreData


class Message : NSObject, NSCoding, Comparable , MessageType{
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.text, forKey: "text")
        aCoder.encode(self.senderID, forKey: "senderID")
        aCoder.encode(self.senderName, forKey: "senderName")
        aCoder.encode(self.sendTime, forKey: "sendTime")
        aCoder.encode(self.messageId, forKey: "messageId")
        aCoder.encode(self.postTime, forKey: "postTime")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.senderID = aDecoder.decodeObject(forKey: "senderID") as? String
        //noteid必須先有值才能呼叫super
        super.init()
        self.text = aDecoder.decodeObject(forKey: "text") as? String
        self.senderName = aDecoder.decodeObject(forKey: "senderName") as? String
        self.sendTime = aDecoder.decodeObject(forKey: "sendTime") as? Date
        self.messageId = (aDecoder.decodeObject(forKey: "messageId") as? String)!
        self.postTime = aDecoder.decodeObject(forKey: "postTime") as? Double
    }
    
    override init() {
        
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.postTime! < rhs.postTime!
    }
    
   
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
  
     var senderID : String?
     var senderName : String?
     var text: String?
     var sendTime : Date?
     var messageId : String = UUID().uuidString
     var postTime : Double?
 
    
    
    var sender: SenderType {
        return Sender(id: senderID!, displayName: senderName!)
    }

    var sentDate: Date {
        return Date()
    }
    
    var kind: MessageKind {
        
        
        return .text(text!)

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

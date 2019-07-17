//
//  Method.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/15.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import Foundation
import UIKit
import Firebase


class Methods{
    var ref : DatabaseReference!
    
    
    func newAlert(Title : String, Message : String, actionTitle : String) -> UIAlertController{
        let alert = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: actionTitle, style: .cancel, handler: nil)
        alert.addAction(defaultAction)
        return alert
    }
    
    func getDate()->String{
        // 獲取當前時間
        let now:Date = Date()
        // 建立時間格式
        let dateFormat:DateFormatter = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd HH:mm"
        // 將當下時間轉換成設定的時間格式
        let dateString : String = dateFormat.string(from: now)
        
        return dateString
    }
    
    //MARK: func - check file in app.
    func checkFile(fileName :String) -> Bool {
        let fileManager = FileManager.default
        let filePath = NSHomeDirectory()+"/Documents/"+fileName
        let exist = fileManager.fileExists(atPath: filePath)
        return exist
    }
    
    func saveToFile(){
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("MapData.archive")
        do{
            //把[Note]轉乘data刑事
            let data = try NSKeyedArchiver.archivedData(withRootObject: Manager.mapData, requiringSecureCoding: false)
            //寫到檔案
            try data.write(to: fileURL, options: [.atomicWrite])
        }catch{
            print("error\(error)")
        }
        
    }
    func loadFromFile(){
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("MapData.archive")
        do{
            //把檔案轉成Data形式
            let fileData = try Data(contentsOf: fileURL)
            //從Data轉回MapData陣列
            Manager.mapData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! MapData
        }catch{
            print("error\(error)")
        }
    }
    
    
    
    
}

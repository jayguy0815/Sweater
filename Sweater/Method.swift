//
//  Method.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/15.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import Foundation
import UIKit

class Methods{
    func setNavigationBar() -> UIView {
        //your custom view for back image with custom size
        let view = UIView(frame: CGRect(x: -5, y: 10, width: 50, height: 60))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 11, width: 20, height: 20))
        if let imgBackArrow = UIImage(named: "backArrowIcon") {
            imageView.image = imgBackArrow
        }
        view.addSubview(imageView)
        let text = UILabel(frame: CGRect(x: 20, y: 1, width: 60, height: 40))
        text.text = "返回"
        text.font = text.font.withSize(17)
        //        text.font = text.font.withSize(20)
        text.textColor = UIColor.white
        view.addSubview(text)
        
        return view
    }
    
    func newAlert(errorTitle : String, errorMessage : String, actionTitle : String) -> UIAlertController{
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
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
}

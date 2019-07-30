//
//  DetailViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/23.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase

class DetailViewController: UIViewController {

    var activity : Activity!
    
    @IBAction func navBtnPressed(_ sender: Any) {
        
        let alertCon = UIAlertController(title: "導航至該場地", message: "請選擇一種方式", preferredStyle: .actionSheet)
        let googleAction = UIAlertAction(title: "Google Maps", style: .default) { (action) in
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                let address = self.activity.address
                let urlString = "comgooglemaps://?daddr=\(address)&directionsmode=driving"
                guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else{
                    assertionFailure("Fail to get comgooglemaps url.")
                    return
                }
                UIApplication.shared.open(url, options: [:]) { (success) in
                }
                
                
            } else {
                self.notInstall()
            }
        }
        
        let appleAction = UIAlertAction(title: "Apple Maps", style: .default) { (action) in
            let sourceCoordinate = CLLocationCoordinate2D(latitude: self.activity.latitue, longitude: self.activity.longitue)
            let sourcePlace = MKPlacemark(coordinate: sourceCoordinate, addressDictionary: nil)
            let targetMapItem = MKMapItem(placemark: sourcePlace)
            let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
            targetMapItem.openInMaps(launchOptions: options)
           
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertCon.addAction(googleAction)
        alertCon.addAction(appleAction)
        alertCon.addAction(cancelAction)
        
        self.present(alertCon, animated: true, completion: nil)
    }
    
    func notInstall(){
        let alert = UIAlertController(title: "錯誤", message: "未安裝Google Maps", preferredStyle: .alert)
        let action = UIAlertAction(title: "好", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true ,completion: nil)
    }
    
    
    
    
    @IBOutlet weak var detailTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        detailTableView.delegate = self
        detailTableView.dataSource = self
        detailTableView.backgroundColor = UIColor(named: "backGreen")
       self.navigationItem.title = "活動資訊"
        let backButton = UIBarButtonItem()
        
        backButton.title = "返回"
        
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        // Do any additional setup after loading the view.
    }
    
    func beginNav(_ startPLCL: CLPlacemark, endPLCL: CLPlacemark) {
        
        // 获取起点
        let startplMK: MKPlacemark = MKPlacemark(placemark: startPLCL)
        let startItem: MKMapItem = MKMapItem(placemark: startplMK)
        
        // 获取终点
        let endplMK: MKPlacemark = MKPlacemark(placemark: endPLCL)
        let endItem: MKMapItem = MKMapItem(placemark: endplMK)
        
        // 设置起点和终点
        let mapItems: [MKMapItem] = [startItem, endItem]
        
        // 设置导航地图启动项参数字典
        let dic: [String : AnyObject] = [
            // 导航模式:驾驶
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving as AnyObject,
            // 地图样式：标准样式
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue as AnyObject,
            // 显示交通：显示
            MKLaunchOptionsShowsTrafficKey: true as AnyObject
        ]
        
        // 根据 MKMapItem 的起点和终点组成数组, 通过导航地图启动项参数字典, 调用系统的地图APP进行导航
        MKMapItem.openMaps(with: mapItems, launchOptions: dic)
    }
}

extension DetailViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 5
        }
        else if section == 1 {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell") as! DetailCell
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "mapCell") as! MapCell
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "quitCell")
        if indexPath.section == 0{
            if indexPath.row == 0{
                cell.detailLabel.text = "活動名稱"
                cell.detail2Label.text = activity.name
                return cell
            }else if indexPath.row == 1 {
                cell.detailLabel.text = "活動時間"
                let dateStr = Manager.shared.dateToString(activity.date)
                cell.detail2Label.text = dateStr
                return cell
            }else if indexPath.row == 2 {
                cell.detailLabel.text = "活動地點"
                cell.detail2Label.text = activity.courtName
                return cell
            }else if indexPath.row == 3 {
                cell.detailLabel.text = "目前人數"
                cell.detail2Label.text = String(activity.participantCounter)
                return cell
            }else if indexPath.row == 4 {
                cell.detailLabel.text = "邀請人數"
                cell.detail2Label.text = String(activity.peopleCounter)
                return cell
            }
        }
        else if indexPath.section == 1{
            if indexPath.row == 0 {
                cell.detailLabel.text = "活動地址"
                cell.detail2Label.text = activity.address
                return cell
            }else if indexPath.row == 1{
                
                cell1.courtName = activity.courtName
                cell1.address = activity.address
                cell1.coordinate = CLLocationCoordinate2D(latitude: activity.latitue, longitude: activity.longitue)
                cell1.addAnnotationOnLoction(pointCoordinate: cell1.coordinate)
                return cell1
            }
        }
        return cell2!
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "活動資訊"
        }else if section == 1 {
            return "地點資訊"
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 10, y: 5, width: 320, height: 10)
        myLabel.font = UIFont.boldSystemFont(ofSize: 10)
        myLabel.textColor = .lightGray
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        let headerView = UIView()
        headerView.addSubview(myLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 {
            if indexPath.row == 1 {
                return 345
            }
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 2{
            guard let uid = UserDefaults.standard.string(forKey: "uid") else{
                return
            }
            var array = self.activity.participants
            for i in 0..<array.count{
                if array[i] == uid{
                     array.remove(at: i)
                     break
                }
            }
            
            guard let nickName = UserDefaults.standard.string(forKey: "nickname") else {
                return
            }
            
            let postTime = Double(Date().timeIntervalSince1970)
           
            let dic : [String:Any] = ["participates": array , "participateCounter" : array.count , "modifiedTime" : postTime , "lastMessage" : "\(nickName)已退出活動" , "lastMessageTime" : postTime]
            let uuid = UUID().uuidString
            
            let message : [String:Any] = ["senderID":uid,"senderName":nickName ,"content":"\(nickName)已退出活動","sendDate":Date(),"messageId":uuid,"postTime":postTime]
            
            let alert = UIAlertController(title: "退出", message: "確定要退出活動？", preferredStyle: .actionSheet)
            let okAction = UIAlertAction(title: "確定", style: .destructive) { (action) in
                Firestore.firestore().collection("activities").document(self.activity.key).updateData(dic, completion: { (error) in
                    if let err = error{
                        print(err)
                    }
                    Firestore.firestore().collection("channels").document(self.activity.key).collection("messages").document(uuid).setData(message, completion: { (error) in
                        if let err = error{
                            print(err)
                        }
                        let okAlert = UIAlertController(title: "", message: "退出成功!", preferredStyle: .alert)
                        let okAction2 = UIAlertAction(title: "好", style: .default, handler: { (action) in
                            self.navigationController?.popToRootViewController(animated: true)
                        })
                        okAlert.addAction(okAction2)
                        self.present(okAlert,animated: true , completion: nil)
                    })
                })
            }
            let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert,animated: true,completion: nil)
        }
    }
    
    
}

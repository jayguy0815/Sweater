//
//  MapViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/16.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase

protocol MapVCDelegate {
     func didFinishCreateActivity()
}

class MapViewController: UIViewController , CLLocationManagerDelegate ,MKMapViewDelegate{
    @IBOutlet weak var placeSelectionSegment: UISegmentedControl!
    @IBOutlet weak var createBtn: UIBarButtonItem!
    @IBOutlet weak var placefield: UITextField!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var placePicker: UIPickerView!
    @IBOutlet weak var courtField: UITextField!
    @IBOutlet weak var courtPicker: UIPickerView!
    @IBOutlet weak var listSelectionView: UIStackView!
    @IBOutlet weak var mapSelectionView: UIView!
    
    var delegate : MapVCDelegate?
    let methods = Methods()
    var activity : [String:Any] = [:]
    var locationManager : CLLocationManager!
    var ref : DatabaseReference = Database.database().reference()
    var distList : [String] = []
    var courtList : [String] = []
    var uid : String?
    let manager = Manager()
    
    var latitude : Double!
    var longitude : Double!
    
    
    var annotationList : [customAnnotation] = []
    var mapData = MapData()
    var annotation : MKPointAnnotation!
    var courtName : String!
    var address : String = ""
    
    @IBAction func segmentChanged(_ sender: Any) {
        switch placeSelectionSegment.selectedSegmentIndex {
        case 0:
            listSelectionView.isHidden = false
            mapSelectionView.isHidden = true
        case 1:
            listSelectionView.isHidden = true
            mapSelectionView.isHidden = false
            //self.delegate?.passActivityData(activityArray: self.activity)
            
        default:
            break
        }
    }
    
    @IBAction func createActivity(_ sender: Any) {
        
        let newActivity = Activity()
        guard let peopleCounter = self.activity["people"] as? String , let dateString = self.activity["date"] as? String , let activityName = self.activity["name"] as? String , let content = self.activity["content"] as? String else{
            return
        }
//        newActivity.id = UUID().uuidString
        newActivity.name = activityName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        guard let date = dateFormatter.date(from: dateString) else {
            fatalError("ERROR: Date conversion failed due to mismatched format.")
        }
        newActivity.date = date
        newActivity.creater = self.uid!
        newActivity.courtName = self.courtName
       
        newActivity.peopleCounter = Int(peopleCounter)!
        newActivity.latitue = self.latitude
        newActivity.longitue = self.longitude
        newActivity.address = self.address
        newActivity.content = content
        
        let dic : [String:Any] = ["activityName":newActivity.name,"date": "\(newActivity.date)", "creator":newActivity.creater,"courtName":newActivity.courtName
            ,"peopleCounter":newActivity.peopleCounter ,"latitude":newActivity.latitue,"longitude":newActivity.longitue,"address":newActivity.address,"content":newActivity.content,"postTime":[".sv":"timestamp"]]
        
       
        
        let alert = UIAlertController(title: "建立揪團", message: "確認場地？\n\(self.courtName!)\n\(self.address)", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { (action) in
            
            Manager.shared.activities.insert(newActivity, at: 0)
            self.ref.child("activities").childByAutoId().setValue(dic)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0, execute: {
                let alertController = UIAlertController(title: "成功", message: "揪團成功", preferredStyle:.alert)
                let backAction = UIAlertAction(title: "返回", style: .default, handler: { (action) in
                    self.navigationController?.popToRootViewController(animated: true)
                })
                alertController.addAction(backAction)
                self.present(alertController,animated: true,completion: nil)
            })
            
        }
        
        let cancelAction = UIAlertAction(title: "取消"
            , style: .cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert,animated: true,completion: nil)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // MARK - get district data
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(self.activity)
        
        self.uid = Auth.auth().currentUser?.uid
        mapSelectionView.isHidden = true
        
        
        // MARK - Navigation Item
        self.view.backgroundColor = UIColor(named: "backGreen")
        self.navigationItem.title = "選擇地點"
        let customBackButton = methods.setNavigationBar()
        self.view.addSubview(customBackButton)
        self.navigationItem.setHidesBackButton(true, animated:false)
        let backTap = UITapGestureRecognizer(target: self, action: #selector(back))
        customBackButton.addGestureRecognizer(backTap)
        let leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        // MARK - MapKitView
        mapview.delegate = self
        mapview.showsUserLocation = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        
        // MARK - PickerView
        placePicker.delegate = self
        placePicker.dataSource = self
        placePicker.removeFromSuperview()
        placefield.inputView = placePicker
        courtPicker.delegate = self
        courtPicker.dataSource = self
        courtPicker.removeFromSuperview()
        courtField.inputView = courtPicker
        
        // MARK - TextField
        placefield.placeholder = "請先選擇行政區"
        courtField.placeholder = "請選擇場地"
        // Do any additional setup after loading the view.
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation:CLLocation = locations.last! as CLLocation
        DispatchQueue.once(token: "MoveRegion") {
            let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            var region:MKCoordinateRegion=MKCoordinateRegion(center: currentLocation.coordinate, span: span)
            region.center=currentLocation.coordinate
            self.mapview.setRegion(region, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? customAnnotation{
            self.courtName = annotation.title!
            self.address = annotation.subtitle ?? ""
        }
    }
    
    func loadFromFile(){
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("mapData.archive")
        do{
            //把檔案轉成Data形式
            let fileData = try Data(contentsOf: fileURL)
            //從Data轉回MapData陣列
            self.mapData = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(fileData) as! MapData
        }catch{
            print("error\(error)")
        }
    }

}

extension MapViewController : UIPickerViewDelegate , UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == placePicker{
            return MapData.shared.distList.count
        }else if pickerView == courtPicker{
            return self.courtList.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == placePicker{
            let text = "\(MapData.shared.distList[row])"
            self.placefield.text = text
            for i in 0..<MapData.shared.courtList.count{
                if MapData.shared.addressList[i].contains(text){
                    self.courtList.append(MapData.shared.courtList[i])
                }
            }
            
        }else if pickerView == courtPicker{
           
            let text = "\(self.courtList[row])"
            self.courtField.text = text
            
            for i in 0..<MapData.shared.latitudeList.count{
                if MapData.shared.courtList[i] == text{
                    self.latitude = MapData.shared.latitudeList[i]
                    self.longitude = MapData.shared.longitudeList[i]
                    self.address = MapData.shared.addressList[i]
                }
            }
            
            if self.annotationList.count != 0 {
                self.mapview.removeAnnotation(annotationList[0])
            }
            
                    var annotionCoordinate = CLLocationCoordinate2D()
                    annotionCoordinate.latitude = self.latitude
                    annotionCoordinate.longitude = self.longitude
                    
                    let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    var region:MKCoordinateRegion=MKCoordinateRegion(center: annotionCoordinate, span: span)
                    
                    region.center=annotionCoordinate
                    self.mapview.setRegion(region, animated: true)
                    
                    
                    let annotation = customAnnotation()
                    annotation.coordinate = annotionCoordinate
                    annotation.title = text
                    annotation.subtitle = "\(self.address)"
                    self.annotationList.append(annotation)
                    
                    if annotation.Id == "111"{
                        annotation.title = "711"
                        annotation.subtitle = "222"
                    }
            
                    self.mapview.addAnnotation(annotation)
                    self.mapview.selectAnnotation(annotation, animated: true)

        }
            
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == placePicker{
            return "\(MapData.shared.distList[row])"
        }else if pickerView == courtPicker{
            return "\(self.courtList[row])"
        }
        return ""
    }
}


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

class MapViewController: UIViewController , CLLocationManagerDelegate ,MKMapViewDelegate{
    @IBOutlet weak var createBtn: UIBarButtonItem!
    @IBOutlet weak var placefield: UITextField!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var placePicker: UIPickerView!
    @IBOutlet weak var courtField: UITextField!
    @IBOutlet weak var courtPicker: UIPickerView!
    
    let methods = Methods()
    var activity : [String:Any]?
    var locationManager : CLLocationManager!
    let uid = Auth.auth().currentUser?.uid
    var ref : DatabaseReference = Database.database().reference()
    var distList : [String] = []
    var courtList : [String] = []
    var coordinateList : [Double] = []
    var address : String = ""
    let queue1 = DispatchQueue(label: "", qos: .userInteractive)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // MARK - get district data
        DispatchQueue.main.async {
            self.ref.observeSingleEvent(of: .value) { (snapshot) in
                guard let array = snapshot.value as? NSDictionary else{return}
                let innerDict = array["maps_basketball"] as! NSDictionary
                self.distList = innerDict.allKeys as! [String]
                print(self.distList)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.activity!)
        
    
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
        print("Lat:\(currentLocation.coordinate.latitude) Lon:\(currentLocation.coordinate.longitude)")
        
        DispatchQueue.once(token: "MoveRegion") {
            let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            var region:MKCoordinateRegion=MKCoordinateRegion(center: currentLocation.coordinate, span: span)
            region.center=currentLocation.coordinate
            self.mapview.setRegion(region, animated: true)

        }
    }

}

class StoreAnootation : MKPointAnnotation{
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

extension MapViewController : UIPickerViewDelegate , UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == placePicker{
            return self.distList.count
        }else if pickerView == courtPicker{
            return self.courtList.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == placePicker{
            let text = "\(self.distList[row])"
            self.placefield.text = text
            
            self.ref.child("maps_basketball").observeSingleEvent(of: .value) { (snapshot0) in
                guard let array = snapshot0.value as? NSDictionary else{return}
                let courtDict = array["\(text)"] as! NSDictionary
                self.courtList = courtDict.allKeys as! [String]
                print(self.courtList)
            }
        }else if pickerView == courtPicker{
            let text = "\(self.courtList[row])"
            self.courtField.text = text
            
            
                self.ref.child("maps_basketball").child(self.placefield.text!).child(text).observeSingleEvent(of: .value) { (snapshot1) in
                    
                    guard let contentArray = snapshot1.value as? NSDictionary else{return}
                    let coordDict = contentArray["coordinates"] as! NSDictionary
                    self.coordinateList = coordDict.allValues as! [Double]
                    print(self.coordinateList)
                    
                }
                self.ref.child("maps_basketball").child(self.placefield.text!).child(self.courtField.text!).observeSingleEvent(of: .value) { (snapshot2) in
                    
                        guard let value = snapshot2.value as? NSDictionary else{return}
                        let address = value["address"] as! String
                        self.address = address
                        print(self.address)
                    
                }
            
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    var annotionCoordinate = CLLocationCoordinate2D()
                    annotionCoordinate.latitude = self.coordinateList[1]
                    annotionCoordinate.longitude = self.coordinateList[0]
                    
                    let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                    var region:MKCoordinateRegion=MKCoordinateRegion(center: annotionCoordinate, span: span)
                    
                    region.center=annotionCoordinate
                    self.mapview.setRegion(region, animated: true)
                    
                    
                    let annotation = StoreAnootation()
                    annotation.coordinate = annotionCoordinate
                    annotation.title = "\(self.courtField.text!)"
                    annotation.subtitle = "\(self.address)"
                    if annotation.Id == "111"{
                        annotation.title = "711"
                        annotation.subtitle = "222"
                    }
                    
                    self.mapview.addAnnotation(annotation)
                    
                
                })
            
        }
            
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == placePicker{
            return "\(distList[row])"
        }else if pickerView == courtPicker{
            return "\(courtList[row])"
        }
        return ""
    }
    
    
}

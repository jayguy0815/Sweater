//
//  TestViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/17.
//  Copyright © 2019 Leo Huang. All rights reserved.


import UIKit
import Firebase
import MapKit
import CoreLocation



class TestViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate {
    
    var ref : DatabaseReference!
    var distList : [String] = []
    var courtList : [String] = []
    var latitudeList : [Double] = []
    var longitudeList : [Double] = []
    var addressList : [String] = []
    
    var name : String?
    var touchPoint : CGPoint?
    
    var mapData = MapData()
    var mapDataArr : [MapData] = []

    var array = ["籃球","健身","棒球","游泳","排球","羽球","網球","足球"]
    var locationManager : CLLocationManager!

    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var textField: UITextField!
    


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        for i in 0 ..< Manager.mapData.courtList.count{
            var annotionCoordinate = CLLocationCoordinate2D()
            annotionCoordinate.latitude = Manager.mapData.latitudeList[i]
            annotionCoordinate.longitude = Manager.mapData.longitudeList[i]
            
            
            let annotation = customAnnotation()
            annotation.coordinate = annotionCoordinate
            annotation.title = "\(Manager.mapData.courtList[i])"
            annotation.subtitle = "\(Manager.mapData.addressList[i])"
            
            
            if annotation.Id == "111"{
                annotation.title = "711"
                annotation.subtitle = "222"
            }
            
            self.mapView.addAnnotation(annotation)
        }
        //self.loadFromFile()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        textField.placeholder = "請選擇一種運動類型"
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.removeFromSuperview()
        textField.inputView = pickerView
        self.navigationItem.title = "球場地圖"
        print(Manager.mapData.addressList.count)
        print(NSHomeDirectory())
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
        gestureRecognizer.delegate = self
        self.mapView.addGestureRecognizer(gestureRecognizer)
        self.mapView.reloadInputViews()
        
        
        
        
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation:CLLocation = locations.last! as CLLocation
        let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        var region:MKCoordinateRegion=MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        region.center=currentLocation.coordinate
        self.mapView.setRegion(region, animated: true)
    }
    
    @objc func handleLongPress(gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state == .began{
            self.touchPoint = gestureRecognizer.location(in: self.mapView)
            
            let alert = UIAlertController(title: "請輸入名稱", message: "請輸入名稱", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.placeholder = "名稱"
            }
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                self.name = alert.textFields?[0].text
                
                let newCoordinate : CLLocationCoordinate2D = self.mapView.convert(self.touchPoint!, toCoordinateFrom: self.mapView)
                self.addAnnotationOnLoction(pointCoordinate: newCoordinate)
            }
            alert.addAction(action)
            present(alert,animated: true,completion: nil)
           
            
        }
    }
    
    func addAnnotationOnLoction(pointCoordinate : CLLocationCoordinate2D){
        
        let annotation = customAnnotation()
        annotation.coordinate = pointCoordinate
        annotation.title = self.name
        mapView.addAnnotation(annotation)
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

extension TestViewController : UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return array.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return array[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let text = "\(self.array[row])"
        self.textField.text = text
    }
}

extension TestViewController : UITextFieldDelegate {
    
}

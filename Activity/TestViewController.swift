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
    var address : String = ""
    var lat : Double = 0.0
    var long : Double = 0.0
    var flag = true
    
    var name : String?
    var touchPoint : CGPoint?
    
    var mapData = MapData()
    var mapDataArr : [MapData] = []

    var array = ["籃球","健身","棒球","游泳","排球","羽球","網球","足球"]
    var locationManager : CLLocationManager!

    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var navBtn: UIBarButtonItem!
    
    @IBAction func backBtnPressed(_ sender: Any) {
        self.mapView.setRegion(MKCoordinateRegion(
            center: self.mapView.userLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ), animated: true)
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       
        //self.loadFromFile()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navBtn.isEnabled = false
    }

    @IBAction func navBtnPressed(_ sender: Any) {
        
        let alertCon = UIAlertController(title: "導航至該場地", message: "請選擇一種方式", preferredStyle: .actionSheet)
        let googleAction = UIAlertAction(title: "Google Maps", style: .default) { (action) in
            if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
                let address = self.address
                let urlString = "comgooglemaps://?daddr=\(address)&directionsmode=driving"
                guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else{
                    assertionFailure("Fail to get comgooglemaps url.")
                    return
                }
                UIApplication.shared.open(url, options: [:]) { (success) in
                    self.mapView.deselectAnnotation(self.mapView.selectedAnnotations[0], animated: true)
                }
                
                
            } else {
                self.notInstall()
            }
        }
        
        let appleAction = UIAlertAction(title: "Apple Maps", style: .default) { (action) in
            let sourceCoordinate = CLLocationCoordinate2D(latitude: self.lat, longitude: self.long)
            let sourcePlace = MKPlacemark(coordinate: sourceCoordinate, addressDictionary: nil)
            let targetMapItem = MKMapItem(placemark: sourcePlace)
            let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
            targetMapItem.openInMaps(launchOptions: options)
            self.mapView.deselectAnnotation(self.mapView.selectedAnnotations[0], animated: true)
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
        if flag == true{
            let currentLocation:CLLocation = locations.last! as CLLocation
            let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            var region:MKCoordinateRegion=MKCoordinateRegion(center: currentLocation.coordinate, span: span)
            region.center=currentLocation.coordinate
            self.mapView.setRegion(region, animated: true)
            flag = false
        }
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if self.mapView.annotations.count != 0{
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        let text = "\(array[row])"
        self.textField.text = text
        let maps = Manager.shared.queryMapsFromCoreData(type: text)
        for i in 0 ..< maps.count{
            var annotionCoordinate = CLLocationCoordinate2D()
            annotionCoordinate.latitude = maps[i].latitude
            annotionCoordinate.longitude = maps[i].longitude
            
            
            let annotation = customAnnotation()
            annotation.coordinate = annotionCoordinate
            annotation.title = "\(maps[i].name)"
            annotation.subtitle = "\(maps[i].address)"

            self.mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let ann = view.annotation as? customAnnotation else{
            return
        }
        self.address = ann.subtitle!
        self.lat = ann.coordinate.latitude
        self.long = ann.coordinate.longitude
        self.navBtn.isEnabled = true
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.navBtn.isEnabled = false
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if let userLocationView = mapView.view(for: mapView.userLocation) {
            userLocationView.canShowCallout = false
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            if view.annotation is MKUserLocation {
                view.canShowCallout = false
            }
        }
    }
    
}

extension TestViewController : UITextFieldDelegate{
    
}



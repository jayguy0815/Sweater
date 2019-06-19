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
    @IBOutlet weak var placeSelectionSegment: UISegmentedControl!
    @IBOutlet weak var createBtn: UIBarButtonItem!
    @IBOutlet weak var placefield: UITextField!
    @IBOutlet weak var mapview: MKMapView!
    @IBOutlet weak var placePicker: UIPickerView!
    @IBOutlet weak var courtField: UITextField!
    @IBOutlet weak var courtPicker: UIPickerView!
    @IBOutlet weak var listSelectionView: UIStackView!
    @IBOutlet weak var mapSelectionView: UIView!
    
    //var delegate : MapViewControllerDelegate?
    let methods = Methods()
    var activity : [String:Any] = [:]
    var locationManager : CLLocationManager!
    var ref : DatabaseReference = Database.database().reference()
    var distList : [String] = []
    var courtList : [String] = []
    
    
   
    
    var latitude : Double!
    var longitude : Double!
    
    
    var annotationList : [customAnnotation] = []
    var mapData = MapData()
    var annotation : MKPointAnnotation!
    var name : String!
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
        let alert = methods.newAlert(errorTitle: "ok", errorMessage: "dd", actionTitle: "dd")
        present(alert,animated: true,completion: nil)
        print(self.name)
        print(self.address)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // MARK - get district data
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //print(self.activity)
        self.loadFromFile()
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
            self.name = annotation.title!
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
            return self.mapData.distList.count
        }else if pickerView == courtPicker{
            return self.courtList.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == placePicker{
            let text = "\(self.mapData.distList[row])"
            self.placefield.text = text
            for i in 0..<self.mapData.courtList.count{
                if self.mapData.distList[i] == text{
                    self.courtList.append(self.mapData.courtList[i])
                }
            }
            
        }else if pickerView == courtPicker{
           
            let text = "\(self.courtList[row])"
            self.courtField.text = text
            
            for i in 0..<self.mapData.latitudeList.count{
                if self.mapData.courtList[i] == text{
                    self.latitude = self.mapData.latitudeList[i]
                    self.longitude = self.mapData.longitudeList[i]
                    self.address = self.mapData.addressList[i]
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
            return "\(self.mapData.distList[row])"
        }else if pickerView == courtPicker{
            return "\(self.courtList[row])"
        }
        return ""
    }
}




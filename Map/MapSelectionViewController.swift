//
//  MapSelectionViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/17.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation

class MapSelectionViewController: UIViewController,CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var activity : [String:Any] = [:]
    var mapVC : MapViewController?
    var ref = Database.database().reference()
    var locationManager : CLLocationManager!
    var methoeds = Methods()
    var mapData = MapData()
    var annotation : MKPointAnnotation!
    var name : String!
    var address : String!
    var latitude : Double!
    var longitude : Double!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.loadFromFile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for i in 0 ..< MapData.shared.courtList.count{
            var annotionCoordinate = CLLocationCoordinate2D()
            annotionCoordinate.latitude = MapData.shared.latitudeList[i]
            annotionCoordinate.longitude = MapData.shared.longitudeList[i]
            
            
            let annotation = customAnnotation()
            annotation.coordinate = annotionCoordinate
            annotation.title = "\(MapData.shared.courtList[i])"
            annotation.subtitle = "\(MapData.shared.addressList[i])"
            
            
            if annotation.Id == "111"{
                annotation.title = "711"
                annotation.subtitle = "222"
            }
            
            self.mapView.addAnnotation(annotation)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "backGreen")
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        // Do any additional setup after loading the view.
    }
    
    override func didMove(toParent parent: UIViewController?) {
        mapVC = parent as! MapViewController
        self.activity = mapVC!.activity
        print(self.activity)
        
        
    }
    
    func saveToFile(fileName : String){
        let homeURL = URL(fileURLWithPath: NSHomeDirectory())
        let documents = homeURL.appendingPathComponent("Documents")
        let fileURL = documents.appendingPathComponent("mapData.archive")
        do{
            //把[Note]轉乘data刑事
            let data = try NSKeyedArchiver.archivedData(withRootObject: self.mapData, requiringSecureCoding: false)
            //寫到檔案
            try data.write(to: fileURL, options: [.atomicWrite])
        }catch{
            print("error\(error)")
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

extension MapSelectionViewController : MKMapViewDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation:CLLocation = locations.last! as CLLocation
        let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        var region:MKCoordinateRegion=MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        region.center=currentLocation.coordinate
        self.mapView.setRegion(region, animated: true)
        
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if let annotation = view.annotation as? customAnnotation{
            self.name = annotation.title!
            self.address = annotation.subtitle ?? ""
            
            mapVC?.courtName = self.name
            mapVC?.address = self.address
            mapVC?.latitude = annotation.coordinate.latitude
            mapVC?.longitude = annotation.coordinate.longitude
        }
    }
}






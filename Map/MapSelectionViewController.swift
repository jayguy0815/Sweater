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
    var flag = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.loadFromFile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
}

extension MapSelectionViewController : MKMapViewDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if flag == true{
            let currentLocation:CLLocation = locations.last! as CLLocation
            let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
            var region:MKCoordinateRegion=MKCoordinateRegion(center: currentLocation.coordinate, span: span)
            region.center=currentLocation.coordinate
            self.mapView.setRegion(region, animated: true)
            flag = false
        }
        
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






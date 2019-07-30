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
    @IBAction func backBtnPressed(_ sender: Any) {
        self.mapView.setRegion(MKCoordinateRegion(
            center: self.mapView.userLocation.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ), animated: true)
    }
    
    var activity : [String:Any] = [:]
    var mapVC : MapViewController?
    var locationManager : CLLocationManager!
    var mapData = MapData()
    var annotation : MKPointAnnotation!
    var name : String!
    var address : String!
    var latitude : Double!
    var longitude : Double!
    var maps = [Maps]()
    var sportType : String!
    var flag = true
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //self.loadFromFile()
    }
    
    override func viewWillAppear(_ animated: Bool) {

        
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
        self.sportType = mapVC!.sportType
        print(self.activity)
        self.maps = Manager.shared.queryMapsFromCoreData(type: self.sportType)
        for i in 0 ..< maps.count{
            var annotionCoordinate = CLLocationCoordinate2D()
            annotionCoordinate.latitude = maps[i].latitude
            annotionCoordinate.longitude = maps[i].longitude
            
            
            let annotation = customAnnotation()
            annotation.coordinate = annotionCoordinate
            annotation.title = maps[i].name
            annotation.subtitle = maps[i].address
            
            
            self.mapView.addAnnotation(annotation)
        }
        
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
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if let userLocationView = mapView.view(for: mapView.userLocation) {
            userLocationView.canShowCallout = false
        }
    }
}






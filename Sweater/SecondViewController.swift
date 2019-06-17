//
//  SecondViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/4/23.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation
class SecondViewController: UIViewController ,CLLocationManagerDelegate{
    let LocationManager = CLLocationManager()
    var CurrentLocation : CLLocation!
    var Lock = NSLock()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    override func loadView() {
        super.loadView()
//        let Camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
//        let MapView = GMSMapView.map(withFrame: CGRect.zero, camera: Camera)
//        view = MapView
//
//        let Marker = GMSMarker()
//        Marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        Marker.title = "Sydney"
//        Marker.snippet = "Australia"
//        Marker.map = MapView
        LocationManager.delegate = self
        LocationManager.desiredAccuracy = kCLLocationAccuracyBest
        LocationManager.distanceFilter = 50
        //LocationManager.requestAlwaysAuthorization()
        LocationManager.requestWhenInUseAuthorization()
        LocationManager.startUpdatingLocation()
        print("開始定位")
        let Camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let MapView = GMSMapView.map(withFrame: CGRect.zero, camera: Camera)
        self.view = MapView
        }
//        override func didReceiveMemoryWarning() {
//            super.didReceiveMemoryWarning()
//        }
        func GetLocation(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]){
            Lock.lock()
            CurrentLocation = locations.last!
            print("經度為\(CurrentLocation.coordinate.latitude)")
            print("緯度為\(CurrentLocation.coordinate.longitude)")
            Lock.unlock()
            let camera = GMSCameraPosition.camera(withLatitude: CurrentLocation.coordinate.latitude, longitude: CurrentLocation.coordinate.longitude, zoom: 12)
            let coordinate = CLLocationCoordinate2D(latitude: CurrentLocation.coordinate.latitude, longitude: CurrentLocation.coordinate.longitude)
            setuplocationMarker(coordinate:coordinate)
            let MapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
            self.view = MapView
        }
        func setuplocationMarker(coordinate:CLLocationCoordinate2D) {
            let locationmarker = GMSMarker(position: coordinate)
            locationmarker.map = self.view as! GMSMapView?
            locationmarker.title = "Here"
            locationmarker.icon = GMSMarker.markerImage(with: UIColor.blue)
            locationmarker.opacity = 0.5
        }
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("定位出錯\(error)")
        }
        
        
    }





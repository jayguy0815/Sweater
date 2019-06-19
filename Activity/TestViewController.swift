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


    var locationManager : CLLocationManager!


    @IBOutlet weak var mapView: MKMapView!




    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //self.loadFromFile()
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
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



    //MARK: func - check file in app.

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


//
//  MapCell.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/23.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapCell: UITableViewCell {

    @IBOutlet weak var detailLabel: UILabel!
   
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBAction func positionBtnPressed(_ sender: Any) {
        self.reposition()
    }
    var locationManager : CLLocationManager!
    var coordinate : CLLocationCoordinate2D!
    var courtName : String!
    var address : String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        mapView.delegate = self
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension MapCell: MKMapViewDelegate{
    func addAnnotationOnLoction(pointCoordinate : CLLocationCoordinate2D){
        
        let annotation = customAnnotation()
        annotation.coordinate = self.coordinate
        annotation.title = self.courtName
        annotation.subtitle = self.address
        mapView.addAnnotation(annotation)
        mapView.selectAnnotation(annotation, animated: false)
    }
}

extension MapCell: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let currentLocation:CLLocation = locations.last! as CLLocation
        let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        var region:MKCoordinateRegion=MKCoordinateRegion(center: self.coordinate, span: span)
        region.center = self.coordinate
        self.mapView.setRegion(region, animated: true)
    }
    
    func reposition(){
        let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        var region:MKCoordinateRegion=MKCoordinateRegion(center: self.coordinate, span: span)
        region.center = self.coordinate
        self.mapView.setRegion(region, animated: true)
    }


    
    
}




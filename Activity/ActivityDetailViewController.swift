//
//  ActivityDetailViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/25.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import MapKit

class ActivityDetailViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentPeopleLabel: UILabel!
    @IBOutlet weak var invitedPeopleLabel: UILabel!
    @IBOutlet weak var courtLabel: UILabel!
    
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    
    var activity = Activity()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.indicatorStyle = .black
        scrollView.isScrollEnabled = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.bounces = true
        scrollView.decelerationRate = .normal
        scrollView.delegate = self
        nameTextView.isUserInteractionEnabled = false
        addressTextView.isUserInteractionEnabled = false
        contentTextView.isUserInteractionEnabled = false
        nameTextView.backgroundColor = UIColor.white.withAlphaComponent(0)
        addressTextView.backgroundColor = UIColor.white.withAlphaComponent(0)
        contentTextView.backgroundColor = UIColor.white.withAlphaComponent(0)
        adjustUITextViewHeight(arg: nameTextView)
        adjustUITextViewHeight(arg: addressTextView)
        adjustUITextViewHeight(arg: contentTextView)
        // Do any additional setup after loading the view.
        
        nameTextView.text = activity.name
        let dateString = Manager.shared.dateToString(activity.date)
        dateLabel.text = dateString
        courtLabel.text = activity.courtName
        currentPeopleLabel.text = String(activity.participantCounter)
        invitedPeopleLabel.text = String(activity.peopleCounter)
        addressTextView.text = activity.address
        contentTextView.text = activity.content
        latitude = activity.latitue
        longitude = activity.longitue
        
        mapView.delegate = self
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
        
    }
    
    func adjustUITextViewHeight(arg : UITextView)
    {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
    }
    
}

extension ActivityDetailViewController : UIScrollViewDelegate {
    
}

extension ActivityDetailViewController : MKMapViewDelegate , CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        DispatchQueue.once(token: "MoveRegion") {
            let span:MKCoordinateSpan=MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            var region:MKCoordinateRegion=MKCoordinateRegion(center: location.coordinate, span: span)
            region.center=location.coordinate
            self.mapView.setRegion(region, animated: true)
            
            let annotation = customAnnotation()
            annotation.coordinate = location.coordinate
            annotation.title = activity.courtName
            annotation.subtitle = activity.address
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
}

extension UILabel {
    var optimalHeight : CGFloat {
        get
        {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
            label.numberOfLines = 0
            label.lineBreakMode = NSLineBreakMode.byWordWrapping
            label.font = self.font
            label.text = self.text
            label.sizeToFit()
            return label.frame.height
        }
        
    }
}

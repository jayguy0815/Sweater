//
//  ActivityDetailViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/25.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class ActivityDetailViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var currentPeopleLabel: UILabel!
    @IBOutlet weak var invitedPeopleLabel: UILabel!
    @IBOutlet weak var courtLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    
    var activity = Activity()
    
    var ref : DatabaseReference!
    
    @IBAction func participateBtnPressed(_ sender: Any) {
        for participate in activity.participates {
            guard participate != Auth.auth().currentUser?.uid else {
                let alertController = UIAlertController(title: "Oops", message: "您已參加此活動", preferredStyle: .alert)
                let action = UIAlertAction(title: "好", style: .cancel, handler: nil)
                alertController.addAction(action)
                self.present(alertController,animated: true,completion: nil)
                return
            }
        }
        let alertController = UIAlertController(title: "確認參加活動？", message: "確定要參加此活動?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "確定", style: .default) { (action) in
            self.ref = Database.database().reference().child("activities").child(self.activity.key)
            let count = self.activity.participantCounter + 1
            self.ref.updateChildValues(["participateCounter":count])
            self.ref.child("participates").updateChildValues(["\(count)":Auth.auth().currentUser?.uid])
        
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.currentPeopleLabel.text = "\(count)"
                let okAlertController = UIAlertController(title: "成功", message: "成功參加活動", preferredStyle: .alert)
                let okokAction = UIAlertAction(title: "好", style: .default, handler: { (action) in
                    
                })
                okAlertController.addAction(okokAction)
                self.present(okAlertController,animated: true,completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController,animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.showsVerticalScrollIndicator = true
        scrollView.indicatorStyle = .black
        scrollView.isScrollEnabled = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.bounces = true
        scrollView.decelerationRate = .normal
        scrollView.delegate = self
        
        
        
        nameLabel.text = activity.name
        let dateString = Manager.shared.dateToString(activity.date)
        dateLabel.text = dateString
        courtLabel.text = activity.courtName
        currentPeopleLabel.text = String(activity.participantCounter)
        invitedPeopleLabel.text = String(activity.peopleCounter)
        addressLabel.text = activity.address
        contentLabel.text = activity.content
        latitude = activity.latitue
        longitude = activity.longitue
        
        mapView.delegate = self
        locationManager.delegate = self
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

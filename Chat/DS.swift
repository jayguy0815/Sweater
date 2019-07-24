
//  DS.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/23.
//  Copyright © 2019 Leo Huang. All rights reserved.


import Foundation
import UIKit

class DS : NSObject   {
    
    var activity : Activity
    var participates : [Account]
    init(activity : Activity, participates : [Account]) {
        self.activity = activity
        self.participates = participates
    }

    
}

extension DS : UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return activity.participants.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "peopleCell", for: indexPath) as! PeopleCollectionViewCell
        cell.accountImageView.layer.cornerRadius = cell.accountImageView.frame.width/2
        let imagedata = self.participates[indexPath.section].image
        if let image = UIImage(data: imagedata){
            cell.accountImageView.image = image
        }
        return cell
    }
}

extension DS : UICollectionViewDelegate {

}


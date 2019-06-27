//
//  ActivityDetailViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/25.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit

class ActivityDetailViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    
    var fullScreenSize :CGSize!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fullScreenSize = UIScreen.main.bounds.size
        scrollView.contentSize = CGSize(width: fullScreenSize.width, height: fullScreenSize.height*1.5)
        scrollView.showsVerticalScrollIndicator = true
        scrollView.indicatorStyle = .black
        scrollView.isScrollEnabled = true
        scrollView.isDirectionalLockEnabled = true
        scrollView.bounces = true
        scrollView.decelerationRate = .normal
        scrollView.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
}

extension ActivityDetailViewController : UIScrollViewDelegate {
    
}

//
//  infoUIView.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/12.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit

class infoUIView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        let size = self.bounds.size
        let h = size.height     // adjust the multiplier to taste
        let w = size.width
        // calculate the 5 points of the pentagon
        let p = self.bounds.origin
        print(p)
        let p1 = CGPoint(x:p.x, y:p.y+h)
        print(p1)
        let p2 = CGPoint(x:p1.x + w, y:p1.y)
        print(p2)
        let p3 = CGPoint(x:p2.x, y: p2.y - h * 0.8)
        print(p3)
        let p4 = CGPoint(x:110, y:p3.y)
        print(p4)
        let p5 = CGPoint(x:90, y:p.y)
        print(p5)
        let p6 = CGPoint(x:70, y:p3.y)
        print(p6)
        let p7 = CGPoint(x:p.x, y:p3.y)
        print(p7)
        
        // create the path
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.addLine(to: p4)
        path.addLine(to: p5)
        path.addLine(to: p6)
        path.addLine(to: p7)
        path.addLine(to: p1)
        path.close()
        
        // fill the path
        UIColor.green.set()
        path.fill()
    }
}

//
//  TestActivities.swift
//  Sweater
//
//  Created by Leo Huang on 2019/4/25.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit

class TestActivities: UIViewController ,UITextFieldDelegate{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag>3{
            viewMoving(true, movevalue: 130)
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag>3{
            viewMoving(false, movevalue: 130)
        }
    }
    func viewMoving(_ up:Bool,movevalue:CGFloat){
        let movementDuration = 0.3
        let movement : CGFloat = (up ? -movevalue : movevalue)
        UIView.beginAnimations("animateview", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        let UserID = UITextField()
        self.view.addSubview(UserID)
        UserID.leftAnchor.constraint(equalTo: super.view.leftAnchor, constant: 100).isActive = true
        UserID.topAnchor.constraint(equalTo: super.view.topAnchor, constant: 30).isActive = true
        UserID.rightAnchor.constraint(equalTo: super.view.rightAnchor, constant: -10).isActive = true
        UserID.heightAnchor.constraint(equalToConstant: 40).isActive = true
        UserID.translatesAutoresizingMaskIntoConstraints = false
        UserID.borderStyle = .line
        UserID.keyboardAppearance = .dark
        UserID.keyboardType = .default
        UserID.delegate = self
        UserID.tag = 0
        UserID.placeholder = "aaa"
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

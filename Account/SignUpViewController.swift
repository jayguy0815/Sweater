//
//  SignUpViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/5/17.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import IQKeyboardManagerSwift

protocol SignUpViewControllerDelegate {
    func returnInfo(_ email : String,_ password : String)
}
class SignUpViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource ,UITextFieldDelegate{
    
    var sportType : [String] = ["籃球","排球","羽球","桌球","棒球","足球","游泳","單車","慢跑","登山","健身"]
    
    var hobbyPickerV = UIPickerView()
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var comfirmPasswordTextField: UITextField!
    @IBOutlet weak var hobbyPickerTxt: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
 
    var delegate : SignUpViewControllerDelegate!
    //資料庫ref
    var ref : DatabaseReference! = Database.database().reference()
    
    @IBAction func signUp(_ sender: UIButton) {
        if emailTextField.text == ""{
            let alert = UIAlertController(title: "error", message: "請輸入電子郵件", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            present(alert,animated: true,completion: nil)
            
        }else if nameTextField.text == ""{
            let alert = UIAlertController(title: "error", message: "請輸入姓名", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            present(alert,animated: true,completion: nil)
            
        }else if nickNameTextField.text == ""{
            let alert = UIAlertController(title: "error", message: "請輸入暱稱", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            present(alert,animated: true,completion: nil)
    
        }else if hobbyPickerTxt.text == ""{
            let alert = UIAlertController(title: "error", message: "請選擇喜好運動", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            present(alert,animated: true,completion: nil)
            
        }else if passwordTextField.text == ""{
            let alert = UIAlertController(title: "error", message: "請輸入密碼", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            present(alert,animated: true,completion: nil)
            
        }else if comfirmPasswordTextField.text == ""{
            let alert = UIAlertController(title: "error", message: "再次輸入密碼", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            present(alert,animated: true,completion: nil)
            
        }else if comfirmPasswordTextField.text != passwordTextField.text{
            let alert = UIAlertController(title: "error", message: "再次輸入密碼錯誤", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(defaultAction)
            present(alert,animated: true,completion: nil)
            
        }else if emailTextField.text != "" && nickNameTextField.text != "" && comfirmPasswordTextField.text != "" && nameTextField.text != "" && passwordTextField.text != "" && hobbyPickerTxt.text != ""{
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){(user , error) in
                if error == nil{
                    print("You have successfully signed up")
                    
                    // add account data to firebase
                    let uid = Auth.auth().currentUser!.uid
                    let accountRef = self.ref.child("user_account").child("\(uid)")
                    let accountArr = ["username":self.nameTextField.text,"email":self.emailTextField.text,"password":self.passwordTextField.text,"nickname":self.nickNameTextField.text,"hobby":self.hobbyPickerTxt.text]
                    accountRef.setValue(accountArr)
                    //finish write data then logout
                    if Auth.auth().currentUser != nil{
                        try? Auth.auth().signOut()
                    }
                    let alertController = UIAlertController(title: "Success", message: "註冊成功", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "返回", style: .default, handler: { (action) in
                        let email = self.emailTextField.text
                        let password = self.passwordTextField.text
                        guard let vc = self.navigationController?.viewControllers[0] as? UIViewController else{return}
                        self.delegate = vc as? SignUpViewControllerDelegate
                        self.delegate.returnInfo(email!, password!)
                        self.navigationController?.popToViewController(vc, animated: true)
                    })
                    alertController.addAction(alertAction)
                    self.present(alertController,animated: true,completion: nil)

                } else {
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaultAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func cancel(_ sender: UIButton) {
        let vc = self.navigationController?.viewControllers[0]
        self.navigationController?.popToViewController(vc!, animated: true)
    }
    let notificationName = Notification.Name("GetUpdateNoti")
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        //self.navigationController?.isNavigationBarHidden = true
        self.nameTextField.placeholder = "請輸入姓名"
        nameTextField.delegate = self
        self.nickNameTextField.placeholder = "請輸入暱稱"
        nickNameTextField.delegate = self
        self.emailTextField.placeholder = "請輸入email"
        emailTextField.delegate = self
        self.passwordTextField.placeholder = "請輸入密碼"
        passwordTextField.delegate = self
        self.passwordTextField.isSecureTextEntry = true
        self.comfirmPasswordTextField.placeholder = "再次輸入密碼"
        comfirmPasswordTextField.delegate = self
        self.comfirmPasswordTextField.isSecureTextEntry = true
        self.hobbyPickerTxt.placeholder = "請選擇喜好運動"
        self.hobbyPickerV.isUserInteractionEnabled = true
        hobbyPickerV.delegate = self
        hobbyPickerV.dataSource = self
        hobbyPickerV.removeFromSuperview()
        hobbyPickerTxt.inputView = hobbyPickerV
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func closeKeyboard(){
        self.view.endEditing(true)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sportType.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let text = self.sportType[row]
        self.hobbyPickerTxt.text = text
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sportType[row]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


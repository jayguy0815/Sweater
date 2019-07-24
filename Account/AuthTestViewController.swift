//
//  AuthTestViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/5/14.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import IQKeyboardManagerSwift

class AuthTestViewController: UIViewController,UITextFieldDelegate,SignUpViewControllerDelegate {
    
    var data : [String] = []
    
    func returnInfo(_ email: String, _ password: String) {
        print("Test")
        self.emailTextField.text = email
        self.passwordTextField.text = password
    }
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func login(_ sender: Any) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
                // 提示用戶是不是忘記輸入 textfield
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
            return
            
            
        }else{
            Firestore.firestore().collection("user_data").whereField("email", isEqualTo: self.emailTextField.text!).getDocuments { (snapshot, error) in
                if let err = error{
                    print(err)
                }
                guard let userData = snapshot?.documents else{
                    return
                }
                
                for doc in userData{
                    let state = doc.data()["issignin"] as! Bool
                    if state == true{
                        let alert =  UIAlertController(title: "Oops", message: "您已重複登入", preferredStyle: .alert)
                        let action = UIAlertAction(title: "好", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert,animated: true, completion: nil)
                    }else{
                        let nickname = doc.data()["nickname"] as! String
                        let hobby = doc.data()["hobby"] as! String
                        let uid = doc.documentID
                        UserDefaults.standard.set(uid, forKey: "uid")
                        UserDefaults.standard.set(nickname, forKey: "nickname")
                        
                        UserDefaults.standard.set(hobby, forKey: "hobby")
                        Storage.storage().reference().child("account").child("\(uid).jpg").getData(maxSize: 1*800*800, completion: { (data, error) in
                            if let err = error{
                                print(err)
                            }
                            guard let imagedata = data else{
                                return
                            }
                            UserDefaults.standard.set(imagedata, forKey: "profileImageData")
                        })
                        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { (user, error) in
                            if error != nil {
                                // 提示用戶從 firebase 返回了一個錯誤。
                                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                                alertController.addAction(defaultAction)
                                self.present(alertController, animated: true, completion: nil)
                                return
                            }else{
                                guard let uid = Auth.auth().currentUser?.uid else {
                                    return
                                }
                                Firestore.firestore().collection("user_data").document(uid).updateData(["issignin" : true])
                                let alert =  UIAlertController(title: "成功", message: "登入成功", preferredStyle: .alert)
                                let action = UIAlertAction(title: "好", style: .default, handler: { (_) in
                                    self.dismiss(animated: true, completion: nil)
                                })
                                alert.addAction(action)
                                self.present(alert,animated: true, completion: nil)
                                
                            }
                        }
                        
                }
                
            
              
                    
                   
                    
                    
                   
                }
            }
            
            
            
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.layer.cornerRadius = 53
        imageView.image = UIImage(named: "SweaterLogo")
        emailTextField.delegate = self
        emailTextField.backgroundColor = UIColor.white
        emailTextField.placeholder = "E-mail"
        emailTextField.keyboardType = .default
        passwordTextField.delegate = self
        passwordTextField.backgroundColor = UIColor.white
        passwordTextField.placeholder = "Password"
        passwordTextField.keyboardType = .default
        passwordTextField.isSecureTextEntry = true
        self.navigationController?.isNavigationBarHidden = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
    }
   
    
    
    @IBAction func check(_ sender: Any) {
            let user = Auth.auth().currentUser;
            if (user != nil) {
                print("1")
            } else {
                print("0")
            }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func closeKeyboard(){
        self.view.endEditing(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        print("deinit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
         return navigationController?.topViewController is AuthTestViewController ? true : false
    }
}

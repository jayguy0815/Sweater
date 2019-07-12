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
                    Storage.storage().reference().child("account").child("\(uid).jpg").getData(maxSize: 1*1024*1024, completion: { (data, error) in
                        if let error = error {
                            print("*** ERROR DOWNLOAD IMAGE : \(error)")
                        } else {
                            // Success
                            if let imageData = data {
                                // 3 - Put the image in imageview
                                DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                                    
                                    UserDefaults.standard.set(imageData, forKey: "userProfileImage")
                                })
                            }
                        }
                    })
                    //Database.database().reference().child("user_account").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
//                        if let dic = snapshot.value as? [String:Any]{
//                            let url = dic["url"] as! String
//                            // 创建一个会话，这个会话可以复用
//                            let session = URLSession()
//                            // 设置URL
//                            let request = URLRequest(url: URL(string: url)!)
//                            // 创建一个网络任务
//                            let task = session.dataTask(with: request) {(data, response, error) in
//                                do {
//                                    // 返回的是一个json，将返回的json转成字典r
//                                    let r = try
//                                    print(r)
//                                } catch {
//                                    // 如果连接失败就...
//                                    print("无法连接到服务器")
//                                    return
//                                }
//                            }
//                            // 运行此任务
//                            task.resume()
//                        }
//                    })
                    self.dismiss(animated: true, completion: nil)
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

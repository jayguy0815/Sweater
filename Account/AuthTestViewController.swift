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
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

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
import Photos
import RSKImageCropper


protocol SignUpViewControllerDelegate {
    func returnInfo(_ email : String,_ password : String)
}
class SignUpViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource ,UITextFieldDelegate{
    
    var sportType : [String] = ["籃球","排球","羽球","桌球","棒球","足球","游泳","單車","慢跑","登山","健身"]
    
    var hobbyPickerV = UIPickerView()
    @IBOutlet weak var accountImageView: UIImageView!
    @IBOutlet weak var cameraIconImageView: UIImageView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var comfirmPasswordTextField: UITextField!
    @IBOutlet weak var hobbyPickerTxt: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
 
    var delegate : SignUpViewControllerDelegate!
    //資料庫ref
    var ref : DatabaseReference! = Database.database().reference()
    var storageRef = Storage.storage().reference()
    var url : String = ""
    
    
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
                    guard let uid = Auth.auth().currentUser?.uid else{
                        return
                    }
                    guard let nickname = self.nickNameTextField.text else{
                        return
                    }
                    guard let hobby = self.hobbyPickerTxt.text else {
                        return
                    }
                    guard let image = self.accountImageView.image else {
                        return
                    }
                    guard let data = image.jpegData(compressionQuality: 0.5) else{
                        return
                    }
                    UserDefaults.standard.set(uid, forKey: "uid")
                    UserDefaults.standard.set(nickname, forKey: "nickname")
                    UserDefaults.standard.set(data, forKey: "profileImageData")
                    UserDefaults.standard.set(hobby, forKey: "hobby")
                    
                    if let uploadData = self.accountImageView.image!.jpegData(compressionQuality: 0.5){
                        Storage.storage().reference().child("account").child("\(uid).jpg").putData(uploadData, metadata: nil, completion: { (data, error) in
                            if error != nil {
                                print("Error: \(error!.localizedDescription)")
                                return
                            }
                            
                            Storage.storage().reference().child("account").child("\(uid).jpg").downloadURL(completion: { (url, error) in
                                if let err = error{
                                    print(err)
                                }
                                guard let newurl = url else{
                                    return
                                }
                                self.url = newurl.absoluteString
                                let time = Double(Date().timeIntervalSince1970)
                                
                               
                                if Auth.auth().currentUser != nil{
                                    try? Auth.auth().signOut()
                                }
                                let alertController = UIAlertController(title: "Success", message: "註冊成功", preferredStyle: .alert)
                                let alertAction = UIAlertAction(title: "返回", style: .default, handler: { (action) in
                                    let accountArr : [String:Any] = ["uid":uid,"username":self.nameTextField.text!,"email":self.emailTextField.text!,"nickname":self.nickNameTextField.text!,"hobby":self.hobbyPickerTxt.text!,"accountImageURL":self.url,"postTime":time,"modifiedTime":time,"issignin":false]
                                    
                                    Firestore.firestore().collection("user_data").document(uid).setData(accountArr)
                                    let email = self.emailTextField.text
                                    let password = self.passwordTextField.text
                                    guard let vc = self.navigationController?.viewControllers[0] as? UIViewController else{return}
                                    self.delegate = vc as? SignUpViewControllerDelegate
                                    self.delegate.returnInfo(email!, password!)
                                    self.navigationController?.popToViewController(vc, animated: true)
                                })
                                alertController.addAction(alertAction)
                                self.present(alertController,animated: true,completion: nil)
                                print("You have successfully signed up")
                            })
                        })
                        
                    }
                    
                    
                    
                   
                }
                // add account data to firebase
                else {
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
    
    @objc private func tap(_ sender : Any) {
        let alertController = UIAlertController(title: "選擇大頭貼", message: "選擇來源", preferredStyle: .actionSheet)
        let imagePicker = UIImagePickerController()
        let cameraAction = UIAlertAction(title: "相機", style: .default) { (action) in
            imagePicker.sourceType = .camera
            //imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.show(imagePicker, sender: nil)
        }
        
        let albumAction = UIAlertAction(title: "相簿", style: .default) { (action) in
            imagePicker.sourceType = .photoLibrary
            //imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.show(imagePicker, sender: nil)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .default, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(albumAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        cameraIconImageView.layer.cornerRadius = 20
        cameraIconImageView.clipsToBounds = false
        cameraIconImageView.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        cameraIconImageView.image = UIImage(named: "signUpCameraIcon")
        
        
        accountImageView.layer.cornerRadius = 100
        accountImageView.backgroundColor = .gray
        accountImageView.clipsToBounds = true
        accountImageView.isUserInteractionEnabled = true
        accountImageView.image = UIImage(named: "defaultAccountImage")
        let tapGestureRegnizer = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        accountImageView.addGestureRecognizer(tapGestureRegnizer)
        
       
        
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

extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
            var imageCropVC : RSKImageCropViewController!
            imageCropVC = RSKImageCropViewController(image: image, cropMode: RSKImageCropMode.circle)
            imageCropVC.delegate = self
            imageCropVC.avoidEmptySpaceAroundImage = true
            imageCropVC.alwaysBounceHorizontal = true
            imageCropVC.alwaysBounceVertical = true
        
            picker.pushViewController(imageCropVC, animated: true)
        
        
    }
}

extension SignUpViewController: RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource {
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        let fullScreen = UIScreen.main.bounds
        let maskSize = CGSize(width: fullScreen.width-20, height: fullScreen.height-60)
        let viewWidth = CGSize(width: controller.view.frame.width, height: controller.view.frame.height ).width
        let maskRect = CGRect(x: (viewWidth - maskSize.width) * 0.5, y: 10, width: maskSize.width, height: maskSize.height)
        return maskRect
        
    }
    
    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        let rect = controller.maskRect
        let area = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        return area
    }
    
    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        return controller.maskRect
    }
    
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.accountImageView.image = croppedImage
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

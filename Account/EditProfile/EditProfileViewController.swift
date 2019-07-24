//
//  EditProfileViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/7/20.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase
import RSKImageCropper

class EditProfileViewController: UIViewController {
   
    @IBOutlet weak var hobbyPickerView: UIPickerView!
    @IBAction func saveBtnPressed(_ sender: Any) {
        let index1 = IndexPath(row: 0, section: 1)
        let index2 = IndexPath(row: 0, section: 2)
        let cell1 = tableView.cellForRow(at: index1) as! NicknameCell
        let cell2 = tableView.cellForRow(at: index2) as! HobbyCell
        guard cell1.nicknameTextFiel.text != "" && cell2.hobbyTextField.text != "" else {
            let alertCon = UIAlertController(title: "錯誤", message: "暱稱及興趣接不能為空白", preferredStyle: .alert)
            let action = UIAlertAction(title: "好", style: .default, handler: nil)
            alertCon.addAction(action)
            self.present(alertCon,animated: true,completion: nil)
            return
        }
        let nickname1 = cell1.nicknameTextFiel.text!
        let hobby1 = cell2.hobbyTextField.text!
        guard let imagedata = self.image.jpegData(compressionQuality: 0.5) else {
            return
        }
        UserDefaults.standard.set(imagedata,forKey: "profileImageData")
        UserDefaults.standard.set(nickname1, forKey: "nickname")
        UserDefaults.standard.set(hobby1, forKey: "hobby")
        guard let uid = UserDefaults.standard.string(forKey: "uid") else {
            return
        }
        Storage.storage().reference().child("account").child("\(uid).jpg").putData(imagedata, metadata: nil) { (metadata, error) in
            if let err = error{
                print(err)
            }
            Storage.storage().reference().child("account").child("\(uid).jpg").downloadURL(completion: { (url, error) in
                if let err = error {
                    print(err)
                }
                guard let newurl = url else{
                    return
                }
                let time = Double(Date().timeIntervalSince1970)
                let dic : [String:Any] = ["accountImageURL":newurl.absoluteString,"hobby":hobby1,"nickname":nickname1,"modifiedTime":time]
                Firestore.firestore().collection("user_data").document(uid).updateData(dic, completion: { (error) in
                    if let err = error{
                        print(err)
                    }else{
                        print("user:\(uid) mod success")
                        let alertController = UIAlertController(title: "完成", message: "已儲存您的更改", preferredStyle: .alert)
                        let okaction = UIAlertAction(title: "好", style: .default, handler: { (action) in
                            self.navigationController?.popViewController(animated: true)
                        })
                        alertController.addAction(okaction)
                        self.present(alertController,animated: true,completion: nil)
                    }
                })
            })
        }
    
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var image : UIImage!
    var hobby : String!
    var name : String!
    var hobbyList = ["籃球","健身","棒球","游泳","足球","排球","羽球","網球"]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationItem.title = "編輯個人資訊"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor(named: "backGreen")
        tableView.dataSource = self
        tableView.delegate = self
        hobbyPickerView.dataSource = self
        hobbyPickerView.delegate = self
        hobbyPickerView.removeFromSuperview()
        
        // Do any additional setup after loading the view.
    }
    
    
    
}

extension EditProfileViewController : UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileImageCell") as! ProfileImageCell
        
        let cell1 = tableView.dequeueReusableCell(withIdentifier: "nicknameCell") as! NicknameCell
        
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "hobbyCell") as! HobbyCell
        
        if indexPath.section == 0 {
            
            cell.profileImage.image = self.image
            return cell
        }else if indexPath.section == 1 {
            
            cell1.nicknameTextFiel.text = self.name
            return cell1
        }
        cell2.hobbyTextField.text = self.hobby
        cell2.hobbyTextField.inputView = self.hobbyPickerView
        return cell2
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "編輯大頭貼"
        }else if section == 1{
            return "編輯暱稱"
        }
        return "編輯興趣"
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 10, y: 5, width: 320, height: 10)
        myLabel.font = UIFont.boldSystemFont(ofSize: 10)
        myLabel.textColor = .lightGray
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        let headerView = UIView()
        headerView.addSubview(myLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 300
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            
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
    }
    
    
}

extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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

extension EditProfileViewController : RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource{
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect, rotationAngle: CGFloat) {
        self.image = croppedImage
        self.tableView.reloadData()
        controller.dismiss(animated: true, completion: nil)
        
        
    }
    
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
    
    
}

extension EditProfileViewController : UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.hobbyList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return hobbyList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let indexPath = IndexPath(row: 0, section: 2)
        let cell = self.tableView.cellForRow(at: indexPath) as! HobbyCell
        cell.hobbyTextField.text = hobbyList[row]
    }
    
    
}


//
//  CreateActivityViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/12.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import MapKit

class CreateActivityViewController: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate {

    @IBOutlet weak var sportlabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var peopleTextfield: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var peoplePicker: UIPickerView!
    
    var sportType : String?
    let errorText : String = "錯誤"
    let pleaseEnter : String = "請輸入"
    let methods = Methods()
    var activity : [String : Any] = [:]
    var people : [Int] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "backGreen")
        // MARK - Navigation Item
        self.navigationItem.title = "建立揪團"
        let customBackButton = methods.setNavigationBar()
        self.view.addSubview(customBackButton)
        self.navigationItem.setHidesBackButton(true, animated:false)
        let backTap = UITapGestureRecognizer(target: self, action: #selector(back))
        customBackButton.addGestureRecognizer(backTap)
        let leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        
        // MARK - Form
        self.sportlabel.text = sportType
        self.nameTextField.placeholder = "團名須小於20字"
        self.dateTextField.placeholder = "請選擇日期"
        self.peopleTextfield.placeholder = "請選擇人數上限"
        
        // MARK - TextView
        contentTextView.delegate = self
        self.contentTextView.textColor = UIColor.lightGray
        self.contentTextView.text = "必填，須小於50字"
        
        // MARK - DatePicker
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 30
        datePicker.date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let fromDate = formatter.date(from: methods.getDate())
        datePicker.minimumDate = fromDate
        let endDate = formatter.date(from: "2030-12-31 23:59")
        datePicker.maximumDate = endDate
        datePicker.locale = Locale(identifier: "zh-TW")
        datePicker.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: .valueChanged)
        datePicker.removeFromSuperview()
        self.dateTextField.inputView = datePicker
        
        // MARK - People Picker
        peoplePicker.delegate = self
        peoplePicker.dataSource = self
        peoplePicker.removeFromSuperview()
        self.peopleTextfield.inputView = peoplePicker
        // Do any additional setup after loading the view.
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.activity = ["name"
            :self.nameTextField.text!,"date":self.dateTextField.text!,"people":self.peopleTextfield.text!,"content":self.contentTextView.text!]
        
        guard let mapVC = segue.destination as? MapViewController else{
            return
        }
        mapVC.activity = self.activity
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard self.nameTextField.text! != "" else {
            let alertController = methods.newAlert(Title: self.errorText, Message: "請輸入團名", actionTitle: "OK")
            present(alertController,animated: true,completion: nil)
            return false
        }
        guard self.nameTextField.text!.count <= 20 else {
            let alertController = methods.newAlert(Title: self.errorText, Message: "團名須小於20字", actionTitle: "OK")
            present(alertController,animated: true,completion: nil)
            return false
        }
        guard self.dateTextField.text! != "" else {
            let alertController = methods.newAlert(Title: self.errorText, Message: "請選擇日期", actionTitle: "OK")
            present(alertController,animated: true,completion: nil)
            return false
        }
        guard self.peopleTextfield.text! != "" else {
            let alertController = methods.newAlert(Title: self.errorText, Message: "請選擇人數限制", actionTitle: "OK")
            present(alertController,animated: true,completion: nil)
            return false
        }
        guard self.contentTextView.text! != "" else {
            let alertController = methods.newAlert(Title: self.errorText, Message: "請輸入簡介", actionTitle: "OK")
            present(alertController,animated: true,completion: nil)
            return false
        }
        guard self.contentTextView.text!.count <= 50 else {
            let alertController = methods.newAlert(Title: self.errorText, Message: "簡介須小於50字", actionTitle: "OK")
            present(alertController,animated: true,completion: nil)
            return false
        }
        return true
    }
    
    @objc func datePickerChanged(datePicker : UIDatePicker){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        self.dateTextField.text = formatter.string(from: datePicker.date)
    }

}

extension CreateActivityViewController : UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray{
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
}

extension CreateActivityViewController : UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.people.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let text = "\(self.people[row])"
        self.peopleTextfield.text = text
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(people[row])"
    }
    
}

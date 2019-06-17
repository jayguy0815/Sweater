//
//  MainViewController.swift
//  Sweater
//
//  Created by Leo Huang on 2019/6/11.
//  Copyright © 2019 Leo Huang. All rights reserved.
//

import UIKit
import Firebase
import IQKeyboardManagerSwift

class MainViewController: UIViewController,UINavigationControllerDelegate {
    @IBOutlet weak var logout: UIButton!

    @IBOutlet weak var basketballBtn: UIButton!
    
    @IBAction func basketballBtnPressed(_ sender: Any) {
        
    }
    
    
    @IBAction func logoutBtn(_ sender: Any) {
        if Auth.auth().currentUser != nil{
            do{
                try Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "nav")
                self.present(vc,animated: true,completion: nil)
            }catch{
                    print("logout failed:\(error.localizedDescription)")
            }
        }
    }
    
    
    @IBAction func check(_ sender: Any) {
        let user = Auth.auth().currentUser
        
        if (user != nil) {
            print("1")
        } else {
            print("0")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user == nil {
                self.switchStoryboard()
            }
        }
        
        
       
        if let img = UIImage(named: "background"){
            self.view.backgroundColor = UIColor(patternImage: img)
        }
    }
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Sweater"
        
        self.basketballBtn.setTitle("", for: .normal)
        
        // Do any additional setup after loading the view.
    }
    
    func switchStoryboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "nav")
        self.present(vc,animated: true,completion: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        print("main deinit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "basketball"{
            let createVC = segue.destination as! CreateActivityViewController
            createVC.sportType = "籃球"
        }
    }
    
    
}

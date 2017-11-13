//
//  ChangePasswordVC.swift
//  TickTok User
//
//  Created by Excellent Webworld on 11/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ChangePasswordVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        
        let str = txtNewPassword.text
        
        if txtNewPassword.text == txtConfirmPassword.text {
        
            if str!.characters.count >= 8  {
                webserviceOfChangePassword()
            }
            else {
                UtilityClass.showAlert("Missing", message: "Password should be minimum 8 characters.", vc: self)
            }
        }
        else {
             UtilityClass.showAlert("Password did not match", message: "Please re-enter password", vc: self)
        }
        
    }
    
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    func webserviceOfChangePassword() {
        
    
        var dictData = [String:AnyObject]()
        
        dictData["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        dictData["Password"] = txtNewPassword.text as AnyObject
        
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        webserviceForChangePassword(dictData as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                
                UtilityClass.showAlert("", message: (result as! NSDictionary).object(forKey: "message") as! String, vc: self)
                
                self.navigationController?.popViewController(animated: true)
                
            }
            else {
                 print(result)
            }
        }
        
    }
    

}
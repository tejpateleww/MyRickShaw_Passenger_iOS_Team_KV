//
//  ChangePasswordVC.swift
//  TickTok User
//
//  Created by Excellent Webworld on 11/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import ACFloatingTextfield_Swift

class ChangePasswordVC: UIViewController, UITextFieldDelegate {

    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (DeviceType.IS_IPHONE_X) {
            constraintOfNavigationViewHeight.constant = 88
        }

        btnSubmit.layer.cornerRadius = 5
        btnSubmit.layer.masksToBounds = true
        
        txtNewPassword.delegate = self
        txtConfirmPassword.delegate = self
    }


    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var txtNewPassword: UITextField! //ACFloatingTextfield!
    @IBOutlet weak var txtConfirmPassword: UITextField! // ACFloatingTextfield!
    @IBOutlet weak var btnSubmit: UIButton!
    @IBOutlet weak var constraintOfNavigationViewHeight: NSLayoutConstraint! // 64
    
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        
        let str = txtNewPassword.text
        
        if validation() {
             webserviceOfChangePassword()
        }
        //        if txtNewPassword.text == txtConfirmPassword.text {
//
//            if str!.count >= 8  {
//                webserviceOfChangePassword()
//            }
//            else {
//                UtilityClass.setCustomAlert(title: appName, message: "Password should be minimum 8 characters.") { (index, title) in
//                }
//            }
//        }
//        else {
//            UtilityClass.setCustomAlert(title: "Password did not match", message: "Please re-enter password") { (index, title) in
//            }
//        }
        
    }
    
    func validation() -> Bool {
        
        if txtNewPassword?.text!.count == 0 {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter password") { (index, title) in
            }
            return false
        }
        else if (txtNewPassword?.text!.count)! <= 7 {
            UtilityClass.setCustomAlert(title: appName, message: "Password must contain at least 8 characters") { (index, title) in
            }
            return false
        }
        else if txtConfirmPassword?.text!.count == 0 {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter confirm password") { (index, title) in
            }
            return false
        }
        else if txtNewPassword?.text! != txtConfirmPassword?.text! {
            UtilityClass.setCustomAlert(title: appName, message: "New password and confirm password must be same") { (index, title) in
            }
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
        if txtNewPassword == textField {
           txtNewPassword.text = txtNewPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if txtConfirmPassword == textField {
            txtConfirmPassword.text = txtConfirmPassword.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
    }

    
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var btnCall: UIButton!
    @IBAction func btCallClicked(_ sender: UIButton)
    {
        
        let contactNumber = helpLineNumber
        
        if contactNumber == "" {
            
            UtilityClass.setCustomAlert(title: appName, message: "Contact number is not available") { (index, title) in
            }
        }
        else
        {
            callNumber(phoneNumber: contactNumber)
        }
    }
    
    private func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
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
                
                UtilityClass.setCustomAlert(title: appName, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.navigationController?.popViewController(animated: true)
                    })
                }
                
//                UtilityClass.showAlert("", message: (result as! NSDictionary).object(forKey: "message") as! String, vc: self)
                
                
                
            }
            else {
                 print(result)
                
//                UtilityClass.setCustomAlert(title: <#T##String#>, message: <#T##String#>, completionHandler: { (<#Int#>, <#String#>) in
//                    <#code#>
//                })
                
            }
        }
        
    }
    

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

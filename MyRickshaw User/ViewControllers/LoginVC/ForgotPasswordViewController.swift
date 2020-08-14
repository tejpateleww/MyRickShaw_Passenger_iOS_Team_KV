//
//  ForgotPasswordViewController.swift
//  MyRickshaw User
//
//  Created by Excelent iMac on 03/08/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit
import ACFloatingTextfield_Swift


class ForgotPasswordViewController: UIViewController {
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

       self.navigationItem.title = "Forgot Password"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnResetPassword(_ sender: UIButton) {
        
        if validation() {
            webserviceCallForForgotPassword(strEmail : txtEmail.text!)
        }
    }
    
    @IBAction func btnBack(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func validation() -> Bool {
        
        let isEmailAddressValid = isValidEmailAddress(emailID: txtEmail.text!)
        
        if txtEmail.text == "" {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter email id") { (index, title) in
            }
            return false
        }
        else if !isEmailAddressValid {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter valid email id") { (index, title) in
            }
            return false
        }
        
        return true
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Call for Forgot Password
    //-------------------------------------------------------------
    
    func webserviceCallForForgotPassword(strEmail : String)
    {
        let dictparam = NSMutableDictionary()
        dictparam.setObject(strEmail, forKey: "Email" as NSCopying)
        
        webserviceForForgotPassword(dictparam) { (result, status) in
           
            if ((result as! NSDictionary).object(forKey: "status") as! Int == 1) {
                
                UtilityClass.setCustomAlert(title: "Success", message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                
                UtilityClass.setCustomAlert(title: appName, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                }
            }
        }
    }
    
    


}

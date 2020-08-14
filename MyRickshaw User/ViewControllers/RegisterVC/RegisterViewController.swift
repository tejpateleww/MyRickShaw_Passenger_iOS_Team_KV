//
//  RegisterViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 25/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import ACFloatingTextfield_Swift
import TransitionButton

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var txtPhoneNumber: ACFloatingTextfield!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var txtPassword: ACFloatingTextfield!
    @IBOutlet weak var txtConfirmPassword: ACFloatingTextfield!
    
    @IBOutlet weak var stackViewFroTextFields: UIStackView!
    @IBOutlet weak var btnNext: TransitionButton!
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtPhoneNumber.delegate = self
        txtEmail.delegate = self
        txtPhoneNumber.delegate = self
        
        //        txtPhoneNumber.text = "1234567890"
        //        txtEmail.text = "rahul.bbit@gmail.com"
        //        txtPassword.text = "12345678"
        //        txtConfirmPassword.text = "12345678"
        
        
//        txtPhoneNumber.placeHolderColor = UIColor.red
        // Do any additional setup after loading the view.
        
        if !(DeviceType.IS_IPHONE_5) {
            stackViewFroTextFields.spacing = 30
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        btnNext.layer.cornerRadius = (btnNext.frame.size.height / 2)
        btnNext.giveShadowToBottomView(item: btnNext, shadowColor: themeYellowColor)
        
    }
    
    
    
    //-------------------------------------------------------------
    // MARK: - TextField Delegate Method
    //-------------------------------------------------------------
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtPhoneNumber {
            let resultText: String? = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            
            if resultText!.count >= 11 {
                return false
            }
            else {
                return true
            }
        }
        
        if textField == txtEmail {
           txtEmail.text = txtEmail.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if textField == txtPhoneNumber {
            txtPhoneNumber.text = txtPhoneNumber.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return true
    }
    
    // MARK: - Navigation
    
    @IBAction func btnNext(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet() {

            if (validateAllFields()) {
                UserDefaults.standard.set(txtEmail.text!, forKey: RegistrationData.kRegEmail)
                UserDefaults.standard.set(txtPhoneNumber.text!, forKey: RegistrationData.kRegMobileNumber)
                webserviceForGetOTPCode(email: txtEmail.text!, mobile: txtPhoneNumber.text!)
            }
        }
        else {
            UtilityClass.setCustomAlert(title: InternetConnection.internetConnectionTitle, message: InternetConnection.internetConnectionMessage) { (index, msg) in
            }
        }

    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //-------------------------------------------------------------
    // MARK: - validation Email Methods
    //-------------------------------------------------------------
    
    func validateAllFields() -> Bool
    {
     
        let isEmailAddressValid = isValidEmailAddress(emailID: txtEmail.text!)
        
        if (txtPhoneNumber.text?.count == 0)
        {

            UtilityClass.setCustomAlert(title: appName, message: "Please enter phone number") { (index, title) in
            }

            return false
        }
        else if ((txtPhoneNumber.text?.count)! != 10)
        {

            UtilityClass.setCustomAlert(title: appName, message: "Please check phone number should 10 digits") { (index, title) in
            }

            return false
        }
        else if (txtEmail.text?.count == 0)
        {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter email address") { (index, title) in
            }

            return false
        }
        else if (!isEmailAddressValid)
        {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter valid email id") { (index, title) in
            }

            return false
        }
        else if (txtPassword.text?.count == 0)
        {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter password") { (index, title) in
            }

            return false
        }
            
        else if ((txtPassword.text?.count)! < 6)
        {
            UtilityClass.setCustomAlert(title: appName, message: "Password must contain at least 6 characters") { (index, title) in
            }

            return false
        }
        else if txtConfirmPassword.text == "" {
            
            UtilityClass.setCustomAlert(title: appName, message: "Please enter confirm password") { (index, title) in
            }
            
            return false
        }
        else if (txtPassword.text != txtConfirmPassword.text)
        {
            UtilityClass.setCustomAlert(title: appName, message: "Password and confirm password must be same") { (index, title) in
            }

            return false
        }
       
        
        return true
    }
    
    
    func isValidEmailAddress(emailID: String) -> Bool
    {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z)-9.-]+\\.[A-Za-z]{2,3}"
        
        do{
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailID as NSString
            let results = regex.matches(in: emailID, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
        }
        catch _ as NSError
        {
            returnValue = false
        }
        
        return returnValue
    }
    
    func setCustomAlert(title: String, message: String) {
        AJAlertController.initialization().showAlertWithOkButton(aStrTitle: title, aStrMessage: message) { (index,title) in
        }
     
    }
    
    func webserviceForGetOTPCode(email: String, mobile: String) {
        
//        Param : MobileNo,Email

        
        var param = [String:AnyObject]()
        param["MobileNo"] = mobile as AnyObject
        param["Email"] = email as AnyObject
        
        var boolForOTP = Bool()
        
        webserviceForOTPRegister(param as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                let datas = (result as! [String:AnyObject])
                
                
                UtilityClass.showAlertWithCompletion("OTP Code", message: datas["message"] as! String, vc: self, completionHandler: { ACTION in
                    
                    if let otp = datas["otp"] as? String {
                        SingletonClass.sharedInstance.otpCode = otp
                    }
                    else if let otp = datas["otp"] as? Int {
                        SingletonClass.sharedInstance.otpCode = "\(otp)"
                    }
                    UtilityClass.hideACProgressHUD()
                    UtilityClass.hideHUD()
                    
                    
                    let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
                    registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
                    registrationContainerVC.pageControl.set(progress: 1, animated: true)
                    
                    UtilityClass.hideACProgressHUD()
                    UtilityClass.hideHUD()
                    
                })
                
//                UtilityClass.setCustomAlert(title: "OTP Code", message: datas["message"] as! String, completionHandler: { (index, title) in
//
//                    if let otp = datas["otp"] as? String {
//                        SingletonClass.sharedInstance.otpCode = otp
//                    }
//                    else if let otp = datas["otp"] as? Int {
//                        SingletonClass.sharedInstance.otpCode = "\(otp)"
//                    }
//
//
//                    let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
//                    registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
//                    registrationContainerVC.pageControl.set(progress: 1, animated: true)
//
//
//                    let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
//                    registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
//                    registrationContainerVC.pageControl.set(progress: 1, animated: true)
      
                
            }
            else {
                 print(result)
                
                if let res = result as? String {
                    UtilityClass.setCustomAlert(title: appName, message: res) { (index, title) in
                    }
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.setCustomAlert(title: appName, message: resDict.object(forKey: "message") as! String) { (index, title) in
                    }
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.setCustomAlert(title: appName, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    }
                }
                
            }
        }
    }
    
}

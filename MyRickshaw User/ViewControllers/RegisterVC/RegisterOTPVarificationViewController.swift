//
//  RegisterOTPVarificationViewController.swift
//  PickNGo User
//
//  Created by Excelent iMac on 17/02/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit
import ACFloatingTextfield_Swift
import TransitionButton

class RegisterOTPVarificationViewController: UIViewController {


    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UtilityClass.hideACProgressHUD()
        UtilityClass.hideHUD()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        btnNext.layer.cornerRadius = (btnNext.frame.size.height / 2)
        btnNext.giveShadowToBottomView(item: btnNext, shadowColor: themeYellowColor)
        UtilityClass.hideACProgressHUD()
        UtilityClass.hideHUD()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var txtOTP: ACFloatingTextfield!
    @IBOutlet weak var btnNext: TransitionButton!
    
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnNext(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet() {
            
            if (txtOTP.text?.isEmpty)! {
                UtilityClass.setCustomAlert(title: "\(appName)", message: "Please enter OTP code", completionHandler: { (index, title) in
                    
                })
            }
            else if SingletonClass.sharedInstance.otpCode == txtOTP.text {
                
                let registrationContainerVC = self.navigationController?.viewControllers.last as! RegistrationContainerViewController
                registrationContainerVC.scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width * 2, y: 0), animated: true)
                registrationContainerVC.pageControl.set(progress: 2, animated: true)
            }
            else
            {
                UtilityClass.setCustomAlert(title: "\(appName)", message: "Please enter valid OTP code", completionHandler: { (index, title) in
                    
                })
            }
        }
        else {
            UtilityClass.setCustomAlert(title: InternetConnection.internetConnectionTitle, message: InternetConnection.internetConnectionMessage) { (index, msg) in
            }
        }
    }
    
    @IBAction func btnResendOTP(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet() {
            
            guard let emailId = UserDefaults.standard.object(forKey: RegistrationData.kRegEmail) else {
                print("did not get EmailId")
                return
            }
            guard let mobileNo = UserDefaults.standard.object(forKey: RegistrationData.kRegMobileNumber) else {
                print("did not get EmailId")
                return
            }
//
            webserviceForGetOTPCode(email: emailId as! String, mobile: mobileNo as! String)
        }
        else {
            UtilityClass.setCustomAlert(title: InternetConnection.internetConnectionTitle, message: InternetConnection.internetConnectionMessage) { (index, msg) in
            }
        }
        
    }
    
    
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    
    func webserviceForGetOTPCode(email: String, mobile: String) {
        
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
                })
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

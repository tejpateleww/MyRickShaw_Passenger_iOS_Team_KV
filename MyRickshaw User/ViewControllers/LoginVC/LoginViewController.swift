//
//  LoginViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 25/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import Foundation
import UIKit
import TransitionButton
import ACFloatingTextfield_Swift
//import SideMenu
import NVActivityIndicatorView
import CoreLocation

class LoginViewController: UIViewController, CLLocationManagerDelegate, alertViewMethodsDelegates {
    
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var txtPassword: ACFloatingTextfield!
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var btnLogin: TransitionButton!
    @IBOutlet weak var btnSignup: TransitionButton!
    @IBOutlet weak var ConstraintOfBottomOfCloseImage: NSLayoutConstraint! //1.187
    @IBOutlet weak var constraintOfSocialIconRatio: NSLayoutConstraint!
    
    
    
    
    var locationManager = CLLocationManager()

    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func loadView() {
        super.loadView()
        
//        if Connectivity.isConnectedToInternet() {
//            print("Yes! internet is available.")
//            // do some tasks..
//
//            if(SingletonClass.sharedInstance.isUserLoggedIN)
//            {
//                self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
//            }
//        }
//        else {
//
//            UtilityClass.setCustomAlert(title: "Connection Error", message: "Internet connection not available") { (index, title) in
//            }
//        }
        
//        webserviceOfAppSetting()
        
        locationManager.requestAlwaysAuthorization()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            if locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))
            {
                if locationManager.location != nil
                {
                    locationManager.startUpdatingLocation()
                    locationManager.delegate = self
                    
                }
                
                //                manager.startUpdatingLocation()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        viewMain.isHidden = true
        
//        txtEmail.lineColor = UIColor.white
//        txtPassword.lineColor = UIColor.white
        
        
        if (DeviceType.IS_IPHONE_X) {
            
            let newConstraint = self.ConstraintOfBottomOfCloseImage.constraintWithMultiplier(1.176)
            self.view!.removeConstraint(self.ConstraintOfBottomOfCloseImage)
            //             self.imgClose!.addConstraint(self.ConstraintOfBottomOfCloseImage = newConstraint as NSLayoutConstraint)
            ConstraintOfBottomOfCloseImage = newConstraint
            self.view!.addConstraint(ConstraintOfBottomOfCloseImage)
            self.view!.layoutIfNeeded()
            
        }
        
        if !(DeviceType.IS_IPHONE_5) {
            constraintOfSocialIconRatio.constant = 45
        }
        
        if UIDevice.current.name == "Bhavesh iPhone" || UIDevice.current.name == "Excellent Web's iPhone 5s" || UIDevice.current.name == "Rahul's iPhone" || UIDevice.current.name == "EWW’s iPhone 6s" || UIDevice.current.name == "Excellent iPhone 7" || UIDevice.current.name == "Excellent’s iPhone One" {
            
            txtEmail.text = "9998359464"
            txtPassword.text = "12345678"
        }
       
        
        #if targetEnvironment(simulator)
            txtEmail.text = "9998359464"
            txtPassword.text = "12345678"
        #endif
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
        
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        btnLogin.layer.cornerRadius = (btnLogin.frame.size.height / 2)
        btnLogin.giveShadowToBottomView(item: btnLogin, shadowColor: themeYellowColor)
        
        self.btnLogin.setTitle("Login", for: .normal)
    
//        btnLogin.layer.shadowColor = themeYellowColor.cgColor
//        btnLogin.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
//        btnLogin.layer.shadowOpacity = 1.0
//        btnLogin.layer.shadowRadius = 0.0
//        btnLogin.layer.masksToBounds = false
       
    }
    
    @IBAction func btnClose(_ sender: UIButton) {

        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Validation
    
    func checkValidation() -> Bool
    {
        if (txtEmail.text?.count == 0)
        {

            UtilityClass.setCustomAlert(title: appName, message: "Please enter mobile number") { (index, title) in
            }
            
             // txtEmail.showErrorWithText(errorText: "Enter Email")
            return false
        }
        else if (txtPassword.text?.count == 0)
        {

            UtilityClass.setCustomAlert(title: appName, message: "Please enter password") { (index, title) in
            }

            return false
        }
        return true
    }
    
    
    //MARK: - Webservice Call for Login
    
    func webserviceCallForLogin()
    {
       
        let dictparam = NSMutableDictionary()
        dictparam.setObject(txtEmail.text!, forKey: "Username" as NSCopying)
        dictparam.setObject(txtPassword.text!, forKey: "Password" as NSCopying)
        dictparam.setObject("1", forKey: "DeviceType" as NSCopying)
        dictparam.setObject("6287346872364287", forKey: "Lat" as NSCopying)
        dictparam.setObject("6287346872364287", forKey: "Lng" as NSCopying)
        dictparam.setObject(SingletonClass.sharedInstance.deviceToken, forKey: "Token" as NSCopying)
        
        webserviceForDriverLogin(dictparam) { (data, result, status) in
            
            if ((result as! NSDictionary).object(forKey: "status") as! Int == 1)
            {
                DispatchQueue.main.async(execute: { () -> Void in

                    self.btnLogin.stopAnimation(animationStyle: .normal, completion: {
                        self.btnLogin.setTitle("Login", for: .normal)
                        
                        SingletonClass.sharedInstance.dictProfile = NSMutableDictionary(dictionary: (result as! NSDictionary).object(forKey: "profile") as! NSDictionary)
//                        SingletonClass.sharedInstance.arrCarLists = NSMutableArray(array: (result as! NSDictionary).object(forKey: "car_class") as! NSArray)
                        SingletonClass.sharedInstance.strPassengerID = String(describing: SingletonClass.sharedInstance.dictProfile.object(forKey: "Id")!)//as! String
                        SingletonClass.sharedInstance.isUserLoggedIN = true
                        
                        UserDefaults.standard.set(SingletonClass.sharedInstance.dictProfile, forKey: "profileData")
                        UserDefaults.standard.set(SingletonClass.sharedInstance.arrCarLists, forKey: "carLists")

                        
                        // get car List
                        let carList = (result as! [String:Any])["car_class"] as! [[String:Any]]
                        let convertCarListToData = NSKeyedArchiver.archivedData(withRootObject: carList)
                        
                        UserDefaults.standard.set(data, forKey: ModelDataConstant.kLoginResponse)
                        
                        SingletonClass.sharedInstance.carList = getCarListData()
                        
                        self.webserviceForAllDrivers()
                        
//                        self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
                    })
                })
            }
            else
            {
                self.btnLogin.stopAnimation(animationStyle: .shake, revertAfterDelay: 0, completion: {
                    self.btnLogin.setTitle("Login", for: .normal)
//                    let next = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertsViewController") as! CustomAlertsViewController
//                    next.delegateOfAlertView = self
//                    next.strTitle = "Error"
//                    next.strMessage = (result as! NSDictionary).object(forKey: "message") as! String
//                    self.navigationController?.present(next, animated: false, completion: nil)
//

                     UtilityClass.setCustomAlert(title: appName, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
            }

                })
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToHomeVC") {
       
        }
    }
    
    var aryAllDrivers = NSArray()
    func webserviceForAllDrivers()
    {
        webserviceForAllDriversList { (result, status) in
            
            if (status) {
                
                self.aryAllDrivers = ((result as! NSDictionary).object(forKey: "drivers") as! NSArray)
                
                SingletonClass.sharedInstance.allDiverShowOnBirdView = self.aryAllDrivers
              
                self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
            }
            else {
                print(result)
            }
        }
    }

    
     //MARK: - Webservice Call for Forgot Password
    
    func webserviceCallForForgotPassword(strEmail : String)
    {
        let dictparam = NSMutableDictionary()
        dictparam.setObject(strEmail, forKey: "MobileNo" as NSCopying)
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        webserviceForForgotPassword(dictparam) { (result, status) in
            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

            if ((result as! NSDictionary).object(forKey: "status") as! Int == 1) {
  
                 UtilityClass.setCustomAlert(title: appName, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                }
            }
            else {

                 UtilityClass.setCustomAlert(title: appName, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                }
            }
            
            
        }
    }
    
    func webserviceOfAppSetting() {
//        version : 1.0.0 , (app_type : AndroidPassenger , AndroidDriver , IOSPassenger , IOSDriver)

        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        let version = nsObject as! String
        
        print("Vewsion : \(version)")
        
        var param = String()
        param = version + "/" + "IOSPassenger"
        webserviceForAppSetting(param as AnyObject) { (result, status) in
            
            if (status) {
                print("result is : \(result)")

                self.viewMain.isHidden = false
                
                if ((result as! NSDictionary).object(forKey: "update") as? Bool) != nil {
                    
                    let alert = UIAlertController(title: appName, message: (result as! NSDictionary).object(forKey: "message") as? String, preferredStyle: .alert)
                    let UPDATE = UIAlertAction(title: "UPDATE", style: .default, handler: { ACTION in
                        
                    })
                    let Cancel = UIAlertAction(title: "Cancel", style: .default, handler: { ACTION in
                        
                        if(SingletonClass.sharedInstance.isUserLoggedIN)
                        {
//                            self.webserviceForAllDrivers()
                            self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
                        }
                    })
                    alert.addAction(UPDATE)
                    alert.addAction(Cancel)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    
                    if(SingletonClass.sharedInstance.isUserLoggedIN) {

                        self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
                    }
                }
            }
            else {
                print(result)

                if let update = (result as! NSDictionary).object(forKey: "update") as? Bool {
                    
                    if (update) {

                        UtilityClass.showAlertWithCompletion("", message: (result as! NSDictionary).object(forKey: "message") as! String, vc: self, completionHandler: { ACTION in
                            
                        })
                    }
                    else {

                         UtilityClass.setCustomAlert(title: appName, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                            if (index == 0)
                            {
                            }
                        }

                    }
                    
                }
            }
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func unwindToVC(segue: UIStoryboardSegue) {
    }
    
    
    
    @IBAction func btnLogin(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet() {
            
//            self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
            
            if (checkValidation()) {
//                self.btnLogin.startAnimation()
                self.webserviceCallForLogin()
            }
        }
        else {
            UtilityClass.setCustomAlert(title: InternetConnection.internetConnectionTitle, message: InternetConnection.internetConnectionMessage) { (index, msg) in
            }
        }
        
    }
    
    @IBAction func btnSignup(_ sender: Any) {
        
    }
    
    
    @IBAction func btnForgotPassword(_ sender: UIButton) {
/*
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Forgot Password?", message: "Enter Mobile Number", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            
            textField.placeholder = "Mobile Number"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            print("Text field: \(String(describing: textField?.text))")
            
            if (textField?.text?.count != 0)
            {
                self.webserviceCallForForgotPassword(strEmail: (textField?.text)!)
            }
            else {
                self.present(alert!, animated: true, completion: nil)
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
*/
        
        self.performSegue(withIdentifier: "segueForgotPassword", sender: nil)
        
//        let next = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordViewController") as! ForgotPasswordViewController
//        self.navigationController?.pushViewController(next, animated: true)
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Location Methods
    //-------------------------------------------------------------
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
//        print("Location: \(location)")
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
           
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    func didOKButtonPressed() {
        
    }
    
    func didCancelButtonPressed() {
        
    }
    
    
    func setCustomAlert(title: String, message: String) {
        AJAlertController.initialization().showAlertWithOkButton(aStrTitle: title, aStrMessage: message) { (index,title) in
        }
        
//        let next = self.storyboard?.instantiateViewController(withIdentifier: "CustomAlertsViewController") as! CustomAlertsViewController
//
//        next.delegateOfAlertView = self
//        next.strTitle = title
//        next.strMessage = message
//
//        self.navigationController?.present(next, animated: false, completion: nil)
        
    }
   
    
}

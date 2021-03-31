//
//  FirstScreenViewController.swift
//  MyRickshaw User
//
//  Created by Excelent iMac on 11/06/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit


class FirstScreenViewController: UIViewController {
    
    @IBOutlet weak var constraintCenterOfDimondImage: NSLayoutConstraint! // 1.02
    
    @IBOutlet weak var constraintWidthOfCarImage: NSLayoutConstraint! //
    
    @IBOutlet weak var btnContinue : UIButton?
    @IBOutlet weak var btnAbout : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImages()
        webserviceOfAppSetting()
        
        
        btnContinue?.imageView?.contentMode = .scaleAspectFit
            btnAbout?.imageView?.contentMode = .scaleAspectFit
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBOutlet weak var imgHomeScreen: UIImageView!
    
    func setImages() {
        
        if DeviceType.IS_IPHONE_5 {
            imgHomeScreen.image = UIImage(named: "iPhoneSE.jpg")
        } else if DeviceType.IS_IPHONE_6_7 {
            imgHomeScreen.image = UIImage(named: "iPhone8.jpg")
        } else if DeviceType.IS_IPHONE_6P_7P {
            imgHomeScreen.image = UIImage(named: "iPhone8Plus.jpg")
        } else if DeviceType.IS_IPHONE_X {
            imgHomeScreen.image = UIImage(named: "iPhoneX.jpg")
            
            
            //            let newConstraint2 = self.constraintWidthOfCarImage.constraintWithMultiplier(0.485)
            //            self.view!.removeConstraint(self.constraintWidthOfCarImage)
            //            constraintWidthOfCarImage = newConstraint2
            //
            //            self.view!.addConstraint(constraintWidthOfCarImage)
            //            self.view!.layoutIfNeeded()
        }
        
        
        if (DeviceType.IS_IPHONE_X) {
            
            let newConstraint = self.constraintCenterOfDimondImage.constraintWithMultiplier(1.12)
            //            self.view!.removeConstraint(self.constraintCenterOfDimondImage)
            
            let newConstraint2 = self.constraintWidthOfCarImage.constraintWithMultiplier(0.485)
            //            self.view!.removeConstraint(self.constraintWidthOfCarImage)
            
            self.view.removeConstraints([self.constraintCenterOfDimondImage])
            
            constraintCenterOfDimondImage = newConstraint
            constraintWidthOfCarImage = newConstraint2
            
            self.view!.addConstraints([self.constraintCenterOfDimondImage])
            
            //            self.view!.addConstraint(constraintCenterOfDimondImage)
            self.view!.layoutIfNeeded()
        }
        
        
        
        //        let people = ["asdf", "axcv", "basdf", "jkjhjk", "beadsf", "cvxcdf"]
        //        print(people)
        //
        //        let groupData = Dictionary(grouping: people, by: {$0.first!})
        //        print(groupData)
        //
        //        groupData["a".first! as! Character]
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    let strSite = "https://www.google.co.in/"
    let strWaihekeExpressTaxis = "https://waihekexpresstaxis.co.nz/"
    let strBudgetShuttlesAndValues = "http://budgetshuttles.co.nz/"
    let strBudgetTaxis = "http://185.123.99.150/~budgettaxis/"
    let strDiamondServices = "https://www.google.com/"
    
    
    @IBAction func btnContinue(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet() {
            
            if(SingletonClass.sharedInstance.isUserLoggedIN)
            {
                appDelegate.GoToHome()
            }
            else
            {
                appDelegate.GoToLogin()
                
            }
        }
        else {
            UtilityClass.setCustomAlert(title: InternetConnection.internetConnectionTitle, message: InternetConnection.internetConnectionMessage) { (index, msg) in
            }
        }
        
    }
    
    @IBAction func btnAbout(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet() {
            navicodes(website: aboutUs, header: "About")
        }
        else {
            UtilityClass.setCustomAlert(title: InternetConnection.internetConnectionTitle, message: InternetConnection.internetConnectionMessage) { (index, msg) in
            }
        }
    }
    
    @IBAction func btnBudgetTaxis(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet() {
            navicodes(website: strBudgetTaxis, header: "Budget Taxis")
        }
        else {
            UtilityClass.setCustomAlert(title: InternetConnection.internetConnectionTitle, message: InternetConnection.internetConnectionMessage) { (index, msg) in
            }
        }
    }
    
    @IBAction func btnBudgetShuttlesAndValues(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet() {
            navicodes(website: strBudgetShuttlesAndValues, header: "Budget Shuttles And Values")
        }
        else {
            UtilityClass.setCustomAlert(title: InternetConnection.internetConnectionTitle, message: InternetConnection.internetConnectionMessage) { (index, msg) in
            }
        }
    }
    
    @IBAction func btnDiamondServices(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet() {
            navicodes(website: strSite, header: "Diamond Services")
        }
        else {
            UtilityClass.setCustomAlert(title: InternetConnection.internetConnectionTitle, message: InternetConnection.internetConnectionMessage) { (index, msg) in
            }
        }
    }
    
    @IBAction func btnWaihekeExpressTaxis(_ sender: UIButton) {
        
        if Connectivity.isConnectedToInternet() {
            navicodes(website: strWaihekeExpressTaxis, header: "Waiheke Express Taxis")
        }
        else {
            UtilityClass.setCustomAlert(title: InternetConnection.internetConnectionTitle, message: InternetConnection.internetConnectionMessage) { (index, msg) in
            }
        }
    }
    
    func navicodes(website: String, header: String) {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "webViewVC") as! webViewVC
        next.strURL = website
        next.headerName = header
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    // ----------------------------------------------------
    // MARK: - webservice Methods
    // ----------------------------------------------------
    
    func webserviceOfAppSetting() {
        //        version : 1.0.0 , (app_type : AndroidPassenger , AndroidDriver , IOSPassenger , IOSDriver)
        
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        let version = nsObject as! String
        
        print("Vewsion : \(version)")
        
        var param = String()
        param = version + "/" + "IOSPassenger"
        webserviceForAppSetting(param as AnyObject) { (result, status) in
            
            if let res = result as? [String:Any] {
                aboutUs = res["about_us"] as? String ?? ""
            }
            
            if (status) {
                print("result is : \(result)")
                
                if ((result as! NSDictionary).object(forKey: "update") as? Bool) != nil {
                    
                    let alert = UIAlertController(title: nil, message: (result as! NSDictionary).object(forKey: "message") as? String, preferredStyle: .alert)
                    let UPDATE = UIAlertAction(title: "UPDATE", style: .default, handler: { ACTION in
                        
                        //                        UIApplication.shared.openURL(NSURL(string: "https://itunes.apple.com/us/app/pick-n-go/id1320783092?mt=8")! as URL)
                    })
                    let Cancel = UIAlertAction(title: "Cancel", style: .default, handler: { ACTION in
                        
                        if(SingletonClass.sharedInstance.isUserLoggedIN)
                        {
                            //                            self.webserviceForAllDrivers()
                            //                            self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
                        }
                    })
                    alert.addAction(UPDATE)
                    alert.addAction(Cancel)
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    
                    if(SingletonClass.sharedInstance.isUserLoggedIN) {
                        
                        //                        self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
                    }
                }
            }
            else {
                print(result)
                
                if let update = (result as! NSDictionary).object(forKey: "update") as? Bool {
                    
                    if (update) {
                        
                        let alert = UIAlertController(title: "",
                                                      message: (result as! NSDictionary).object(forKey: "message") as? String,
                                                      preferredStyle: UIAlertController.Style.alert)
                        
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)

                         }))
                        
                        
                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        
                        
                    }
                    else {
                        let alert = UIAlertController(title: "",
                                                      message: (result as! NSDictionary).object(forKey: "message") as? String,
                                                      preferredStyle: UIAlertController.Style.alert)
                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                        
                        
                    }
                    
                }
                /*
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
                 */
            }
        }
    }
    
}



//
//  MyBookingViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 09/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
//import NVActivityIndicatorView

class MyBookingViewController: UIViewController, UIScrollViewDelegate {

    
    var aryHistory = NSArray()
    
    let bottomBorderOnGoing = CALayer()
    let bottomBorderUpComming = CALayer()
    let bottomBorderPastBooking = CALayer()
    @IBOutlet weak var constraintHeight: NSLayoutConstraint!

    var heightOfLayer = CGFloat()
    var heighMinusFromY = CGFloat()
    
    var isFromPushNotification = Bool()
    var bookingType = String()
    
    var selectedBackgroundColor = UIColor.black
    var unselectedBackgroundColor = UIColor.white
    var selectedTextColor = UIColor.black
    var unselectedTextColor = UIColor.init(red: 167/255, green: 167/255, blue: 167/255, alpha: 1.0)
    
//    @IBOutlet weak var viewHeaderHeightConstant: NSLayoutConstraint!
//
//    func setHeaderForIphoneX() {
//
//        if UIDevice().userInterfaceIdiom == .phone {
//            switch UIScreen.main.nativeBounds.height {
//            case 2436,1792:
//
//                viewHeaderHeightConstant.constant = 80
//            default:
//                print("Height of device is \(UIScreen.main.nativeBounds.height)")
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        heightOfLayer = 2.0
        heighMinusFromY = 2.0
        
        webserviceOfBookingHistory()
        
        scrollObject.isUserInteractionEnabled = true
        setHeaderForIphoneX()
        scrollObject.delegate = self
        scrollObject.layoutIfNeeded()
        scrollObject.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        if (isFromPushNotification) {
            
            if bookingType == "accept" {
                Upcomming()
            }
            else if bookingType == "reject" {
                PastBooking()
            }
            
        }
        else {
            PastBooking()
        }
        
        // Do any additional setup after loading the view.
    }
    
    
    func setHeaderForIphoneX() {
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436,1792:
                
                constraintHeight.constant = 40
            default: break
//                print("Height of device is \(UIScreen.main.nativeBounds.height)")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         
         
    }
    
    
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    @IBOutlet weak var btnBack: UIButton!
    
    @IBOutlet weak var lblOnGoing: UIButton!
    @IBOutlet weak var btnUpComming: UIButton!
    @IBOutlet weak var btnPastBooking: UIButton!
    
    @IBOutlet weak var scrollObject: UIScrollView!
    
    
    @IBOutlet weak var viewBottomOfUpComming: UIView!
    @IBOutlet weak var viewBottomOfPastBooking: UIView!
    
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnBack(_ sender: UIButton) {
      
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is CustomSideMenuViewController {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
    @IBOutlet weak var btnCall: UIButton!
    @IBAction func btCallClicked(_ sender: UIButton)
    {
        
        let contactNumber = helpLineNumber
        
        if contactNumber == "" {
            
            UtilityClass.setCustomAlert(title: "\(appName)", message: "Contact number is not available") { (index, title) in
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
    
    @IBAction func lblOnGoing(_ sender: UIButton) {
        OnGoing()
        
    }
    
    @IBAction func btnUpComming(_ sender: UIButton) {
        Upcomming()
        if self.children.count != 0 {
            if let commingVC = self.children.first as? UpCommingVC {
                commingVC.webserviceOfUpcommingPagination(index: 1)
            }
        }
    }
    
    func isModal() -> Bool {
        if (presentingViewController != nil) {
            return true
        }
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        if (tabBarController?.presentingViewController is UITabBarController) {
            return true
        }
        return false
    }

    func OnGoing() {
        

//        bottomBorderOnGoing.frame = CGRect(x: 0.0, y: lblOnGoing.frame.size.height - heighMinusFromY, width: lblOnGoing.frame.size.width, height: heightOfLayer)
//        bottomBorderOnGoing.backgroundColor = UIColor.init(red: 255/255, green: 163/255, blue: 0, alpha: 1.0).cgColor
//        lblOnGoing.layer.addSublayer(bottomBorderOnGoing)
        //        bottomBorderUpComming.removeFromSuperlayer()
        //        bottomBorderPastBooking.removeFromSuperlayer()
        
        
        btnUpComming.backgroundColor = unselectedBackgroundColor
        btnPastBooking.backgroundColor = unselectedBackgroundColor
        btnUpComming.setTitleColor(unselectedTextColor, for: .normal)
        btnPastBooking.setTitleColor(unselectedTextColor, for: .normal)
        
        lblOnGoing.backgroundColor = selectedBackgroundColor
        lblOnGoing.setTitleColor(selectedTextColor, for: .normal)
        
        scrollObject.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    func Upcomming() {
       
        
//        btnUpComming.backgroundColor = selectedBackgroundColor
//        btnPastBooking.backgroundColor = unselectedBackgroundColor
//        lblOnGoing.backgroundColor = unselectedBackgroundColor
        
        viewBottomOfUpComming.backgroundColor = selectedBackgroundColor
        viewBottomOfPastBooking.backgroundColor = unselectedBackgroundColor
        
        btnUpComming.setTitleColor(selectedTextColor, for: .normal)
        lblOnGoing.setTitleColor(unselectedTextColor, for: .normal)
        btnPastBooking.setTitleColor(unselectedTextColor, for: .normal)
       
//        bottomBorderUpComming.frame = CGRect(x: 0.0, y: btnUpComming.frame.size.height - heighMinusFromY, width: btnUpComming.frame.size.width, height: heightOfLayer)
//        bottomBorderUpComming.backgroundColor = UIColor.init(red: 255/255, green: 163/255, blue: 0, alpha: 1.0).cgColor
//        btnUpComming.layer.addSublayer(bottomBorderUpComming)
//
//
//        bottomBorderOnGoing.removeFromSuperlayer()
//        bottomBorderPastBooking.removeFromSuperlayer()
        
        
        
        
//        lblOnGoing.backgroundColor = UIColor.white
////        btnUpComming.backgroundColor = UIColor.init(red: 255/255, green: 163/255, blue: 0, alpha: 1.0)
//        btnPastBooking.backgroundColor = UIColor.white
//
//        lblOnGoing.setTitleColor(UIColor.black, for: .normal)
//        btnUpComming.setTitleColor(UIColor.black, for: .normal)
//        btnPastBooking.setTitleColor(UIColor.black, for: .normal)
        
      
        scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
    }
    
    func PastBooking() {
        
        
//        bottomBorderPastBooking.frame = CGRect(x: 0.0, y: btnPastBooking.frame.size.height - heighMinusFromY, width: btnPastBooking.frame.size.width, height: heightOfLayer)
//        bottomBorderPastBooking.backgroundColor = UIColor.init(red: 255/255, green: 163/255, blue: 0, alpha: 1.0).cgColor
//        btnPastBooking.layer.addSublayer(bottomBorderPastBooking)
//
//
//        bottomBorderUpComming.removeFromSuperlayer()
//        bottomBorderOnGoing.removeFromSuperlayer()
        
        
//        lblOnGoing.backgroundColor = UIColor.white
//        btnUpComming.backgroundColor = UIColor.white
////        btnPastBooking.backgroundColor = UIColor.init(red: 255/255, green: 163/255, blue: 0, alpha: 1.0)
//
//        lblOnGoing.setTitleColor(UIColor.black, for: .normal)
//        btnUpComming.setTitleColor(UIColor.black, for: .normal)
//        btnPastBooking.setTitleColor(UIColor.black, for: .normal)
        
//        btnUpComming.backgroundColor = unselectedBackgroundColor
//        btnPastBooking.backgroundColor = selectedBackgroundColor
//        lblOnGoing.backgroundColor = unselectedBackgroundColor
        
        viewBottomOfPastBooking.backgroundColor = selectedBackgroundColor
        viewBottomOfUpComming.backgroundColor = unselectedBackgroundColor
        
        btnUpComming.setTitleColor(unselectedTextColor, for: .normal)
        lblOnGoing.setTitleColor(unselectedTextColor, for: .normal)
        btnPastBooking.setTitleColor(selectedTextColor, for: .normal)

        
        scrollObject.setContentOffset(CGPoint(x: self.view.frame.size.width * 2, y: 0), animated: true)
    }
    
    @IBAction func btnPastBooking(_ sender: UIButton) {
       
        PastBooking()
        
        if self.children.count != 0 {
            if let pastVC = self.children.last as? PastBookingVC {
                pastVC.webserviceOfPastbookingpagination(index: 1)
            }
        }        
    }
    
    //-------------------------------------------------------------
    // MARK: - Scroll Methods
    //-------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        let pageNo = CGFloat(scrollView.contentOffset.x / scrollView.frame.size.width)
        //        segmentController.selectItemAt(index: Int(pageNo), animated: true)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
//        let currentPage = scrollView.contentOffset.x / scrollView.frame.size.width
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------

    func webserviceOfBookingHistory()
    {
//        let activityData = ActivityData()
//        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
//
        webserviceForBookingHistory(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                
                self.aryHistory = (result as! NSDictionary).object(forKey: "history") as! NSArray
                
                print(self.aryHistory)
                
                SingletonClass.sharedInstance.aryHistory = self.aryHistory
                
                // ------------------------------------------------------------
                // OnGoing
                var aryOnGoing = [NSDictionary]()
                for i in 0..<self.aryHistory.count
                {
                    if (self.aryHistory.object(at: i) as! NSDictionary).object(forKey: "HistoryType") as? String == "onGoing" {
                      
                        aryOnGoing.append((self.aryHistory.object(at: i) as! NSDictionary))
                    }
                }
                SingletonClass.sharedInstance.aryOnGoing = aryOnGoing as NSArray
                // Post notification
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationCenterName.keyForOnGoing), object: nil)
                // ------------------------------------------------------------
                
                // UpComming
                var aryUpComming = [NSDictionary]()
                for i in 0..<self.aryHistory.count
                {
                    if (self.aryHistory.object(at: i) as! NSDictionary).object(forKey: "HistoryType") as? String == "Upcoming" {
                        
                        aryUpComming.append((self.aryHistory.object(at: i) as! NSDictionary))
                    }
                }
                SingletonClass.sharedInstance.aryUpComming = aryUpComming as NSArray
                // Post notification
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationCenterName.keyForUpComming), object: nil)
                // ------------------------------------------------------------
            
                // UpComming
                var aryPastBooking = [NSDictionary]()
                for i in 0..<self.aryHistory.count
                {
                    if (self.aryHistory.object(at: i) as! NSDictionary).object(forKey: "HistoryType") as? String == "Past" {
                        
                        aryPastBooking.append((self.aryHistory.object(at: i) as! NSDictionary))
                    }
                }
                SingletonClass.sharedInstance.aryPastBooking = aryPastBooking as NSArray
                // Post notification
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationCenterName.keyForPastBooking), object: nil)
                // ------------------------------------------------------------
                
//                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            }
            else {
                
                print(result)
            }
        }
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

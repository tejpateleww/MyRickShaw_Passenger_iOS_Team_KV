//
//  CustomAlertsViewController.swift
//  CapRide
//
//  Created by MAYUR on 29/01/18.
//  Copyright © 2018 Excelent iMac. All rights reserved.
//

import UIKit
import SDWebImage


@objc protocol alertViewMethodsDelegates {
    @objc optional func didOKButtonPressed()
    @objc optional func didCancelButtonPressed()
}

class CustomAlertsViewController: UIViewController
{
    
    var delegateOfAlertView: alertViewMethodsDelegates!
    
    var strTitle = String()
    var strMessage = String()
    var btnOKisHidden = Bool()
    var btnCancelisHidden = Bool()
    
    var closeBtnPosition = CGPoint()
    var alertViewSize = CGRect()
    var alertViewZeroSize = CGRect()
   
    
    var aryOfBookinDetails = [[String:AnyObject]]()
    
    var strDriverName = String()
    var strPickupLocation = String()
    var strDropoffLocation = String()
    var strCarCompany = String()
    var strCarModel = String()
    var strCarColor = String()
    var strMobileNumber = String()
    var strDriverImage = String()
    
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDataOnBookingConfirmScreen()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.isNavigationBarHidden = true
        
        lblTitleName.text = appName
        lblMessageDetails.text = ""

        gaveCornerRadus(item: viewMainAlert)
        gaveCornerRadus(item: viewAlert)
        
//        self.viewMainAlert.isHidden = true
        
      
    }
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        
//        startAnimation()
       
    }
    
    func gaveCornerRadus(item: UIView) {
        
        item.layer.cornerRadius = 5
        item.layer.masksToBounds = true
    }
    
    func setDataOnBookingConfirmScreen() {
        
        if let bookingDetails = aryOfBookinDetails as? [[String:AnyObject]] {
            
            if bookingDetails.count != 0 {
                if let bookingInfo = bookingDetails[0]["BookingInfo"] as? [[String:AnyObject]] {
                    
                    strPickupLocation = bookingInfo[0]["PickupLocation"] as! String
                    strDropoffLocation = bookingInfo[0]["DropoffLocation"] as! String
                }
                
                if let carInfo = bookingDetails[0]["CarInfo"] as? [[String:AnyObject]] {
                    
                    if let company = carInfo.first?["CarModel"] as? String {
                        strCarCompany = carInfo[0]["CarModel"] as! String
                    }
                    
                    if let modelInfo = carInfo.first?["CarType"] as? String {
                        strCarModel = carInfo[0]["CarType"] as! String
                    }
                    
                    if let color = carInfo.first?["Color"] as? String {
                        strCarColor = carInfo[0]["Color"] as! String
                    }
                }
                
                if (bookingDetails[0]["Details"] as? [[String:AnyObject]]) != nil {
                    
                }
                
                if let driverInfo = bookingDetails[0]["DriverInfo"] as? [[String:AnyObject]] {
                    
                    strDriverName = driverInfo[0]["Fullname"] as! String
                    strMobileNumber = driverInfo[0]["MobileNo"] as! String
                    
                    strDriverImage = WebserviceURLs.kImageBaseURL + (driverInfo[0]["Image"] as! String)
                }
                
//                if let modelInfo = bookingDetails[0]["ModelInfo"] as? [[String:AnyObject]] {
//
//                    strCarModel = modelInfo[0]["Name"] as! String
//                }
                
                if let message = bookingDetails[0]["message"] as? String {
                    
                    strMessage = message
                }
                
                setData()
                
                if let rating = bookingDetails[0]["DriverRate"] as? CGFloat {
                    viewRating.rating = Float(rating)
                    lblRating.text = "\(Double(rating).rounded(toPlaces: 2))"
                    return
                }
                else if let rating = bookingDetails[0]["DriverRate"] as? String {
                    viewRating.rating = Float(rating) ?? 0.0
                    lblRating.text = "\(Double(rating)!.rounded(toPlaces: 2))"
                    return
                }
                else if let rating = (bookingDetails.first as! [String:Any])["rating"] as? String {
                    viewRating.rating = Float(rating) ?? 0.0
                    lblRating.text = "\(Double(rating)!.rounded(toPlaces: 2))"
                    return
                }
                else if let rating = (bookingDetails.first as! [String:Any])["rating"] as? CGFloat {
                    viewRating.rating = Float(rating)
                    lblRating.text = "\(Double(rating).rounded(toPlaces: 2))"
                    return
                }
            }
        }
    }
    
    func setData() {
        
        lblDriverName.text = strDriverName
        
        lblPickupLocation.text = strPickupLocation
        lblDropoffLocation.text = strDropoffLocation
        
        imgDriverImage.sd_setImage(with: URL(string: strDriverImage), completed: nil)
        
        lblCarInfo.text = "\(strCarCompany) - \(strCarModel) - \(strCarColor)"
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    
    @IBOutlet var viewMain: UIView!
    @IBOutlet weak var viewMainAlert: UIView!
    @IBOutlet var viewAlert: UIView!
    
    @IBOutlet var imgHeaderImage: UIImageView!
    
    @IBOutlet var lblTitleName: UILabel!
    @IBOutlet var lblMessageDetails: UILabel!
    
    @IBOutlet weak var btnClose: UIButton!
    @IBOutlet var btnOK: UIButton!
    
    @IBOutlet weak var constainlblTitleNameLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var imgDriverImage: UIImageView!
    @IBOutlet weak var lblCarInfo: UILabel!
    
    @IBOutlet weak var lblPickupLocation: UILabel!
    @IBOutlet weak var lblDropoffLocation: UILabel!
    @IBOutlet weak var viewRating: FloatRatingView!
    @IBOutlet weak var lblRating: UILabel!
    
    
    @IBAction func btnCallToDriver(_ sender: UIButton) {
        
        if let url = URL(string: "tel://\(strMobileNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    
    
    func setAlertViewwithData(title:String?, message:String?, buttonRightTitle:String?)
    {
        
//        if title?.length == 0
//        {
//            constainlblTitleNameLabelHeight.constant = 0
//        }
//        else
//        {
//            constainlblTitleNameLabelHeight.constant = 42
//        }
        
//        lblTitleName.text = title
//        lblMessageDetails.text = message
//
//
//        btnOK.setTitle(buttonRightTitle, for: .normal)
        
//        if numberOfButton == "1"
//        {
//            btnRight.isHidden = true
//        }
    }
 


    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    
    @IBAction func btnClose(_ sender: UIButton)
    {
        print("btnClose Pressed")
//        DismissAnimation()
        
        self.dismiss(animated: true, completion: nil)
        
//        self.dismiss(animated: true, completion: {
//
//        self.delegateOfAlertView?.didCancelButtonPressed!()
//        })
    }
    
    
    
    @IBAction func btnOK(_ sender: UIButton) {
        
        print("btnOK Pressed")
        
        self.dismiss(animated: false, completion: {
        
         self.delegateOfAlertView?.didOKButtonPressed!()
        })
    }
    
    func startAnimation() {
        
        self.viewMainAlert.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseIn, animations:
            {
                self.viewMainAlert.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
                self.viewMainAlert.isHidden = false
                
                self.viewMainAlert.layoutIfNeeded()
        }) { _ in
        }
        
    }
    
    func DismissAnimation() {
        
        self.viewMainAlert.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: .curveEaseOut, animations:
            {
                self.viewMainAlert.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                
                self.viewMainAlert.isHidden = true
                
                self.viewMainAlert.layoutIfNeeded()
        }) { _ in
            
            self.dismiss(animated: false, completion: {
            
             self.delegateOfAlertView?.didCancelButtonPressed!()
            })
        }
        
    }
    
    
}







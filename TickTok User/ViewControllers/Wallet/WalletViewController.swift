//
//  WalletViewController.swift
//  TiCKTOC-Driver
//
//  Created by Excellent Webworld on 06/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class WalletViewController: UIViewController, UIScrollViewDelegate {

    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewTop.layer.cornerRadius = 5
        viewTop.layer.masksToBounds = true
 
        viewOptions.layer.cornerRadius = 5
        viewOptions.layer.masksToBounds = true
        
        scrollObj.delegate = self
        scrollObj.isScrollEnabled = false
        
        bPaySelected()
        
        webserviceOfTransactionHistory()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
      
        
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         bPaySelected()
        
        self.lblCurrentBalance.text = "$\(SingletonClass.sharedInstance.strCurrentBalance)"
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    
    @IBOutlet weak var scrollObj: UIScrollView!
    
    
//    @IBOutlet weak var pageCtrl: UIPageControl!
    
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var viewOptions: UIView!
    
    @IBOutlet weak var lblCurrentBalance: UILabel!
    @IBOutlet weak var imgBpay: UIImageView!
    @IBOutlet weak var imgTravel: UIImageView!
    @IBOutlet weak var imgEntertainment: UIImageView!
    
    @IBOutlet weak var lblBpay: UILabel!
    @IBOutlet weak var lblTravel: UILabel!
    @IBOutlet weak var lblEntertainment: UILabel!
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnBackToNavigate(_ sender: UIButton) {
        
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is CustomSideMenuViewController {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
        
//        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func btnBalance(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletBalanceMainVC") as! WalletBalanceMainVC
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    
    @IBAction func btnTransfer(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletTransferViewController") as! WalletTransferViewController
        self.navigationController?.pushViewController(next, animated: true)
  
    }
    
    
    @IBAction func btnCards(_ sender: UIButton) {
        
        if SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0 {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
            self.navigationController?.pushViewController(next, animated: true)
        }
        else {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletCardsVC") as! WalletCardsVC
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    @IBAction func btnBpay(_ sender: UIButton) {
        
        bPaySelected()
        
        
    }
    
    @IBAction func btnTravel(_ sender: UIButton) {
        
        travelSelected()
        
        
    }
    
    @IBAction func btnEntertainment(_ sender: UIButton) {
        
        entertainmentSelected()
        
       
    }
    
    func bPaySelected() {
        
        scrollObj.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
        lblBpay.textColor = UIColor.init(red: 56/255, green: 145/255, blue: 219/255, alpha: 1.0)
        lblTravel.textColor = UIColor.init(red: 147/255, green: 147/255, blue: 147/255, alpha: 1.0)
        lblEntertainment.textColor = UIColor.init(red: 147/255, green: 147/255, blue: 147/255, alpha: 1.0)
        
        imgBpay.image = UIImage(named: "iconDollerSelected")
        imgEntertainment.image = UIImage(named: "iconEntertainmentUnSelected")
        imgTravel.image = UIImage(named: "iconTravelBag")
    }
    
    func travelSelected() {
        
        scrollObj.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
        
        lblBpay.textColor = UIColor.init(red: 147/255, green: 147/255, blue: 147/255, alpha: 1.0)
        lblTravel.textColor = UIColor.init(red: 56/255, green: 145/255, blue: 219/255, alpha: 1.0)
        lblEntertainment.textColor = UIColor.init(red: 147/255, green: 147/255, blue: 147/255, alpha: 1.0)
        
        imgBpay.image = UIImage(named: "iconDollerGrey")
        imgEntertainment.image = UIImage(named: "iconEntertainmentUnSelected")
        imgTravel.image = UIImage(named: "iconTravelBagSelected")
    }
    
    func entertainmentSelected() {
        
        imgBpay.image = UIImage(named: "iconDollerGrey")
        imgEntertainment.image = UIImage(named: "iconEntertainmentSelected")
        imgTravel.image = UIImage(named: "iconTravelBag")
        
        scrollObj.setContentOffset(CGPoint(x: self.view.frame.size.width * 2, y: 0), animated: true)
        
        lblBpay.textColor = UIColor.init(red: 147/255, green: 147/255, blue: 147/255, alpha: 1.0)
        lblTravel.textColor = UIColor.init(red: 147/255, green: 147/255, blue: 147/255, alpha: 1.0)
        lblEntertainment.textColor = UIColor.init(red: 56/255, green: 145/255, blue: 219/255, alpha: 1.0)
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods Transaction History
    //-------------------------------------------------------------
    
    func webserviceOfTransactionHistory() {
        
        webserviceForTransactionHistory(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                SingletonClass.sharedInstance.strCurrentBalance = ((result as! NSDictionary).object(forKey: "walletBalance") as AnyObject).doubleValue
                self.lblCurrentBalance.text = "$\(SingletonClass.sharedInstance.strCurrentBalance)"

                
                SingletonClass.sharedInstance.walletHistoryData = (result as! NSDictionary).object(forKey: "history") as! [[String:AnyObject]]
                
                self.webserviceOFGetAllCards()
                
            }
            else {
                print(result)
                
                if let res = result as? String {
                    UtilityClass.showAlert("", message: res, vc: self)
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.showAlert("", message: (resDict).object(forKey: "message") as! String, vc: self)
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.showAlert("", message: ((resAry).object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)
                }
                
            }
        
        }

    }
    
    var aryCards = [[String:AnyObject]]()
    
    func webserviceOFGetAllCards() {
        
        webserviceForCardList(SingletonClass.sharedInstance.strPassengerID as AnyObject){ (result, status) in

            if (status) {
                print(result)
                
                self.aryCards = (result as! NSDictionary).object(forKey: "cards") as! [[String:AnyObject]]
                
                SingletonClass.sharedInstance.CardsVCHaveAryData = self.aryCards
                
//                SingletonClass.sharedInstance.isCardsVCFirstTimeLoad = false

            }
            else {
                print(result)
                if let res = result as? String {
                    UtilityClass.showAlert("", message: res, vc: self)
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.showAlert("", message: resDict.object(forKey: "message") as! String, vc: self)
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.showAlert("", message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)
                }
            }
        }

    }

}

//-------------------------------------------------------------
// MARK: - BpayVC
//-------------------------------------------------------------


class BpayVC: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewTop.layer.cornerRadius = 5
        viewTop.layer.masksToBounds = true
        
        btnSubmit.layer.cornerRadius = 5
        btnSubmit.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var viewTop: UIView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        
    }
    
}


//-------------------------------------------------------------
// MARK: - TravelVC
//-------------------------------------------------------------

class TravelVC: UIViewController {
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewTop.layer.cornerRadius = 5
        viewTop.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var viewTop: UIView!
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnAction(_ sender: UIButton) {
        
//        let next = self.storyboard?.instantiateViewController(withIdentifier: "webViewVC") as! webViewVC
//        self.navigationController?.pushViewController(next, animated: true)
    }
    
    
}

//-------------------------------------------------------------
// MARK: - EntertainmentVC
//-------------------------------------------------------------

class EntertainmentVC: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewTop.layer.cornerRadius = 5
        viewTop.layer.masksToBounds = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var viewTop: UIView!
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
   
    @IBAction func btnActions(_ sender: UIButton) {
        
//        let next = self.storyboard?.instantiateViewController(withIdentifier: "webViewVC") as! webViewVC
//        self.navigationController?.pushViewController(next, animated: true)
    }
    
    
}



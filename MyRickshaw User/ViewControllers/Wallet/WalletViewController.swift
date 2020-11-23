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
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var lblCurrentBalance: UILabel!
    @IBOutlet weak var lblCreditBalance: UILabel!
    
    @IBOutlet weak var lblCreditExpiryDate: UILabel!

    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webserviceOfTransactionHistory()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.lblCurrentBalance.text = "\(currencySign) \(SingletonClass.sharedInstance.strCurrentBalance)"
        
        
        let naviagate = UtilityClass.returnValueForCredit(key: "IsRequestCreditAccount")
        
        if(naviagate == "0" || naviagate == "3")
        {
            self.lblCreditBalance.text = ""
            
        }
        else if (naviagate == "1" )
        {
            self.lblCreditBalance.text = "Pending"
            
        }
        else if (naviagate == "2" )
        {
            self.lblCreditBalance.text = "\(currencySign)\(SingletonClass.sharedInstance.creditHistoryData["AvailableCreditLimit"] as? String ?? "")"
            self.lblCreditExpiryDate.text = "Start date: \(UtilityClass.returnValueForCredit(key: "CreditAccountStartDate")) Exp. date : \(UtilityClass.returnValueForCredit(key: "CreditAccountExpDate"))"

        }
        
        

    }
    
    
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
    
    
    @IBAction func btnCredit(_ sender: UIButton) {
        
        let naviagate = UtilityClass.returnValueForCredit(key: "IsRequestCreditAccount")
        
        if(naviagate == "0" || naviagate == "3")
        {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "CreditFormViewController") as! CreditFormViewController
            self.navigationController?.pushViewController(next, animated: true)
        }
        else if(naviagate == "1")
        {
            UtilityClass.showAlertWithCompletion("", message: "Your request is still pending please check after sometime", vc: self) { (status) in
                
            }
        }
        else
        {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletBalanceMainVC") as! WalletBalanceMainVC
            next.isFromCredit = true
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods Transaction History
    //-------------------------------------------------------------
    
    func webserviceOfTransactionHistory() {
        
        webserviceForTransactionHistory(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                SingletonClass.sharedInstance.strCurrentBalance = ((result as! NSDictionary).object(forKey: "walletBalance") as AnyObject).doubleValue
                self.lblCurrentBalance.text = "\(currencySign) \(SingletonClass.sharedInstance.strCurrentBalance)"
                
                if let history = result["history"] as? [[String:AnyObject]]
                {
                    SingletonClass.sharedInstance.walletHistoryData = history
                }
                
                //                SingletonClass.sharedInstance.walletHistoryData = (result as! NSDictionary).object(forKey: "history") as! [[String:AnyObject]]
                
                self.webserviceOFGetAllCards()
                
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


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

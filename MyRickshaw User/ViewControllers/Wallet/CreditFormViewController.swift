//
//  CreditFormViewController.swift
//  MyRickshaw User
//
//  Created by EWW072 on 27/08/20.
//  Copyright © 2020 Excellent Webworld. All rights reserved.
//

import UIKit
import ACFloatingTextfield_Swift
class CreditFormViewController: UIViewController,SelectCardDelegate {
    
    
    
    @IBOutlet weak var txtEmail: ACFloatingTextfield!
    @IBOutlet weak var txtPostalCode: ACFloatingTextfield!
    @IBOutlet weak var txtMobileNumber: ACFloatingTextfield!
    @IBOutlet weak var txtRequestCredit: ACFloatingTextfield!
    @IBOutlet weak var lblCardTitle: UILabel!
    var strCardId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    func validations() -> Bool
    {
        //        if(txtEmail.text?.trimFirstAndLastSpace().count == 0)
        //        {
        //            UtilityClass.showAlert("Missing", message: "Please enter \(txtEmail.placeholder ?? "")", vc: self)
        //            return false
        //        }
        //        else
        if(txtPostalCode.text?.trimFirstAndLastSpace().count == 0)
        {
            UtilityClass.showAlert("Missing", message: "Please enter \(txtPostalCode.placeholder ?? "")", vc: self)
            return false
        }
        else if(txtMobileNumber.text?.trimFirstAndLastSpace().count == 0)
        {
            UtilityClass.showAlert("Missing", message: "Please enter \(txtMobileNumber.placeholder ?? "")", vc: self)
            return false
        }
        else if(txtRequestCredit.text?.trimFirstAndLastSpace().count == 0)
        {
            UtilityClass.showAlert("Missing", message: "Please enter \(txtRequestCredit.placeholder ?? "")", vc: self)
            return false
        }
        else if(strCardId.trimFirstAndLastSpace().count == 0)
        {
            UtilityClass.showAlert("Missing", message: "Please enter card", vc: self)
            return false
        }
        
        
        return true
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        if(validations())
        {
            webserviceCallForCreditRequest()
        }
    }
    @IBAction func btnBackToNavigate(_ sender: UIButton) {
        
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is CustomSideMenuViewController {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
        
        //        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func webserviceCallForCreditRequest()
    {
        
        var dictParam = [String:Any]()
        dictParam["PassengerId"] = SingletonClass.sharedInstance.strPassengerID
        dictParam["CardId"] = strCardId
        //        dictParam["email"] = txtEmail.text
        dictParam["PostalAddress"] = txtPostalCode.text
        dictParam["MobileNo"] = txtMobileNumber.text
        dictParam["RequestCredit"] = txtRequestCredit.text
        
        
        webserviceForCreditRequest(dictParam as AnyObject) { (result, status) in
            if(status)
            {
                print(result)
                //                SingletonClass.sharedInstance.creditHistoryData["IsRequestCreditAccount"] = result["IsRequestCreditAccount"] as? Int
                
                
                var naviagate = String()
                if let isRequestedCreditAccount = result["IsRequestCreditAccount"]as? String
                {
                    naviagate = isRequestedCreditAccount
                }
                else if let isRequestedCreditAccount = result["IsRequestCreditAccount"]as? Int
                {
                    naviagate = "\(isRequestedCreditAccount)"
                    
                }
                SingletonClass.sharedInstance.creditHistoryData["IsRequestCreditAccount"] = naviagate
                
                if let res = result as? String
                {
                    UtilityClass.setCustomAlert(title: appName, message: res) { (index, title) in
                    }
                }
                else if let resDict = result as? NSDictionary
                {
                    
                    UtilityClass.setCustomAlert(title: appName, message: resDict.object(forKey: "message") as! String) { (index, title) in
                    }
                }
                else if let resAry = result as? NSArray
                {
                    
                    UtilityClass.setCustomAlert(title: appName, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    }
                }
            }
            else
            {
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
    
    
    @IBAction func btnCardTitle(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletCardsVC") as! WalletCardsVC
        SingletonClass.sharedInstance.isFromCredit = true
        next.delegateForTopUp = self
        self.navigationController?.pushViewController(next, animated: false)
    }
    
    
    func didSelectCard(dictData: [String : AnyObject]) {
        lblCardTitle.text = "\(dictData["Type"] as! String) \(dictData["CardNum2"] as! String)"
        strCardId = dictData["Id"] as! String
    }
}

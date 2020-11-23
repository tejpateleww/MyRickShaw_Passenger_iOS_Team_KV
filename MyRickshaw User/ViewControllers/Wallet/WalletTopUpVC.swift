//
//  WalletTopUpVC.swift
//  TiCKTOC-Driver
//
//  Created by Excelent iMac on 23/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit


@objc protocol SelectCardDelegate {
    
    func didSelectCard(dictData: [String:AnyObject])
}


class WalletTopUpVC: ParentViewController, SelectCardDelegate {

    
    var strCardId = String()
    var strAmt = String()
    weak var delegate: delegateForUpdateCurrentBalance?
    var isFromCredit = Bool()
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewMain.layer.cornerRadius = 5
        viewMain.layer.masksToBounds = true
        
        btnAddFunds.layer.cornerRadius = 5
        btnAddFunds.layer.masksToBounds = true
        
        
        if(isFromCredit)
        {
            txtAmount.isUserInteractionEnabled = false
            
            let intTotalCredit = Int(UtilityClass.returnValueForCredit(key: "CreditLimit")) ?? 0

            let intCreditAvailable = Int(UtilityClass.returnValueForCredit(key: "AvailableCreditLimit")) ?? 0

            txtAmount.text = "\(intTotalCredit - intCreditAvailable)"
        }
//        txtAmount.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var lblCardTitle: UILabel!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var btnAddFunds: UIButton!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var btnCardTitle: UIButton!
    
    
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnCardTitle(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletCardsVC") as! WalletCardsVC
        SingletonClass.sharedInstance.isFromTopUP = true
        next.delegateForTopUp = self
        self.navigationController?.pushViewController(next, animated: false)
    }
    
    @IBAction func btnAddFunds(_ sender: UIButton) {
        
        if strCardId == "" {
            
            UtilityClass.setCustomAlert(title: appName, message: "Please select card") { (index, title) in
            }
        }
        else if txtAmount.text == "" {
            
            UtilityClass.setCustomAlert(title: appName, message: "Please enter amount") { (index, title) in
            }
        }
        else {
            
            
            if(isFromCredit)
            {
                webserviceForCreditTopUp()
            }
            else
            {
                webserviceOFTopUp()
            }
        }
        
    }
    @IBAction func txtAmount(_ sender: UITextField) {
        
        if let amountString = txtAmount.text?.currencyInputFormatting() {
            
            
//            txtAmount.text = amountString
            
            
            let unfiltered1 = amountString   //  "!   !! yuahl! !"
            
            // Array of Characters to remove
            
            let spaceAdd = " "
        
            let insertCurrencySymboleInString = "\(currencySign),\(spaceAdd)"
            let insertcurrencySymboleInCharacter = [Character](insertCurrencySymboleInString)
            
            let removal1: [Character] = insertcurrencySymboleInCharacter    // ["!"," "]
            
            // turn the string into an Array
            let unfilteredCharacters1 = unfiltered1
            
            // return an Array without the removal Characters
            let filteredCharacters1 = unfilteredCharacters1.filter { !removal1.contains($0) }
            
            // build a String with the filtered Array
            let filtered1 = String(filteredCharacters1)
            
            print(filtered1) // => "yeah"
            
            // combined to a single line
            print(String(unfiltered1.filter { !removal1.contains($0) })) // => "yuahl"
            
            txtAmount.text = "\(currencySign)\(String(unfiltered1.filter { !removal1.contains($0) }))"
            
            let space = " "
            let comma = " "
            let currencySymboleInString = "\(currencySign),\(comma),\(space)"
            let currencySymboleInCharacter = [Character](currencySymboleInString)
            
            // ----------------------------------------------------------------------
            // ----------------------------------------------------------------------
            let unfiltered = amountString   //  "!   !! yuahl! !"
            
            // Array of Characters to remove
            let removal: [Character] = currencySymboleInCharacter    // ["!"," "]
            
            // turn the string into an Array
            let unfilteredCharacters = unfiltered
            
            // return an Array without the removal Characters
            let filteredCharacters = unfilteredCharacters.filter { !removal.contains($0) }
            
            // build a String with the filtered Array
            let filtered = String(filteredCharacters)
            
            print(filtered) // => "yeah"
            
            // combined to a single line
            print(String(unfiltered.filter { !removal.contains($0) })) // => "yuahl"
            
            strAmt = String(unfiltered.filter { !removal.contains($0) })
            print("amount : \(strAmt)")
            
        }
    }
    
    
    
    //-------------------------------------------------------------
    // MARK: - Select Card Delegate Methods
    //-------------------------------------------------------------
    
    func didSelectCard(dictData: [String : AnyObject]) {
        
        print(dictData)
        
        lblCardTitle.text = "\(dictData["Type"] as! String) \(dictData["CardNum2"] as! String)"
        strCardId = dictData["Id"] as! String
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods For TOP UP
    //-------------------------------------------------------------
    
    func webserviceOFTopUp() {
        
//        PassengerId,Amount,CardId
        
        var dictParam = [String:AnyObject]()
 
        strAmt = strAmt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        dictParam["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        dictParam["CardId"] = strCardId as AnyObject
        dictParam["Amount"] = strAmt.replacingOccurrences(of: " ", with: "") as AnyObject
        
        webserviceForAddMoney(dictParam as AnyObject) { (result, status) in
        
        
            if (status) {
                print(result)
                
                self.txtAmount.text = ""
                
                SingletonClass.sharedInstance.strCurrentBalance = ((result as! NSDictionary).object(forKey: "walletBalance") as AnyObject).doubleValue
                
                UtilityClass.setCustomAlert(title: appName, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        
                        if self.delegate != nil {
                            self.delegate?.didUpdateCurrentBalance!()
                        }
                        
                        self.navigationController?.popViewController(animated: true)
                    })
                    
                }
                
            }
            else {
                print(result)
                
                self.txtAmount.text = ""
                
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
    
    

        //-------------------------------------------------------------
        // MARK: - Webservice Methods For Credit TOP UP
        //-------------------------------------------------------------
        
        func webserviceForCreditTopUp() {
            
    //        PassengerId,Amount,CardId
            
            var dictParam = [String:AnyObject]()
     
            strAmt = strAmt.trimmingCharacters(in: .whitespacesAndNewlines)
            
            dictParam["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
            dictParam["CardId"] = strCardId as AnyObject
 
            webserviceForPaymentInCredit(dictParam as AnyObject) { (result, status) in
            
            
                if (status) {
                    print(result)
                    
                    SingletonClass.sharedInstance.strCurrentBalance = ((result as! NSDictionary).object(forKey: "walletBalance") as AnyObject).doubleValue
                    
                    UtilityClass.setCustomAlert(title: appName, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                            
                            if self.delegate != nil {
                                self.delegate?.didUpdateCurrentBalance!()
                            }
                            
                            self.navigationController?.popViewController(animated: true)
                        })
                        
                    }
                    
                }
                else {
                    print(result)
                    
                    self.txtAmount.text = ""
                    
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


/*
{
    message = "Add Money successfully";
    status = 1;
    walletBalance = "-4.63";
}
 */



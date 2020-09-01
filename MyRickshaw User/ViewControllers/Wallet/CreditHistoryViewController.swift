//
//  CreditHistoryViewController.swift
//  MyRickshaw User
//
//  Created by EWW072 on 28/08/20.
//  Copyright © 2020 Excellent Webworld. All rights reserved.
//

import UIKit

class CreditHistoryViewController: ParentViewController {
    
    @IBOutlet weak var tblView: UITableView!
    
    var aryData = [[String:AnyObject]]()
    @IBOutlet weak var constraintTop: NSLayoutConstraint!
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webserviceOfCreditTransactionHistory()
        setHeaderForIphoneX()
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func kindOfSelection(_ sender: UISegmentedControl) {
     
        if(sender.selectedSegmentIndex == 0)
        {
            webserviceOfCreditTransactionHistory()

        }
        else
        {
            
            webserviceOfHistory()

        }
    }
    
    
    
    func setHeaderForIphoneX() {
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436,1792:
                
                constraintTop.constant = 80
            default:
                print("Height of device is \(UIScreen.main.nativeBounds.height)")
            }
        }
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods Transaction History
    //-------------------------------------------------------------
    
    func webserviceOfHistory() {
        
        webserviceCreditHistory(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                
                if let history = result["data"] as? [[String:AnyObject]]
                {
                    self.aryData = history
                }
                
                self.tblView.reloadData()
                
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
    
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods Credit Transaction History
    //-------------------------------------------------------------
    
    func webserviceOfCreditTransactionHistory() {
        
        webserviceForCreditHistory(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                if let history = result["history"] as? [[String:AnyObject]]
                {
                    self.aryData = history
                }
                self.tblView.reloadData()
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



extension CreditHistoryViewController : UITableViewDataSource
{
    //-------------------------------------------------------------
    // MARK: - TableView Methods
    //-------------------------------------------------------------
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //           if aryData.count == 0 {
        //               return 1
        //           }
        //           else {
        return aryData.count
        //           }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletHistoryTableViewCell") as! WalletHistoryTableViewCell
        cell.selectionStyle = .none
        
        let dictData = aryData[indexPath.row]
        
        if(segment.selectedSegmentIndex == 0)
        {
            cell.lblTransferTitle.text = dictData["Description"] as? String
            cell.lblTransferTitle.font = UIFont(name: cell.lblTransferTitle.font.familyName, size: 15)
            cell.lblDateOfTransfer.text = (dictData["UpdatedDate"] as? String)?.onlyDateToString(dateFormat: "yyyy-MM-dd HH:mm:ss")
            cell.lblTimeOfTransfer.text = (dictData["UpdatedDate"] as? String)?.onlyTimeToString(dateFormat: "yyyy-MM-dd HH:mm:ss")
            
            
            if dictData["Status"] as! String == "failed" {
                
                cell.lblAmount.text = "\(dictData["Type"] as! String) \(dictData["Amount"] as! String)"
                cell.lblAmount.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
                
                cell.lblTransferStatusHeight.constant = 20.5
                cell.lblTransferStatus.isHidden = false
                cell.lblTransferStatus.text = "Transaction Failed"
                cell.lblTransferStatus.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
            }
            else if dictData["Status"] as! String == "pending" {
                cell.lblAmount.text = "\(dictData["Type"] as! String) \(dictData["Amount"] as! String)"
                cell.lblAmount.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
                
                cell.lblTransferStatusHeight.constant = 17
                cell.lblTransferStatus.isHidden = false
                cell.lblTransferStatus.text = "Transaction Pending"
                cell.lblTransferStatus.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
            }
            else {
                
                if dictData["Type"] as! String == "-" {
                    cell.lblTransferStatusHeight.constant = 0
                    cell.lblTransferStatus.isHidden = true
                    //                cell.lblTransferStatus.text = dictData["Status"] as? String ?? ""
                    cell.lblAmount.text = "\(currencySign) \(dictData["Amount"] as! String)"
                    cell.lblAmount.textColor = UIColor.black
                }
                else {
                    cell.lblTransferStatusHeight.constant = 20.5
                    cell.lblTransferStatus.isHidden = false
                    cell.lblTransferStatus.text = dictData["Status"] as? String ?? ""
                    cell.lblAmount.text = "\(currencySign) \(dictData["Amount"] as! String)"
                    cell.lblAmount.textColor = UIColor.init(red: 0, green: 144/255, blue: 81/255, alpha: 1.0)
                    cell.lblTransferStatus.textColor = UIColor.init(red: 0, green: 144/255, blue: 81/255, alpha: 1.0)
                    
                }
                
            }
        }
        else
        {
            cell.lblTransferTitle.text = dictData["Description"] as? String
            cell.lblTransferTitle.font = UIFont(name: cell.lblTransferTitle.font.familyName, size: 15)
            cell.lblDateOfTransfer.text = (dictData["Date"] as? String)?.onlyDateToString(dateFormat: "yyyy-MM-dd HH:mm:ss")
            cell.lblTimeOfTransfer.text = (dictData["Date"] as? String)?.onlyTimeToString(dateFormat: "yyyy-MM-dd HH:mm:ss")
            
            
            if dictData["Status"] as! String == "failed" {
                
                cell.lblAmount.text = "\(dictData["Type"] as! String) \(dictData["Amount"] as! String)"
                cell.lblAmount.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
                
                cell.lblTransferStatusHeight.constant = 20.5
                cell.lblTransferStatus.isHidden = false
                cell.lblTransferStatus.text = "Transaction Failed"
                cell.lblTransferStatus.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
            }
            else if dictData["Status"] as! String == "pending" {
                cell.lblAmount.text = "\(dictData["Type"] as! String) \(dictData["Amount"] as! String)"
                cell.lblAmount.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
                
                cell.lblTransferStatusHeight.constant = 17
                cell.lblTransferStatus.isHidden = false
                cell.lblTransferStatus.text = "Transaction Pending"
                cell.lblTransferStatus.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
            }
            else {
                
                if dictData["TransactionType"] as! String == "-" {
                    cell.lblTransferStatusHeight.constant = 0
                    cell.lblTransferStatus.isHidden = true
                    //                cell.lblTransferStatus.text = dictData["Status"] as? String ?? ""
                    cell.lblAmount.text = "\(currencySign) \(dictData["Amount"] as! String)"
                    cell.lblAmount.textColor = UIColor.black
                }
                else {
                    cell.lblTransferStatusHeight.constant = 20.5
                    cell.lblTransferStatus.isHidden = false
                    cell.lblTransferStatus.text = dictData["Status"] as? String ?? ""
                    cell.lblAmount.text = "\(currencySign) \(dictData["Amount"] as! String)"
                    cell.lblAmount.textColor = UIColor.init(red: 0, green: 144/255, blue: 81/255, alpha: 1.0)
                    cell.lblTransferStatus.textColor = UIColor.init(red: 0, green: 144/255, blue: 81/255, alpha: 1.0)
                    
                }
                
            }
        }
        
 
        
        
        // ----------------------------------------------------------------------
        // ----------------------------------------------------------------------
        return cell
        
    }
}

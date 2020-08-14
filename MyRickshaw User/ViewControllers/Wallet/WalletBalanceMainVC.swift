//
//  WalletBalanceMainVC.swift
//  TiCKTOC-Driver
//
//  Created by Excelent iMac on 23/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

@objc protocol delegateForUpdateCurrentBalance {
    @objc optional func didUpdateCurrentBalance()
}

class WalletBalanceMainVC: ParentViewController, UITableViewDataSource, UITableViewDelegate, delegateForUpdateCurrentBalance {
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControlEvents.valueChanged)
        refreshControl.tintColor = themeYellowColor
        
        return refreshControl
    }()
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        webserviceOfTransactionHistory()
        tableView.reloadData()
    }

    var isHighLighted:Bool = false
    
    var aryData = [[String:AnyObject]]()
    var labelNoData = UILabel()
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        self.tableView.addSubview(self.refreshControl)
        
        if SingletonClass.sharedInstance.walletHistoryData.count == 0 {
             webserviceOfTransactionHistory()
        }
        else {
            aryData = SingletonClass.sharedInstance.walletHistoryData
            self.lblAvailableFundsDesc.text = "\(currencySign) \(SingletonClass.sharedInstance.strCurrentBalance)"
        }
        
        btnTopUp.imageView?.contentMode = .scaleAspectFit
        btnTransferToBank.imageView?.contentMode = .scaleAspectFit
        btnHistory.imageView?.contentMode = .scaleAspectFit        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        viewAvailableFunds.layer.cornerRadius = 5
        viewAvailableFunds.layer.masksToBounds = true
        
        viewCenter.layer.cornerRadius = 5
        viewCenter.layer.masksToBounds = true
        
        viewBottom.layer.cornerRadius = 5
        viewBottom.layer.masksToBounds = true
        setUpButtons()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func topDown() {
        
        self.viewTopUp.backgroundColor = UIColor.black
    }
    
    @objc func topCancel() {
        self.viewTopUp.backgroundColor = self.viewTransferToBank.backgroundColor
        
    }
    
    func setUpButtons() {
        
        if btnTopUp.isHighlighted {
            viewTopUp.backgroundColor = UIColor.black
        }
        else if !btnTopUp.isHighlighted {
            viewTopUp.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
        }
        
        if btnTransferToBank.isHighlighted {
            viewTransferToBank.backgroundColor = UIColor.black
        }
        else if !btnTransferToBank.isHighlighted {
            viewTransferToBank.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
        }
        
        if btnHistory.isHighlighted {
            viewHistory.backgroundColor = UIColor.black
        }
        else if !btnHistory.isHighlighted {
            viewHistory.backgroundColor = UIColor.init(red: 235/255, green: 235/255, blue: 235/255, alpha: 1.0)
        }
    }

    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var viewAvailableFunds: UIView!
    @IBOutlet weak var lblAvailableFunds: UILabel!
    @IBOutlet weak var lblAvailableFundsDesc: UILabel!
    
    @IBOutlet weak var viewCenter: UIView!
    
    @IBOutlet weak var imgTopUp: UIImageView!
    @IBOutlet weak var lblTopUp: UILabel!
    
    @IBOutlet weak var imgTansferToBank: UIImageView!
    @IBOutlet weak var lblTransferToBank: UILabel!
    
    @IBOutlet weak var imgHistory: UIImageView!
    @IBOutlet weak var lblHistory: UILabel!
    
    @IBOutlet weak var viewBottom: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var viewTopUp: UIView!
    @IBOutlet weak var viewTransferToBank: UIView!
    @IBOutlet weak var viewHistory: UIView!
    
    @IBOutlet weak var btnTopUp: UIButton!
    @IBOutlet weak var btnTransferToBank: UIButton!
    @IBOutlet weak var btnHistory: UIButton!
    
  
    //-------------------------------------------------------------
    // MARK: - TableView Methods
    //-------------------------------------------------------------
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if aryData.count >= 5 {
           return 5
        }
        else {
           return aryData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "WalletBalanceMainTableViewCell") as! WalletBalanceMainTableViewCell
        cell.selectionStyle = .none
 
        let dictData = aryData[indexPath.row]
        
        cell.lblTransferTitle.text = dictData["Description"] as? String
        cell.lblTransferDateAndTime.text = (dictData["UpdatedDate"] as? String)!.onlyDateToString(dateFormat: "yyyy-MM-dd hh:mm:ss")
        cell.lblTime.text = (dictData["UpdatedDate"] as? String)!.onlyTimeToString(dateFormat: "yyyy-MM-dd hh:mm:ss")
        
//        if dictData["Status"] as! String == "failed" {
//
//            cell.lblPrice.text = "\(dictData["Type"] as! String) \(dictData["Amount"] as! String)"
//            cell.lblPrice.textColor = UIColor.red
//        }
//        else {
//
//            cell.lblPrice.text = "\(dictData["Type"] as! String) \(dictData["Amount"] as! String)"
//            cell.lblPrice.textColor = UIColor.init(red: 0, green: 144/255, blue: 81/255, alpha: 1.0)
//        }
        // ----------------------------------------------------------------------
        // ----------------------------------------------------------------------
        
        if dictData["Status"] as! String == "failed" {
            
            cell.lblPrice.text = "\(dictData["Type"] as! String) \(dictData["Amount"] as! String)"
            cell.lblPrice.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
            
            cell.statusHeight.constant = 20.5
            cell.lblStatus.isHidden = false
            cell.lblStatus.text = "Transaction Failed"
            cell.lblStatus.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
        }
        else if dictData["Status"] as! String == "pending" {
            cell.lblPrice.text = "\(dictData["Type"] as! String) \(dictData["Amount"] as! String)"
            cell.lblPrice.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
            
            cell.statusHeight.constant = 17
            cell.lblStatus.isHidden = false
            cell.lblStatus.text = "Transaction Pending"
            cell.lblStatus.textColor = UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0)
        }
        else {
            
            if dictData["Type"] as! String == "-" {
                cell.statusHeight.constant = 0
                cell.lblStatus.isHidden = true
                
                cell.lblPrice.text = "\(dictData["Type"] as! String) \(dictData["Amount"] as! String)"
                cell.lblPrice.textColor = UIColor.black
            }
            else {
                cell.statusHeight.constant = 0
                cell.lblStatus.isHidden = true
                
                cell.lblPrice.text = "\(dictData["Type"] as! String) \(dictData["Amount"] as! String)"
                cell.lblPrice.textColor = UIColor.init(red: 0, green: 144/255, blue: 81/255, alpha: 1.0)
            }
            
        }
   
        
        // ----------------------------------------------------------------------
        // ----------------------------------------------------------------------
        return cell
 
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnTopUP(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletTopUpVC") as! WalletTopUpVC
        next.delegate = self
        self.navigationController?.pushViewController(next, animated: true)
        
    }
    
    @IBAction func btnTransferToBank(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletTransferToBankVC") as! WalletTransferToBankVC
        next.delegate = self
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @IBAction func btnHistory(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletHistoryViewController") as! WalletHistoryViewController
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    // ----------------------------------------------------
    // MARK: - delegateForUpdateCurrentBalance Methods
    // ----------------------------------------------------
    
    func didUpdateCurrentBalance() {
        webserviceOfTransactionHistory()
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods Transaction History
    //-------------------------------------------------------------

    func webserviceOfTransactionHistory() {

        
        webserviceForTransactionHistory(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                SingletonClass.sharedInstance.strCurrentBalance = ((result as! NSDictionary).object(forKey: "walletBalance") as AnyObject).doubleValue
                self.lblAvailableFundsDesc.text = "\(currencySign) \(SingletonClass.sharedInstance.strCurrentBalance)"
                
                if let history = result["history"] as? [[String:AnyObject]]
                {
                    SingletonClass.sharedInstance.walletHistoryData = history
                }
//                SingletonClass.sharedInstance.walletHistoryData = (result as! NSDictionary).object(forKey: "history") as! [[String:AnyObject]]

                self.aryData = SingletonClass.sharedInstance.walletHistoryData
                
                self.tableView.reloadData()
                
                self.refreshControl.endRefreshing()
                
                
                if self.aryData.count == 0 {
                    self.labelNoData = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: self.tableView.frame.size.height))
                    self.labelNoData.text = "No Data Found"
                    self.labelNoData.textAlignment = .center
                    self.viewBottom.addSubview(self.labelNoData)
                    
                }
                else {
                    self.labelNoData.removeFromSuperview()
                }
                
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

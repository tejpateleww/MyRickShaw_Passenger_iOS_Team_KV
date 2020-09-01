//
//  FlatRateViewController.swift
//  MyRickshaw User
//
//  Created by Apple on 29/10/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

class FlatRateViewController: UIViewController {

    // ----------------------------------------------------
    // MARK: - Outlets
    // ----------------------------------------------------

    @IBOutlet weak var tableView: UITableView!
    
    
    // ----------------------------------------------------
    // MARK: - Globle Declaration Methods
    // ----------------------------------------------------
    
    var aryFlateRate = [[String:Any]]()
    
    weak var delegate: delegateForFlateRate?
    
    // ----------------------------------------------------
    // MARK: - Base Methods
    // ----------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()

        webservieOfFlateRate()
    }
    
    // ----------------------------------------------------
    // MARK: - Actions
    // ----------------------------------------------------
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        
        
        if let homeVC = self.parent as? HomeViewController {
            homeVC.btnFlatRate.setTitleColor(UIColor.black, for: .normal)
            homeVC.btnPointToPoint.setTitleColor(UIColor.white, for: .normal)
            homeVC.strServiceType = ServiceType.PointToPoint.rawValue
        }
        else if let homeVC = self.navigationController?.children.first as? HomeViewController {
            homeVC.btnFlatRate.setTitleColor(UIColor.black, for: .normal)
            homeVC.btnPointToPoint.setTitleColor(UIColor.white, for: .normal)
            homeVC.strServiceType = ServiceType.PointToPoint.rawValue
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    // ----------------------------------------------------
    // MARK: - Webservice Methods
    // ----------------------------------------------------

    func webservieOfFlateRate() {
        
        webserviceForFlateRateList("" as AnyObject) { (result, status) in
            
            print(result)
            if (status) {
                if let res =  result as? [String:Any] {
                    if let flateRetsList = res["flatrates"] as? [[String:Any]] {
                        self.aryFlateRate = flateRetsList
                        self.tableView.reloadData()
                    }
                }
            }
            else {
                UtilityClass.showAlertOfAPIResponse(param: result, vc: self)
            }
        }
    }
}


extension FlatRateViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryFlateRate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FlatRateTableViewCell") as! FlatRateTableViewCell
        cell.selectionStyle = .none
        
        let currentData = aryFlateRate[indexPath.row]
        cell.setDataOnFlatRate(dict: currentData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentData = aryFlateRate[indexPath.row]
        if delegate != nil {
            delegate?.didAcceptFlateRate!(dict: currentData)
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
}

//
//  MoreOptionsViewController.swift
//  MyRickshaw User
//
//  Created by Excelent iMac on 02/08/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

class MoreOptionsViewController: UIViewController {

    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var tableView: UITableView!
    
    //-------------------------------------------------------------
    // MARK: - Global Declaration
    //-------------------------------------------------------------
    
    var aryCarModelData: [[String:Any]] = [["Type":"TM Card Holder", "value":0, "key": "TMCardHolder"], ["Type":"Baby Seater", "value":0, "key": "BabySeater"], ["Type":"Hoist Van", "value":0, "key": "HoistVan"]]
    var arySelectedCarModelData = [[String:Any]]()
    var selectedItem = Int()
    
    var aryCar = SingletonClass.sharedInstance.carList //CarListConstant
    var tempAry = [CarListModel]()
    
    var delegate: delegateChooseCarOptions?
    var delegateBookLater: delegateForChooseCarFromBookLater?

    var aryIndex = [Int]()
    var isFromBookLater = Bool()
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if arySelectedCarModelData.count != 0 {
            
            for (_,item) in arySelectedCarModelData.enumerated() {
                if item["key"] as! String == "TMCardHolder" {
                    aryIndex.append(0)
                }
                if item["key"] as! String == "BabySeater" {
                    aryIndex.append(1)
                }
                if item["key"] as! String == "HoistVan" {
                    aryIndex.append(2)
                }
            }
        }
      
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnClose(_ sender: UIButton) {
        
        arySelectedCarModelData.removeAll()
        
        if !(isFromBookLater) {
            if delegate != nil {
                delegate?.didSelectOptions!(indexes: arySelectedCarModelData)
            }
        }
        else {
            if delegateBookLater != nil {
                delegateBookLater?.didSelectOptions!(indexes: arySelectedCarModelData)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDone(_ sender: UIButton) {
        
        if !(isFromBookLater) {
            if delegate != nil {
                delegate?.didSelectOptions!(indexes: arySelectedCarModelData)
            }
        }
        else {
            if delegateBookLater != nil {
                delegateBookLater?.didSelectOptions!(indexes: arySelectedCarModelData)
            }
        }
        
        self.dismiss(animated: true, completion: nil)
        
//        if SingletonClass.sharedInstance.carList != nil {
//            if selectedItem.count != 0 {
//                if !(isFromBookLater) {
//                    swap(&SingletonClass.sharedInstance.carList![2], &SingletonClass.sharedInstance.carList![selectedItem.row + 3])
//                    delegate?.didChangedCar!(index: 2)
//                }
//                else {
//                    if SingletonClass.sharedInstance.carList != nil {
//                        delegateBookLater?.didCarChoosed(index: selectedItem.row)
//                    }
//                }
//            }
//        }
        
    }
    
}


//-------------------------------------------------------------
// MARK: - TableView Methods
//-------------------------------------------------------------

extension MoreOptionsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryCarModelData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoreOptionsTableViewCell") as! MoreOptionsTableViewCell
        
        cell.selectionStyle = .none
        cell.lblCarModelName.text = aryCarModelData[indexPath.row]["Type"] as? String
        
        cell.imgCarModelSelectedOrNot.image = UIImage(named: "iconCheckMarkUnselected")
        
        if aryIndex.contains(indexPath.row) {
            cell.imgCarModelSelectedOrNot.image = UIImage(named: "iconCheckMarkSelected")
        }
        cell.isUserInteractionEnabled = true
        if(selectedItem == 0 && cell.lblCarModelName.text == "Hoist Van")
        {
            cell.isUserInteractionEnabled = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let currentData = aryCarModelData[indexPath.row]
        var changeValue = currentData
        changeValue["value"] = 1
        
        if aryIndex.count != 0 {
            if aryIndex.contains(indexPath.row) {
                aryIndex = aryIndex.filter{$0 != indexPath.row}
                arySelectedCarModelData = arySelectedCarModelData.filter{$0["Type"] as! String != changeValue["Type"] as! String }
            }
            else {
                aryIndex.append(indexPath.row)
                arySelectedCarModelData.append(changeValue)
            }
        }
        else {
            aryIndex.append(indexPath.row)
            arySelectedCarModelData.append(changeValue)
        }
        
        tableView.reloadData()
    }
    
}

//
//  PastBookingVC.swift
//  TickTok User
//
//  Created by Excellent Webworld on 09/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class PastBookingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var aryData = NSMutableArray()
    
    var strPickupLat = String()
    var strPickupLng = String()
    
    var strDropoffLat = String()
    var strDropoffLng = String()
    
//    var labelNoData = UILabel()
    
    
    var expandedCellPaths = Set<IndexPath>()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = themeYellowColor
        
        return refreshControl
    }()

    @IBOutlet weak var labelNoData: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let navHeight = self.navigationController?.navigationBar.frame.size.height
       
//        labelNoData = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: ((UIApplication.shared.delegate as! AppDelegate).window?.frame.size.height)!))
        self.labelNoData.text = "Loading..."
//        labelNoData.textAlignment = .center
//        self.view.addSubview(labelNoData)
        self.tableView.isHidden = true
        
        
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        self.tableView.addSubview(self.refreshControl)
        

        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadTableView), name: NSNotification.Name(rawValue: NotificationCenterName.keyForPastBooking), object: nil)
    }
    
    @objc func reloadTableView()
    {
//        self.aryData = SingletonClass.sharedInstance.aryPastBooking as! NSMutableArray
//        self.tableView.reloadData()
        
        self.labelNoData.text = "Loading..."
        webserviceOfPastbookingpagination(index: 1)
        
//        if(self.aryData.count == 0)
//        {
//            self.labelNoData.text = "No data found."
//            self.tableView.isHidden = true
//        }
//        else {
//            self.labelNoData.removeFromSuperview()
//            self.tableView.isHidden = false
//        }
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        tableView.reloadData()
//        refreshControl.endRefreshing()
        aryData.removeAllObjects()
        webserviceOfPastbookingpagination(index: 1)
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------

    @IBOutlet weak var tableView: UITableView!
    
    
    
    //-------------------------------------------------------------
    // MARK: - Table View Methods
    //-------------------------------------------------------------
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return aryData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastBooingTableViewCell") as! PastBooingTableViewCell
        cell.selectionStyle = .none
 
        if aryData.count > 0 {


            let currenRow = (aryData.object(at: indexPath.row) as! [String:Any])
            let notAvailable = "N/A"

            
            if let name = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "DriverName") as? String {
                
                if name == "" {
                    cell.lblDriverName.isHidden = true
                }
                else {
                    let attributedString = NSAttributedString(string: name)
                    let textRange = NSMakeRange(0, attributedString.length)
                    let underlinedMessage = NSMutableAttributedString(attributedString: attributedString)
                    underlinedMessage.addAttribute(NSAttributedString.Key.underlineStyle,
                                                   value:NSUnderlineStyle.single.rawValue,
                                                   range: textRange)
                    cell.lblDriverName.attributedText = underlinedMessage
//                    cell.lblDriverName.text = name
                }
            }
           
            let formattedString = NSMutableAttributedString()
            formattedString
                .normal("Booking Id: ")
                .bold("\(String(describing: (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "Id")!))", 14)
            
            let lbl = UILabel()
            lbl.attributedText = formattedString
            
            cell.lblBookingID.attributedText = formattedString
            
//            cell.lblBookingID.text = "Booking Id: \(String(describing: (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "Id")!))"
            
            if let dateAndTime = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "CreatedDate") as? String {
                
                if dateAndTime == "" {
                    cell.lblDateAndTime.text = notAvailable
                }
                else {
                    cell.lblDateAndTime.text = dateAndTime
                }
                
            }
//            cell.lblDateAndTime.text = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "CreatedDate") as? String
            
            // DropOff Address is PickupAddress
            // Pickup Address is DropOffAddress
            
            if let pickupAddress = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "PickupLocation") as? String {
//
                if pickupAddress == "" {
                     cell.lblPickupAddress.text = notAvailable
                    
                }
                else {
                    cell.lblPickupAddress.text = pickupAddress
                }
            }
           
            if let dropoffAddress = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "DropoffLocation") as? String {
//
                if dropoffAddress == "" {
                    cell.lblDropoffAddress.text = notAvailable
                }
                else {
                    cell.lblDropoffAddress.text = dropoffAddress
                }
            }
            
//            cell.lblPickupAddress.text = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "PickupLocation") as? String
//            cell.lblDropoffAddress.text = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "DropoffLocation") as? String
            
            if let pickupTime = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "PickupTime") as? String {
                if pickupTime == "" {
                    cell.lblPickupTime.text = notAvailable
//                    cell.stackViewPickupTime.isHidden = true
                }
                else {
                    cell.lblPickupTime.text = setTimeStampToDate(timeStamp: pickupTime)
                }
            }
            
            if let DropoffTime = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "DropTime") as? String {
                if DropoffTime == "" {
                    cell.lblDropoffTime.text = notAvailable
//                    cell.stackViewDropoffTime.isHidden = true
                }
                else {
                    cell.lblDropoffTime.text = setTimeStampToDate(timeStamp: DropoffTime)
                }
            }
            
//            cell.lblPickupTime.text = setTimeStampToDate(timeStamp: ((aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "PickupTime") as? String)!)
//            cell.lblDropoffTime.text = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "DropTime") as? String
            
            if let strModel = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "Model") as? String {
                if strModel == "" {
                    cell.lblVehicleType.text = notAvailable
//                    cell.stackViewVehicleType.isHidden = true
                }
                else {
                    cell.lblVehicleType.text = strModel
                }
            }
//            cell.lblVehicleType.text = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "Model") as? String
            if let strTripDistance = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "TripDistance") as? String {
                if strTripDistance == "" {
                    cell.lblDistanceTravelled.text = notAvailable
//                    cell.stackViewDistanceTravelled.isHidden = true
                }
                else {
                    cell.lblDistanceTravelled.text = strTripDistance
                }
            }
//            cell.lblDistanceTravelled.text = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "TripDistance") as? String

           
            cell.lblTripFare.text = currencySign + checkDictionaryHaveValue(dictData: currenRow, didHaveValue: "TripFare", isNotHave: notAvailable) //(aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "TripFare") as? String
            cell.lblNightFare.text = currencySign + checkDictionaryHaveValue(dictData: currenRow, didHaveValue: "NightFare", isNotHave: notAvailable)  // (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "NightFare") as? String

            cell.lblTollFee.text =  currencySign + checkDictionaryHaveValue(dictData: currenRow, didHaveValue: "TollFee", isNotHave: notAvailable)  // (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "TollFee") as? String
            cell.lblWaitingCost.text = currencySign + checkDictionaryHaveValue(dictData: currenRow, didHaveValue: "WaitingTimeCost", isNotHave: notAvailable)  //  (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "WaitingTimeCost") as? String
            cell.lblWaitingTime.text = currencySign + checkDictionaryHaveValue(dictData: currenRow, didHaveValue: "LoadingUnloadingCharge", isNotHave: notAvailable)  // (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "WaitingTime") as? String
            cell.lblBookingCharge.text =  currencySign + checkDictionaryHaveValue(dictData: currenRow, didHaveValue: "BookingCharge", isNotHave: notAvailable)  // (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "BookingCharge") as? String
            cell.lblTax.text =  currencySign + checkDictionaryHaveValue(dictData: currenRow, didHaveValue: "Tax", isNotHave: notAvailable)  // (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "Tax") as? String
            cell.lblDiscount.text = currencySign + checkDictionaryHaveValue(dictData: currenRow, didHaveValue: "Discount", isNotHave: notAvailable)  //  (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "Discount") as? String
            cell.lblPaymentType.text =  checkDictionaryHaveValue(dictData: currenRow, didHaveValue: "PaymentType", isNotHave: notAvailable)  // (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "PaymentType") as? String
            cell.lblTotalCost.text = currencySign + checkDictionaryHaveValue(dictData: currenRow, didHaveValue: "GrandTotal", isNotHave: notAvailable)  //  (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "GrandTotal") as? String


            cell.viewDetails.isHidden = !expandedCellPaths.contains(indexPath)
            
        }

        return cell
 
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? PastBooingTableViewCell {
            cell.viewDetails.isHidden = !cell.viewDetails.isHidden
            if cell.viewDetails.isHidden {
                expandedCellPaths.remove(indexPath)
            } else {
                expandedCellPaths.insert(indexPath)
            }
            tableView.beginUpdates()
            tableView.endUpdates()
            
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func setTimeStampToDate(timeStamp: String) -> String {
        
        let unixTimestamp = Double(timeStamp)
        //        let date = Date(timeIntervalSince1970: unixTimestamp)
        
        let date = Date(timeIntervalSince1970: unixTimestamp!)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm yyyy/MM/dd" //Specify your format that you want
        let strDate: String = dateFormatter.string(from: date)
        
        return strDate
    }
    
    func webserviceOfPastbookingpagination(index: Int) {
        
        let driverId = SingletonClass.sharedInstance.strPassengerID + "/" + "\(index)"
        
        webserviceForPastBooking(driverId as AnyObject, isLoading: false) { (result, status) in
            if (status) {
                DispatchQueue.main.async {
                    
                    let tempPastData = ((result as! NSDictionary).object(forKey: "history") as! NSArray)
                    
                    for i in 0..<tempPastData.count {
                        
                        let dataOfAry = (tempPastData.object(at: i) as! NSDictionary)
                        
                        let strHistoryType = dataOfAry.object(forKey: "HistoryType") as? String
                        
                        if strHistoryType == "Past" {
                            self.aryData.add(dataOfAry)
                        }
                    }
                    
                    if(self.aryData.count == 0) {
                        self.labelNoData.isHidden = false
                        self.labelNoData.text = "No data found."
                        self.tableView.isHidden = true
                    }
                    else {
                        self.labelNoData.isHidden = true
                        self.tableView.isHidden = false
                    }
                    
                    //                    self.getPostJobs()
                    self.refreshControl.endRefreshing()
                    self.tableView.reloadData()
                    
                    UtilityClass.hideACProgressHUD()
                }
            }
            else {
                UtilityClass.showAlertOfAPIResponse(param: result, vc: self)
            }
        }
    }
    
    var isDataLoading:Bool=false
    var pageNo:Int = 0
    var didEndReached:Bool=false
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        print("scrollViewWillBeginDragging")
        isDataLoading = false
    }
    
    //Pagination
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        print("scrollViewDidEndDragging")
        if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height) {
            //            if !isDataLoading{
            //                isDataLoading = true
            //                self.pageNo = self.pageNo + 1
            //                webserviceOfPastbookingpagination(index: self.pageNo)
            //            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == (self.aryData.count - 5) {
            if !isDataLoading{
                isDataLoading = true
                self.pageNo = self.pageNo + 1
                webserviceOfPastbookingpagination(index: self.pageNo)
            }
        }
    }

}

//
//  UpCommingVC.swift
//  TickTok User
//
//  Created by Excellent Webworld on 09/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class UpCommingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    
    var aryData = NSMutableArray()
    
    var strPickupLat = String()
    var strPickupLng = String()
    
    var strDropoffLat = String()
    var strDropoffLng = String()
    
    var bookinType = String()
    
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
        
//        labelNoData = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: ((UIApplication.shared.delegate as! AppDelegate).window?.frame.size.height)!))
        self.labelNoData.text = "Loading..."
//        labelNoData.textAlignment = .center
//        self.view.addSubview(labelNoData)
        self.tableView.isHidden = true

        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        self.tableView.addSubview(self.refreshControl)
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDataTableView), name: NSNotification.Name(rawValue: NotificationCenterName.keyForUpComming), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        aryData.removeAllObjects()
//        webserviceOfUpcommingPagination(index: 1)
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        
        tableView.reloadData()
        refreshControl.endRefreshing()
        aryData.removeAllObjects()
        webserviceOfUpcommingPagination(index: 1)
    }
    
    @objc func reloadDataTableView()
    {
        webserviceOfUpcommingPagination(index: 1)
//        self.aryData = SingletonClass.sharedInstance.aryUpComming as! NSMutableArray
//        self.tableView.reloadData()
////        self.tableView.frame.size = tableView.contentSize
//
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
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "UpCommingTableViewCell") as! UpCommingTableViewCell
        cell.selectionStyle = .none

        if aryData.count > 0 {
            
            let currentData = aryData.object(at: indexPath.row) as? [String:Any]

            cell.lblBookingId.text = "Booking Id: \(currentData!["Id"] as? String ?? "0")"
            cell.lblPassengerName.text = currentData!["DriverName"] as? String
            
            cell.lblPickupAddress.text = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "PickupLocation") as? String // PickupLocation
            cell.lblDropoffAddress.text = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "DropoffLocation") as? String //  DropoffLocation
            var time = ((aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "CreatedDate") as? String)
            time!.removeLast(3)
            
            cell.lblDateAndTime.text = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "CreatedDate") as? String
            cell.lblPaymentType.text = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "PaymentType") as? String
  
            if let bookingID = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "Id") as? String {
                cell.btnCancelRequest.tag = Int(bookingID)!
            }
            else if let bookingID = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "Id") as? Int {
                cell.btnCancelRequest.tag = bookingID
            }
            
            if let luggage = currentData?["NoOfLuggage"] as? String {
                cell.lblNoOfLuggages.text = luggage
            }
            if let passenger = currentData?["NoOfPassenger"] as? String {
                cell.lblNoOPassengers.text = passenger
            }
            
            bookinType = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "BookingType") as! String
            cell.btnCancelRequest.addTarget(self, action: #selector(self.CancelRequest), for: .touchUpInside)
            
            cell.btnCancelRequest.layer.cornerRadius = 5
            cell.btnCancelRequest.layer.masksToBounds = true
            
            cell.btnChat.isHidden = true
            cell.constraintHeightOfChatButton.constant = 0
            if let status = (aryData.object(at: indexPath.row) as! NSDictionary).object(forKey: "Status") as? String {
                if status.lowercased() == "accepted" || status.lowercased() == "accept" || status.lowercased() == "travelling" || status.lowercased() == "traveling" {
                    cell.btnChat.isHidden = false
                    cell.constraintHeightOfChatButton.constant = 30
                }
            }
            
            cell.btnChat.tag = indexPath.row
            cell.btnChat.addTarget(self, action: #selector(self.buttonChatAction(_:)), for: .touchUpInside)
            
            cell.viewDetails.isHidden = !expandedCellPaths.contains(indexPath)
        }
 
        return cell

    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
     
        if let cell = tableView.cellForRow(at: indexPath) as? UpCommingTableViewCell {
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

    @objc func CancelRequest(sender: UIButton) {
        
        let bookingID = sender.tag
        
        
        let socketData = ((self.navigationController?.children[1] as! CustomSideMenuViewController).children[0].children[0] as! HomeViewController).socket
        let showTopView = ((self.navigationController?.children[1] as! CustomSideMenuViewController).children[0].children[0] as! HomeViewController)
        
        if (SingletonClass.sharedInstance.isTripContinue) {
            
//            if (SingletonClass.sharedInstance.bookingId == String(bookingID)) {
            
            UtilityClass.setCustomAlert(title: "Your trip has started", message: "You cannot cancel this request.") { (index, title) in
            }
            
//            }
            
        }
        else {
            if bookinType == "Book Now" {
                let myJSON = [SocketDataKeys.kBookingIdNow : bookingID] as [String : Any]
                socketData.emit(SocketData.kCancelTripByPassenger , with: [myJSON])
                
                showTopView.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                
//                reloadDataTableView()
                
                
//                UtilityClass.showAlertWithCompletion("", message: "Your request cancelled successfully", vc: self, completionHandler: { ACTION in
//                    self.navigationController?.popViewController(animated: true)
//                })
                
//                UtilityClass.setCustomAlert(title: "\(appName)", message: "Your request cancelled successfully", completionHandler: { (index, title) in
                    self.navigationController?.popViewController(animated: true)
//                })
            }
            else {
                let myJSON = [SocketDataKeys.kBookingIdNow : bookingID] as [String : Any]
                socketData.emit(SocketData.kAdvancedBookingCancelTripByPassenger , with: [myJSON])
                
//                reloadDataTableView()
                
//                UtilityClass.showAlertWithCompletion("", message: "Your request cancelled successfully", vc: self, completionHandler: { ACTION in
//                    self.navigationController?.popViewController(animated: true)
//                })
                
//                UtilityClass.setCustomAlert(title: "\(appName)", message: "Your request cancelled successfully", completionHandler: { (index, title) in
                    self.navigationController?.popViewController(animated: true)
//                })
            }
        }
        
    }
    
    @objc func buttonChatAction(_ sender: UIButton) {
        
        let currrentData = aryData.object(at: sender.tag) as! [String : AnyObject]
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        SingletonClass.sharedInstance.strChatingNowBookingId = "\(checkDictionaryHaveValue(dictData: currrentData, didHaveValue: "Id", isNotHave: ""))"
        
        next.strBookingId = "\(checkDictionaryHaveValue(dictData: currrentData, didHaveValue: "Id", isNotHave: ""))"
        next.strBookingType = "\(checkDictionaryHaveValue(dictData: currrentData, didHaveValue: "BookingType", isNotHave: ""))"
        
        self.navigationController?.pushViewController(next, animated: true)
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
        dateFormatter.dateFormat = "HH:mm dd/MM/yyyy" //Specify your format that you want
        let strDate: String = dateFormatter.string(from: date)
        
        return strDate
    }
    
    func changeDateAndTimeFormate(dateAndTime: String) -> String {
        
        let time = dateAndTime // "22:02:00"
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-mm-dd HH-mm-ss"
        
        let fullDate = dateFormatter.date(from: time)
        
        dateFormatter.dateFormat = "yyyy/mm/dd HH:mm"
        
        let time2 = dateFormatter.string(from: fullDate!)
        
        return time2
    }
    
    func webserviceOfUpcommingPagination(index: Int) {
        
        let driverId = SingletonClass.sharedInstance.strPassengerID //+ "/" + "\(index)"
        
        webserviceForUpcomingBooking(driverId as AnyObject, isLoading: false) { (result, status) in
            if (status) {
                DispatchQueue.main.async {
                    
                    let tempPastData = ((result as! NSDictionary).object(forKey: "history") as! NSArray)
                    
                    for i in 0..<tempPastData.count {
                        
                        let dataOfAry = (tempPastData.object(at: i) as! NSDictionary)
                        
                        let strHistoryType = dataOfAry.object(forKey: "HistoryType") as? String
                        
                        if strHistoryType == "Upcoming" {
                            self.aryData.add(dataOfAry)
                        }
                    }
                    
                    if(self.aryData.count == 0) {
                        self.labelNoData.text = "No data found."
                        self.tableView.isHidden = true
                        self.labelNoData.isHidden = false
                    }
                    else {
                        self.tableView.isHidden = false
                        self.labelNoData.isHidden = true
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
   
}

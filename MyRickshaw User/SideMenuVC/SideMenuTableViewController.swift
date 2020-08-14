//
//  SideMenuTableViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 26/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

protocol delegateForTiCKPayVerifyStatus {
    
    func didRegisterCompleted()
}

class SideMenuTableViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, delegateForTiCKPayVerifyStatus {
  
    @IBOutlet weak var tableView: UITableView!
    
    var ProfileData = NSDictionary()
    
    var arrMenuIcons = [String]()
    var arrMenuTitle = [String]()
    var indexPathSelected = IndexPath()

    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        giveGradientColor()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.SetRating), name: NSNotification.Name(rawValue: "rating"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setNewBookingOnArray), name: NotificationForAddNewBooingOnSideMenu, object: nil)
        
        if SingletonClass.sharedInstance.bookingId != "" {
            setNewBookingOnArray()
        }

        webserviceOfTickPayStatus()
        
        ProfileData = SingletonClass.sharedInstance.dictProfile
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        

        
        arrMenuIcons = ["iconMyBooking","iconPaymentOption","iconWallet", "iconAccountMenu","iconStarOfSideMenu","iconMyreceipts","iconInviteFriends","iconLogOut"]
        
        arrMenuTitle = ["My Bookings","Payment Options","Wallet", "Account","Favourites","My Receipts","Invite Friends","Logout"]
        

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        giveGradientColor()
        
//        UIApplication.shared.isStatusBarHidden = true
//        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
//
//
    }
    
    
    @objc func SetRating() {
        ProfileData = SingletonClass.sharedInstance.dictProfile
        self.tableView.reloadData()
    }
    
    @objc func setNewBookingOnArray() {
        
        if SingletonClass.sharedInstance.bookingId == "" {
            if (arrMenuTitle.contains("New Booking")) {
                arrMenuIcons.removeFirst()
                arrMenuTitle.removeFirst()
            }
        }
        
        // ----------------------------------------------------
        // TODO: - For New Booking
        // ----------------------------------------------------

//        if !(arrMenuTitle.contains("New Booking")) && SingletonClass.sharedInstance.bookingId != "" {
//            arrMenuIcons.insert("iconNewBooking", at: 0)
//            arrMenuTitle.insert("New Booking", at: 0)
//        }
        
        self.tableView.reloadData()
    }
    
    func giveGradientColor() {
        
        let colorTop =  UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        let colorMiddle =  UIColor(red: 36/255, green: 24/255, blue: 3/255, alpha: 0.5).cgColor
        let colorBottom = UIColor(red: 64/255, green: 43/255, blue: 6/255, alpha: 0.8).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorMiddle, colorBottom]
        gradientLayer.locations = [ 0.0, 0.5, 1.0]
        gradientLayer.frame = self.view.bounds
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
    }

    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0
        {
            return 1
        }
        else
        {
            return arrMenuIcons.count
        }
    }
  
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        if (indexPath.section == 0)
        {
            let cellHeader = tableView.dequeueReusableCell(withIdentifier: "MainHeaderTableViewCell") as! MainHeaderTableViewCell
            cellHeader.selectionStyle = .none
            
            cellHeader.imgProfile.layer.cornerRadius = cellHeader.imgProfile.frame.width / 2
             cellHeader.imgProfile.layer.borderWidth = 1.0
             cellHeader.imgProfile.layer.borderColor = UIColor.white.cgColor
            cellHeader.imgProfile.layer.masksToBounds = true
            
            if ProfileData.count != 0 {
                cellHeader.imgProfile.sd_setImage(with: URL(string: ProfileData.object(forKey: "Image") as! String), completed: nil)
                cellHeader.lblName.text = ProfileData.object(forKey: "Fullname") as? String
                cellHeader.lblMobileNumber.text = ProfileData.object(forKey: "MobileNo") as? String
            }
            
            cellHeader.lblRating.text = SingletonClass.sharedInstance.passengerRating

            return cellHeader
        }
        else
        {
            let cellMenu = tableView.dequeueReusableCell(withIdentifier: "ContentTableViewCell") as! ContentTableViewCell

            if !(DeviceType.IS_IPHONE_5) {
                cellMenu.lblTitle.font = UIFont.systemFont(ofSize: 17)
            }
            
//            if indexPathSelected == indexPath {
////                let origImage = UIImage(named: arrMenuIcons[indexPath.row])
////                let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
////                cellMenu.imgDetail?.tintColor = UIColor.init(red: 249/255, green: 179/255, blue: 48/255, alpha: 1.0)
////                cellMenu.imgDetail?.image = tintedImage
//
//                cellMenu.imgDetail?.image = UIImage(named: "\(arrMenuIcons[indexPath.row])Selected")
//                cellMenu.lblTitle.textColor = UIColor.init(red: 249/255, green: 179/255, blue: 48/255, alpha: 1.0)
//                cellMenu.viewUnderLineOfImage.backgroundColor = UIColor.init(red: 249/255, green: 179/255, blue: 48/255, alpha: 1.0)
//
//            }
//            else {
//
//                cellMenu.imgDetail?.image = UIImage(named: arrMenuIcons[indexPath.row])
//                cellMenu.viewUnderLineOfImage.backgroundColor = UIColor.init(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
//
//                cellMenu.lblTitle.textColor = UIColor.white
//            }
            
            cellMenu.imgDetail?.image = UIImage(named: arrMenuIcons[indexPath.row])
            cellMenu.viewUnderLineOfImage.backgroundColor = UIColor.init(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
            
            cellMenu.lblTitle.textColor = UIColor.white
            
            cellMenu.selectionStyle = .none

            cellMenu.lblTitle.text = arrMenuTitle[indexPath.row]
            
            return cellMenu
        }
        
        // Configure the cell...

//        return cellHeader
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
//            let next = self.storyboard?.instantiateViewController(withIdentifier: "CommingSoonViewController") as! CommingSoonViewController
//            self.navigationController?.pushViewController(next, animated: true)
            
            let next = self.storyboard?.instantiateViewController(withIdentifier: "UpdateProfileViewController") as! UpdateProfileViewController
            self.navigationController?.pushViewController(next, animated: true)

        }
        else if (indexPath.section == 1)
        {
            
            indexPathSelected = indexPath
            
//            ["New Booking","My Booking","Payment Options","Wallet","Favourites","My Receipts","Invite Friends","Settings","Become a \(appName) Driver","Package History","LogOut"]
            if arrMenuTitle[indexPath.row] == "New Booking" {
                NotificationCenter.default.post(name: NotificationForBookingNewTrip, object: nil)
                sideMenuController?.toggle()
                
            }
            if arrMenuTitle[indexPath.row] == "My Bookings"
            {
//                self.performSegue(withIdentifier: "segueMyBooking", sender: self)

                let next = self.storyboard?.instantiateViewController(withIdentifier: "MyBookingViewController") as! MyBookingViewController
                self.navigationController?.pushViewController(next, animated: true)
                
            }
            
            if arrMenuTitle[indexPath.row] == "Payment Options" {
                
//                if SingletonClass.sharedInstance.setPasscode == "" {
//                    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SetPasscodeViewController") as! SetPasscodeViewController
//                    self.navigationController?.pushViewController(viewController, animated: true)
//                }
//                else {
//
//                    if (SingletonClass.sharedInstance.passwordFirstTime) {
//
                        if SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0 {
                            let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
                            self.navigationController?.pushViewController(next, animated: true)
                        }
                        else {
                            let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletCardsVC") as! WalletCardsVC
                            self.navigationController?.pushViewController(next, animated: true)
                        }
//                    }
//                    else {
//                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VerifyPasswordViewController") as! VerifyPasswordViewController
//                        self.navigationController?.pushViewController(viewController, animated: true)
//
//                    }
//                }
                
            }
            else if arrMenuTitle[indexPath.row] == "Wallet" {
                
                if (SingletonClass.sharedInstance.isPasscodeON) {
                    
                    if SingletonClass.sharedInstance.setPasscode == "" {
                        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SetPasscodeViewController") as! SetPasscodeViewController
                        viewController.strStatusToNavigate = "Wallet"
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                    else {
                        
//                        if (SingletonClass.sharedInstance.passwordFirstTime) {
//
//                            let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
//                            self.navigationController?.pushViewController(next, animated: true)
//
//                        }
//                        else {
                            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "VerifyPasswordViewController") as! VerifyPasswordViewController
                            viewController.strStatusToNavigate = "Wallet"
                            self.navigationController?.pushViewController(viewController, animated: true)
                            
//                        }
                    }
                }
                else {
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletViewController") as! WalletViewController
                    self.navigationController?.pushViewController(next, animated: true)
                }
                
            }
            else if arrMenuTitle[indexPath.row] == "Account"
            {
                //                self.performSegue(withIdentifier: "segueMyBooking", sender: self)
                
                let next = self.storyboard?.instantiateViewController(withIdentifier: "EditAccountViewController") as! EditAccountViewController
                self.navigationController?.pushViewController(next, animated: true)
                
            }
            else if arrMenuTitle[indexPath.row] == "Favourites" {
                let next = self.storyboard?.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
                
//                let homeVC = ((self.navigationController?.childViewControllers[1] as! CustomSideMenuViewController).childViewControllers[0] as! UINavigationController).childViewControllers[0] as! HomeViewController
                var homeVC : HomeViewController!
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: CustomSideMenuViewController.self) {
                        
                        homeVC = (controller.childViewControllers[0] as! UINavigationController).childViewControllers[0] as! HomeViewController
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
                
                next.delegateForFavourite = homeVC.self as? FavouriteLocationDelegate!
                
                self.navigationController?.pushViewController(next, animated: true)
            }
            else if arrMenuTitle[indexPath.row] == "My Receipts" {
                let next = self.storyboard?.instantiateViewController(withIdentifier: "MyReceiptsViewController") as! MyReceiptsViewController
                self.navigationController?.pushViewController(next, animated: true)
            }
            else if arrMenuTitle[indexPath.row] == "Invite Friends" {
                let next = self.storyboard?.instantiateViewController(withIdentifier: "InviteDriverViewController") as! InviteDriverViewController
                self.navigationController?.pushViewController(next, animated: true)
            }
            else if arrMenuTitle[indexPath.row] == "Settings" {
                let next = self.storyboard?.instantiateViewController(withIdentifier: "SettingPasscodeVC") as! SettingPasscodeVC
                self.navigationController?.pushViewController(next, animated: true)
            }
            else if arrMenuTitle[indexPath.row] == "Become a \(appName) Driver" {
//                UIApplication.shared.openURL(NSURL(string: "https://itunes.apple.com/us/app/pick-n-go-driver/id1320783710?mt=8")! as URL)
            }
            else if arrMenuTitle[indexPath.row] == "Package History"
            {
                let next = self.storyboard?.instantiateViewController(withIdentifier: "PackageHistoryViewController") as! PackageHistoryViewController
                self.navigationController?.pushViewController(next, animated: true)
            }
            
            
            if (arrMenuTitle[indexPath.row] == "Logout") {
                
//                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                
                UserDefaults.standard.removeObject(forKey: "Passcode")
                SingletonClass.sharedInstance.setPasscode = ""
                
                UserDefaults.standard.removeObject(forKey: "isPasscodeON")
                SingletonClass.sharedInstance.isPasscodeON = false
                
                for key in UserDefaults.standard.dictionaryRepresentation().keys {
                    if (key != "Token")
                    {
                        UserDefaults.standard.removeObject(forKey: key.description)
                    }
                }
                
                let socket = (((self.parent as? CustomSideMenuViewController)?.childViewControllers.first as! UINavigationController).childViewControllers.first as! HomeViewController).socket
                
                socket.off(SocketData.kAcceptBookingRequestNotification)
                socket.off(SocketData.kRejectBookingRequestNotification)
                socket.off(SocketData.kPickupPassengerNotification)
                socket.off(SocketData.kBookingCompletedNotification)
                socket.off(SocketData.kAdvancedBookingTripHoldNotification)
                
                socket.off(SocketData.kReceiveDriverLocationToPassenger)
                socket.off(SocketData.kCancelTripByDriverNotficication)
                socket.off(SocketData.kAcceptAdvancedBookingRequestNotification)
                socket.off(SocketData.kRejectAdvancedBookingRequestNotification)
                socket.off(SocketData.kAdvancedBookingPickupPassengerNotification)
                
                socket.off(SocketData.kReceiveHoldingNotificationToPassenger)
                socket.off(SocketData.kAdvancedBookingDetails)
                socket.off(SocketData.kReceiveGetEstimateFare)
                socket.off(SocketData.kInformPassengerForAdvancedTrip)
                socket.off(SocketData.kAcceptAdvancedBookingRequestNotify)
                socket.off(SocketData.kReceiveMessage)
                socket.off(SocketData.kNearByDriverList)
                
                socket.disconnect()
            
                self.performSegue(withIdentifier: "unwindToContainerVC", sender: self)
                
            }
//            else if (indexPath.row == arrMenuTitle.count - 2)
//            {
//                self.performSegue(withIdentifier: "pushToBlank", sender: self)
//            }
            
            self.tableView.reloadData()
        }

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 0)
        {
            if !(DeviceType.IS_IPHONE_5) {
                return 204
            }
            return 174
        }
        else
        {
            if !(DeviceType.IS_IPHONE_5) {
                return 52
            }
            return 42
        }
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        
        if (indexPath.section != 0) {
            let cell  = tableView.cellForRow(at: indexPath as IndexPath) as! ContentTableViewCell
            
            cell.imgDetail?.image = UIImage(named: "\(arrMenuIcons[indexPath.row])Selected")
            cell.lblTitle.textColor = UIColor.init(red: 249/255, green: 179/255, blue: 48/255, alpha: 1.0)
            cell.viewUnderLineOfImage.backgroundColor = UIColor.init(red: 249/255, green: 179/255, blue: 48/255, alpha: 1.0)
        }
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        
        if (indexPath.section != 0) {
            
            let cell  = tableView.cellForRow(at: indexPath as IndexPath) as! ContentTableViewCell
            
            cell.imgDetail?.image = UIImage(named: arrMenuIcons[indexPath.row])
            cell.viewUnderLineOfImage.backgroundColor = UIColor.init(red: 33/255, green: 33/255, blue: 33/255, alpha: 1.0)
            cell.lblTitle.textColor = UIColor.white
        }
    }

    
    func didRegisterCompleted() {
        
        webserviceOfTickPayStatus()
    }
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func navigateToTiCKPay() {
//        webserviceOfTickPayStatus()
        
        if self.varifyKey == 0 {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "TickPayRegistrationViewController") as! TickPayRegistrationViewController
            next.delegateForVerifyStatus = self
            self.navigationController?.pushViewController(next, animated: true)
        }
            
        else if self.varifyKey == 1 {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "TiCKPayNeedToVarifyViewController") as! TiCKPayNeedToVarifyViewController
            self.navigationController?.pushViewController(next, animated: true)
        }
            
        else if self.varifyKey == 2 {
            let next = self.storyboard?.instantiateViewController(withIdentifier: "PayViewController") as! PayViewController
            self.navigationController?.pushViewController(next, animated: true)
        }
    }
    
    
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    var varifyKey = Int()
    func webserviceOfTickPayStatus() {
        
        webserviceForTickpayApprovalStatus(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                if let id = (result as! [String:AnyObject])["Verify"] as? String {
                    
//                    SingletonClass.sharedInstance.TiCKPayVarifyKey = Int(id)!
                    self.varifyKey = Int(id)!
                }
                else if let id = (result as! [String:AnyObject])["Verify"] as? Int {
                    
//                    SingletonClass.sharedInstance.TiCKPayVarifyKey = id
                    self.varifyKey = id
                }

            }
            else {
                print(result)
            }
        }
    }
    
}

//
//  ChatViewController.swift
//  ChatDemo
//
//  Created by Apple on 30/10/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SocketIO


let windowWidth: CGFloat = CGFloat(UIScreen.main.bounds.size.width)

class ChatViewController: UIViewController ,UINavigationControllerDelegate, UITextFieldDelegate {
    
    // ----------------------------------------------------
    // MARK: - Outlets
    // ----------------------------------------------------

    @IBOutlet weak var vwTitle: UIView!
    @IBOutlet weak var btnInfo: UIBarButtonItem!
    
    @IBOutlet weak var btnBack: UIBarButtonItem!
    @IBOutlet weak var tblVw: UITableView!
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var btnEmergency: UIButton!
    @IBOutlet weak var vwSelectedImage: UIView!
    @IBOutlet weak var vwEmergency: UIView!
    @IBOutlet weak var imgVWSelectedImage: UIImageView!
    
    @IBOutlet weak var conVwMessageBottom: NSLayoutConstraint!
    @IBOutlet weak var conVwEmergencyMessageHeight: NSLayoutConstraint!
    @IBOutlet weak var conVwImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constraintHeightOfNavigationBar: NSLayoutConstraint!
    
    @IBOutlet weak var imgPasenger: UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    
    @IBOutlet weak var btnSend: UIButton!
    
    // ----------------------------------------------------
    // MARK: - Global Declaration
    // ----------------------------------------------------

    
    var arrData = [MessageObject]()
    var isEmergency = false
    var isImage = false
    let picker = UIImagePickerController()
    
    var strBookingId = String()
    var strBookingType = String()
    
//    let socket = (UIApplication.shared.delegate as! AppDelegate).SocketManager
    
    
    // ----------------------------------------------------
    // MARK: - Base Methods
    // ----------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtMessage.delegate = self
        
        SingletonClass.sharedInstance.strChatingNowBookingId = strBookingId
        
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.enable = false
        
//        (((self.navigationController?.childViewControllers[1] as! CustomSideMenuViewController).childViewControllers.first as! UINavigationController).childViewControllers.first as! HomeViewController).socket
        
//        btnSend.setImage(UIImage(named: "send"), for: .normal)
//        btnSend.imageView?.setImageColor(color: UIColor.white)
        
        
        self.imgPasenger.isHidden = true
        self.lblDriverName.isHidden = true

        NotificationCenter.default.removeObserver(self, name: NotificationgetResponseOfChatting, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadNewData), name: NotificationgetResponseOfChatting, object: nil)
        
        
        //        self.title = "Richard Hindricks,MD"
        //        self.navigationController?.setNavigationBarHidden(false, animated: true)
        //        self.setProfileImageOnBarButton()
        self.picker.delegate = self
        
        //        for var i in 1...100 {
        //            var obj = MessageObject()
        //            obj.strMessage = i%3 == 0 ? "" : "hihihihihihi"
        //            obj.isSender = i%2 == 0 ? false : true
        //            obj.isImage = i%3  == 0 ? true : false
        //
        //            arrData.append(obj)
        //        }
        
        if strBookingType == "Book Later" || strBookingType == "book later" || strBookingType == "BookLater" || strBookingType == "AdvanceBooking" {
            strBookingType = "AdvanceBooking"
        }
        else {
            strBookingType = "Booking"
        }
        
        webserviceOfChatting(bookingId: strBookingId, bookingType: strBookingType)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboard(false)
        self.hideKeyboard()
        self.registerForKeyboardNotifications()
        
        SingletonClass.sharedInstance.isChatingPresented = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if arrData.count>0 {
            tblVw.reloadData()
            let indexPath = IndexPath.init(row: arrData.count-1, section: 0)
            tblVw.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SingletonClass.sharedInstance.isChatingPresented = false
        
        setupKeyboard(true)
        self.deregisterFromKeyboardNotifications()
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.enable = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        btnSend.setImage(UIImage(named: "send"), for: .normal)
//        btnSend.imageView?.setImageColor(color: UIColor.white)
        
        imgPasenger.layer.cornerRadius = imgPasenger.frame.height / 2
        imgPasenger.layer.masksToBounds = true
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.view.frame.size.height))
        txtMessage.leftView = paddingView
        txtMessage.leftViewMode = .always
        
        //        let barHeight = navigationController?.navigationBar.frame.maxY
        //        constraintHeightOfNavigationBar.constant = barHeight ?? 64
        switch UIScreen.main.nativeBounds.height {
        case 2436:
            print("iPhone X, XS Height")
            constraintHeightOfNavigationBar.constant = 94
        case 1792:
            print("iPhone XR Height")
            constraintHeightOfNavigationBar.constant = 94
        case 2688:
            print("iPhone XS Max Height")
            constraintHeightOfNavigationBar.constant = 94
        default:
            constraintHeightOfNavigationBar.constant = 64
        }
    }

    // ----------------------------------------------------
    // MARK: - Custom Methods
    // ----------------------------------------------------
    
    @objc func reloadNewData() {
        
        arrData.append(SingletonClass.sharedInstance.ChattingMessages)
        
        let indexPath = IndexPath.init(row: arrData.count-1, section: 0)
        
        tblVw.insertRows(at: [indexPath], with: .bottom)
        let path = IndexPath.init(row: arrData.count-1, section: 0)
        tblVw.scrollToRow(at: path, at: .bottom, animated: true)
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        
        var info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size
        conVwMessageBottom.constant = keyboardSize!.height
        self.view.animateConstraintWithDuration()
        
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        conVwMessageBottom.constant = 0
        self.view.animateConstraintWithDuration()
        //Once keyboard disappears, restore original positions
        
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if txtMessage == textField {
            
            txtMessage.text = txtMessage.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    //MARK: Button Methods
    @IBAction func sendClick(_ sender: UIButton) {
        txtMessage.text = txtMessage.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if isImage || !txtMessage.text!.isEmpty{
             self.sendMessage(true)
            /*
            let alert = UIAlertController(title: "Pick N GO", message: "Select User", preferredStyle: .actionSheet)
            let firstAction = UIAlertAction(title: "Sender", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                self.sendMessage(true)
            })
            let secondAction = UIAlertAction(title: "Receiver", style: .default, handler: {(_ action: UIAlertAction) -> Void in
                self.sendMessage(false)
                print("You pressed button two")
                
            })
            alert.addAction(firstAction)
            alert.addAction(secondAction)
            present(alert, animated: true) {() -> Void in }
             */
        }
        
    }
    @IBAction func emergencyClick(_ sender: UIButton) {
        //        btnEmergency.isSelected = !btnEmergency.isSelected
        
        isEmergency = !isEmergency
        
        conVwEmergencyMessageHeight.constant = isEmergency ? 40 : 0
        
        self.view.animateConstraintWithDuration()
    }
    @IBAction func cameraClick(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle:.actionSheet)
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (action) in
            self.openCamra(id: "1")
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            self.openCamra(id: "2")
        }))
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func deleteImageClick(_ sender: Any) {
        imgVWSelectedImage.image = nil
        isImage = false
        conVwImageHeight.constant = 0
        self.view.animateConstraintWithDuration()
    }
    // MARK: Send message
    func sendMessage(_ isSender: Bool){
        let objMessage = MessageObject()
        objMessage.strMessage = txtMessage.text!
        objMessage.isSender = isSender
        objMessage.isEmergency = isEmergency
        objMessage.isImage = isImage
        if objMessage.isImage {
            objMessage.imgMessage = imgVWSelectedImage.image!
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeString = formatter.string(from: Date())
        
        objMessage.date = timeString
        arrData.append(objMessage)
        let indexPath = IndexPath.init(row: arrData.count-1, section: 0)
        
        tblVw.insertRows(at: [indexPath], with: .bottom)
        let path = IndexPath.init(row: arrData.count-1, section: 0)
        tblVw.scrollToRow(at: path, at: .bottom, animated: true)
        
        sendMessageToPassenger(message: txtMessage.text!)
        
        self.resetAll()
    }
    
    func resetAll() {
//        btnSend.setImage(UIImage(named: "send"), for: .normal)
//        btnSend.imageView?.setImageColor(color: UIColor.white)
        txtMessage.text = ""
        isImage = false
        isEmergency = false
        imgVWSelectedImage.image = nil
        conVwImageHeight.constant = 0
        conVwEmergencyMessageHeight.constant = 0
        //        btnEmergency.isSelected = false
        self.view.animateConstraintWithDuration()
    }
    
    func openCamra(id : String){
        if id == "1" {
            self.picker.allowsEditing = false
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true, completion: nil)
            
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.camera)  {
                self.picker.sourceType = .camera
                self.picker.allowsEditing = true
                self.picker.cameraDevice = .front
                self.present(self.picker, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func backClick(_ sender: Any) {
        
        if (self.parent == nil) {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    
    }
    
    @IBAction func profileClick(_ sender: Any) {
        self.performSegue(withIdentifier: "segueProfileDetail", sender: nil)
        
    }
    
    func isModal() -> Bool {
        if (presentingViewController != nil) {
            return true
        }
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        if (tabBarController?.presentingViewController is UITabBarController) {
            return true
        }
        return false
    }
    
    // ----------------------------------------------------
    // MARK: - Socket Methods
    // ----------------------------------------------------
    
    func sendMessageToPassenger(message: String) {
        
        let myJSON = ["BookingId": strBookingId, "Type": strBookingType, "Sender": "passenger", "Message": message] as [String : Any]
        
        NotificationCenter.default.post(name: NotificationgetResponseOfChattingOfSpecificDriver, object: myJSON)
        
//        if self.navigationController != nil {
//            if self.navigationController?.childViewControllers.count != 0 && (self.navigationController?.childViewControllers.count)! > 1 {
//                if let cstSideMenu = self.navigationController?.childViewControllers[1] as? CustomSideMenuViewController {
//                    if cstSideMenu.childViewControllers.count != 0 {
//                        if let naviCtrl = cstSideMenu.childViewControllers.first as? UINavigationController {
//                            if naviCtrl.childViewControllers.count != 0 {
//                                if let homeVC = naviCtrl.childViewControllers.first as? HomeViewController {
//                                    let socket = homeVC.socket
//                                    let myJSON = ["BookingId": strBookingId, "Type": strBookingType, "Sender": "passenger", "Message": message] as [String : Any]
//                                    socket.emit(SocketData.kSendMessage, with: [myJSON])
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
    
    
    // ----------------------------------------------------
    // MARK: - Webservice Service
    // ----------------------------------------------------
    
    func webserviceOfChatting(bookingId: String, bookingType: String) {
        
        //        BookingId/BookingType
        if bookingId != "" && bookingType != "" {
            let param = "\(bookingId)/\(bookingType)"
            
            webserviceForChattingwithPassenger(param as AnyObject) { (result, status) in
                
                if status {
                    print(result)
                    
                    var aryMessages = [[String:Any]]()
                    
                    
                    if let res = result as? [String:Any] {
                        if let passenger = res["driver"] as? [[String:Any]] {
                            if passenger.count != 0 {
                                if let img = passenger.first?["Image"] as? String {
                                    
                                    if img != "" {
                                        self.imgPasenger.isHidden = false
                                        let imageUrl = WebserviceURLs.kImageBaseURL + img
                                        self.imgPasenger.sd_setImage(with: URL(string: imageUrl), completed: nil)
                                    }
                                }
                                
                                if let name = passenger.first?["Fullname"] as? String {
                                    
                                    if name != "" {
                                        self.lblDriverName.isHidden = false
                                        self.lblDriverName.text = name
                                    }
                                }
                            }
                        }
                        
                        if let message = res["message"] as? [[String:Any]] {
                            if message.count != 0 {
                                aryMessages = message
                            }
                        }
                        
                        if aryMessages.count != 0 {
                            
                            for (_, value) in aryMessages.enumerated() {
                                
                                let objMessage = MessageObject()
                                
                                objMessage.strMessage = value["Message"] as! String
                                objMessage.isEmergency = false
                                objMessage.isImage = false
                                
                                if value["SenderId"] as! String == SingletonClass.sharedInstance.strPassengerID {
                                    objMessage.isSender = true
                                }
                                else {
                                    objMessage.isSender = false
                                }
                                
                                objMessage.id = value["Id"] as? String
                                objMessage.bookingId = value["BookingId"] as? String
                                objMessage.type = value["Type"] as? String
                                objMessage.senderId = value["SenderId"] as? String
                                objMessage.sender = value["Sender"] as? String
                                objMessage.receiverId = value["ReceiverId"] as? String
                                objMessage.message = value["Message"] as? String
                                objMessage.date = value["Date"] as? String
                                
                                self.arrData.append(objMessage)
                                
                            }
                            self.tblVw.reloadData()
                        }
                    }
                }
                else {
                    UtilityClass.showAlertOfAPIResponse(param: result, vc: self)
                }
            }
        }
        else {
            UtilityClass.showAlert(appName, message: "Booking Id is missing please go back and reselect", vc: self)
        }
        
    }
    
    
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: MessageCell, forRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let obj = arrData[indexPath.row]
        let strIdentifier = obj.isSender ? "SenderCell" : "RecieverCell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: strIdentifier, for: indexPath) as! MessageCell
        cell.lblMessage.text = obj.strMessage
        
        
//        cell.con_ImgHeight.constant = obj.isImage ? (windowWidth * 171.5)/414.0 : 0
        
        
        cell.constraintHeightOfImage.constant = obj.isImage ? (windowWidth * 171.5)/414.0 : 0
        cell.lblMessage.isHidden = obj.strMessage.isEmpty ? true : false
        cell.lblTime.text = obj.date
        cell.lblReadStatus.isHidden = true
        
//        cell.con_vwEmergencyHeight.constant = obj.isEmergency ? 30 : 0
        
        cell.lblMessage.textColor = UIColor.black
        cell.lblTime.textColor = UIColor.black
        cell.lblReadStatus.textColor = UIColor.black
        
        if obj.isEmergency {
//            cell.vwChatBg.backgroundColor = GlobalConstant.Color.cellEmergencyBgColor
//            cell.lblMessage.textColor = GlobalConstant.Color.AppTitleTextColor
//            cell.lblTime.textColor = GlobalConstant.Color.AppSubTitleTextColor
//            cell.lblReadStatus.textColor = GlobalConstant.Color.AppSubTitleTextColor
        }else {
            if obj.isSender {
//                cell.vwChatBg.backgroundColor = GlobalConstant.Color.AppBlueColor
                cell.lblMessage.textColor = UIColor.black
                cell.lblTime.textColor = UIColor.black
                cell.lblReadStatus.textColor = UIColor.black
            }else{
//                cell.vwChatBg.backgroundColor = GlobalConstant.Color.cellSenderBgColor
//                cell.lblMessage.textColor = GlobalConstant.Color.AppTitleTextColor
//                cell.lblTime.textColor = GlobalConstant.Color.AppSubTitleTextColor
//                cell.lblReadStatus.textColor = GlobalConstant.Color.AppSubTitleTextColor
            }
        }
        
        
        if obj.isImage {
            cell.imgVwPhoto.image = obj.imgMessage
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.00, execute: {
            if obj.isSender == true {
                cell.vwChatBg.roundCorners([.bottomLeft,.topLeft,.topRight], radius: 15.0)
            }else {
                cell.vwChatBg.roundCorners([.bottomRight,.topLeft,.topRight], radius: 15.0)
            }
            
        })
        
        cell.selectionStyle = .none
        return cell
    }
    
}
extension ChatViewController : UIImagePickerControllerDelegate {
    //MARK: - Imagepicker Delegates
   /*
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        //        let data = UIImageJPEGRepresentation(chosenImage, 0.7)
        imgVWSelectedImage.image = chosenImage
        isImage = true
        conVwImageHeight.constant = 50
        self.view.animateConstraintWithDuration()
        dismiss(animated: true) {
            
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    */
}

//MARK: Table Methods
class MessageCell: UITableViewCell {
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var lblReadStatus: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var vwChatBg: UIView!
    @IBOutlet weak var imgVwPhoto: UIImageView!
    
//    @IBOutlet weak var con_ImgHeight: NSLayoutConstraint!
//    @IBOutlet weak var con_vwEmergencyHeight: NSLayoutConstraint!
    
    @IBOutlet weak var constraintHeightOfImage: NSLayoutConstraint!
    
    override func layoutSubviews() {
        
    }
}

class MessageObject  {
    var strMessage: String = ""
    var isSender: Bool = false
    var isEmergency: Bool = false
    var isImage: Bool = false
    var imgMessage = UIImage()
    
    
    var id : String?
    var bookingId : String?
    var type : String?
    var senderId : String?
    var sender : String?
    var receiverId : String?
    var receiver : String?
    var message : String?
    var date : String?
}

extension UIView {
    //For layout change animation
    func animateConstraintWithDuration(duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: { [weak self] in
            self?.layoutIfNeeded() ?? ()
        })
    }
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

func setupKeyboard(_ enable: Bool) {
//    IQKeyboardManager.sharedManager().enable = enable
//    IQKeyboardManager.sharedManager().enableAutoToolbar = enable
//    IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = !enable
    
    //    IQKeyboardManager.sharedManager().previousNextDisplayMode = .alwaysShow
}

extension UIViewController {
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

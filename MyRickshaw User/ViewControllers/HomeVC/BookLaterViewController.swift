//
//  BookLaterViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 04/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import M13Checkbox
import GoogleMaps
import GooglePlaces
import SDWebImage
import FormTextField
import ACFloatingTextfield_Swift
import IQKeyboardManagerSwift

protocol isHaveCardFromBookLaterDelegate {
    
    func didHaveCards()
}

@objc protocol delegateForChooseCarFromBookLater {
//    @objc optional func didCarChoosed(index: Int?)
    @objc optional func didSelectOptions(indexes: [[String:Any]])
    
}

class BookLaterViewController: UIViewController, GMSAutocompleteViewControllerDelegate, UINavigationControllerDelegate, WWCalendarTimeSelectorProtocol, UIPickerViewDelegate, UIPickerViewDataSource, isHaveCardFromBookLaterDelegate, UITextFieldDelegate, delegateForChooseCarFromBookLater {
    
    
    func didSelectOptions(indexes: [[String : Any]]) {
        //        [["Type":"TM Card Holder", "value":0, "key": "TMCardHolder"], ["Type":"Baby Seater", "value":0, "key": "BabySeater"], ["Type":"Hoist Van", "value":0, "key": "HoistVan"]]
        arySelectedCarOptions = indexes
        valueTMCardHolde = 0
        valueBabySeater = 0
        valueHoistVan = 0
        
        if indexes.count != 0 {
            
            for (_,item) in indexes.enumerated() {
                if item["key"] as! String == "TMCardHolder" {
                    valueTMCardHolde = 1
                }
                if item["key"] as! String == "BabySeater" {
                    valueBabySeater = 1
                }
                if item["key"] as! String == "HoistVan" {
                    valueHoistVan = 1
                }
            }
        }
    }
    
    
    
    //-------------------------------------------------------------
    // MARK: - Global Declaration
    //-------------------------------------------------------------
    

    var pickerView = UIPickerView()
    var strModelId = String()
    var BoolCurrentLocation = Bool()
    var strCarModelURL = String()
    var strPassengerType = String()
    var convertDateToString = String()
    var boolIsSelected = Bool()
    var boolIsSelectedNotes = Bool()
    var strCarName = String()
    
    var strFullname = String()
    var strMobileNumber = String()
    
    var placesClient = GMSPlacesClient()
    var locationManager = CLLocationManager()
    
    var aryOfPaymentOptionsNames = [String]()
    var aryOfPaymentOptionsImages = [String]()
    
    var CardID = String()
    var paymentType = String()
    
    var selector = WWCalendarTimeSelector.instantiate()
    var selecorTime = WWCalendarTimeSelector.instantiate()
    
    var dictFlatRate: [String:Any]?
    var strServiceType = String()
    
    var arySelectedCarOptions = [[String:Any]]()
    var intNoOfPassengersLimites = 4
    var valueTMCardHolde = 0
    var valueBabySeater = 0
    var valueHoistVan = 0
    
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblNoOfPassenger.text = "0\(intNumberOfPassenger)"
        if intNumberOfPassenger > 9 {
            lblNoOfPassenger.text = "\(intNumberOfPassenger)"
        }
        
        lblNoIOfLuggage.text = "0\(intNoOfBages)"
        if intNoOfBages > 9 {
            lblNoOfPassenger.text = "\(intNoOfBages)"
        }
        
       
        txtDropOffLocation.delegate = self
        
//        UIApplication.shared.statusBarView?.backgroundColor = UIColor.black
         
         
        
        if #available(iOS 11.0, *) {
            if (UIApplication.shared.keyWindow?.safeAreaInsets.top)! > 0.0 {
                
                print("iPhone X")
            }
            else {
                print("Not iPhone X ")
            }
        } else {
            // Fallback on earlier versions
        }
    
        txtDropOffLocation.text = strDropoffLocation

        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        txtFullName.leftView = paddingView
        txtFullName.leftViewMode = .always
        
        
        selector.delegate = self
        selecorTime.delegate = self
//        alertView.removeFromSuperview()
        
        btnForMySelfAction.addTarget(self, action: #selector(self.ActionForViewMySelf), for: .touchUpInside)
        
        btnForOthersAction.addTarget(self, action: #selector(self.ActionForViewOther), for: .touchUpInside)
        
        viewProocode.isHidden = true
        
        webserviceOfCardList()
        
        pickerView.delegate = self
        
        aryOfPaymentOptionsNames = [""]
        aryOfPaymentOptionsImages = [""]
        
        locationManager.startUpdatingLocation()
        locationManager.delegate = self

        setViewDidLoad()
        
//        txtDataAndTimeFromCalendar.isUserInteractionEnabled = false
        imgCareModel.sd_setImage(with: URL(string: strCarModelURL), completed: nil)
        lblCareModelClass.text = "Car Model: \(strCarName)"
        
        txtFullName.text = strFullname
        txtMobileNumber.text = strMobileNumber

        checkMobileNumber()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
         
          
//        gaveCornerRadius()
        
        if SingletonClass.sharedInstance.CardsVCHaveAryData.count != 0 {
            pickerView.reloadAllComponents()
            txtSelectPaymentMethod.text = ""
            imgPaymentOption.image = UIImage(named: "iconDummyCard")
//            paymentType = "cash"
           pickerView.selectedRow(inComponent: 0)
            txtSelectPaymentMethod.becomeFirstResponder()
            txtSelectPaymentMethod.resignFirstResponder()
 
        }
        
       txtSelectPaymentMethod.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(self.IQKeyboardmanagerDoneMethod))
        
        fillTextFields()
        
//        getPlaceFromLatLong()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fillTextFields() {
        txtPickupLocation.text = strPickupLocation
        txtDropOffLocation.text = strDropoffLocation
        
    }
    
    func gaveCornerRadius() {
        
        viewCurrentLocation.layer.cornerRadius = 5
        viewDestinationLocation.layer.cornerRadius = 5
        
        viewCurrentLocation.layer.borderWidth = 1
        viewDestinationLocation.layer.borderWidth = 1
        
        viewDestinationLocation.layer.borderColor = UIColor.black.cgColor
        viewDestinationLocation.layer.borderColor = UIColor.black.cgColor
        
        viewCurrentLocation.layer.masksToBounds = true
        viewDestinationLocation.layer.masksToBounds = true
        
    }

    func setViewDidLoad() {
        
//        let themeColor: UIColor = UIColor.init(red: 255/255, green: 163/255, blue: 0, alpha: 1.0)
        
        viewMySelf.tintColor = themeYellowColor
        viewOthers.tintColor = themeYellowColor
//        viewFlightNumber.tintColor = themeYellowColor
//        btnNotes.tintColor = themeYellowColor
        
        
        viewMySelf.stateChangeAnimation = .fill
        viewOthers.stateChangeAnimation = .fill
//        viewFlightNumber.stateChangeAnimation = .fill
//        btnNotes.stateChangeAnimation = .fill
        
        viewMySelf.boxType = .square
        
        viewMySelf.checkState = .checked
        viewOthers.boxType = .square
//        btnNotes.boxType = .square
        strPassengerType = "myself"
//        viewFlightNumber.boxType = .square
        
//        constraintsHeightOFtxtFlightNumber.constant = 0 // 30 Height
//        constaintsOfTxtFlightNumber.constant = 0
        imgViewLineForFlightNumberHeight.constant = 0
        
//        constantHavePromoCodeTop.constant = 0
//        constantNoteHeight.constant = 0
        imgViewLineForFlightNumberHeight.constant = 0
        imgViewLineForNotesHeight.constant = 0
        
//        txtFlightNumber.isHidden = true
//        txtFlightNumber.isEnabled = false
//        txtDescription.isEnabled = false
        
        
        alertView.layer.cornerRadius = 10
        alertView.layer.masksToBounds = true
        
//        txtDataAndTimeFromCalendar.layer.borderWidth = 1
//        txtDataAndTimeFromCalendar.layer.cornerRadius = 5
//        txtDataAndTimeFromCalendar.layer.borderColor = UIColor.black.cgColor
//        txtDataAndTimeFromCalendar.layer.masksToBounds = true
        
        
        viewPaymentMethod.layer.borderWidth = 1
        viewPaymentMethod.layer.cornerRadius = 5
        viewPaymentMethod.layer.borderColor = UIColor.black.cgColor
        viewPaymentMethod.layer.masksToBounds = true
        
        btnSubmit.layer.cornerRadius = 10
        btnSubmit.layer.masksToBounds = true
        
//        viewCurrentLocation.layer.shadowOpacity = 0.3
//        viewCurrentLocation.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
//        viewDestinationLocation.layer.shadowOpacity = 0.3
//        viewDestinationLocation.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    @IBOutlet weak var viewProocode: UIView!
    @IBOutlet weak var btnSubmit: UIButton!
    
    @IBOutlet weak var viewMySelf: M13Checkbox!
    @IBOutlet weak var viewOthers: M13Checkbox!
//    @IBOutlet weak var viewFlightNumber: M13Checkbox!
    
    @IBOutlet weak var viewDestinationLocation: UIView!
    @IBOutlet weak var viewCurrentLocation: UIView!
    
    @IBOutlet weak var lblMySelf: UILabel!
    @IBOutlet weak var lblOthers: UILabel!
    
    @IBOutlet weak var lblCareModelClass: UILabel!
    @IBOutlet weak var imgCareModel: UIImageView!
    
    @IBOutlet weak var txtPickupLocation: UITextField!
    @IBOutlet weak var txtDropOffLocation: UITextField!
    
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtMobileNumber: FormTextField!
    @IBOutlet weak var txtDataAndTimeFromCalendar: UITextField!
    
    @IBOutlet weak var lblDataFromCalendar: UILabel!
    @IBOutlet weak var lblTimeFromCalendar: UILabel!
    
    @IBOutlet weak var btnCalendar: UIButton!
 
    @IBOutlet weak var txtFlightNumber: UITextField!
    @IBOutlet weak var constraintsHeightOFtxtFlightNumber: NSLayoutConstraint!
    @IBOutlet weak var constaintsOfTxtFlightNumber: NSLayoutConstraint! // 10
    
    @IBOutlet weak var txtSelectPaymentMethod: UITextField!
    @IBOutlet weak var imgPaymentOption: UIImageView!
    
    @IBOutlet weak var btnNotes: M13Checkbox!
    
    @IBOutlet weak var constantNoteHeight: NSLayoutConstraint!  // 40
    
    @IBOutlet weak var constantHavePromoCodeTop: NSLayoutConstraint!  // 10
    
    @IBOutlet weak var txtPromoCode: UITextField!
    
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet var alertView: UIView!
    @IBOutlet weak var viewPaymentMethod: UIView!
    
    @IBOutlet weak var lblPromoCode: UILabel!
    var BackView = UIView()
    
    @IBOutlet weak var btnForMySelfAction: UIButton!
    @IBOutlet weak var btnForOthersAction: UIButton!
    
    @IBOutlet weak var imgViewLineForFlightNumberHeight: NSLayoutConstraint!
    @IBOutlet weak var imgViewLineForNotesHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewUnderlineForBtnMySelf: UIView!
    @IBOutlet weak var viewUnderlineForBtnOther: UIView!
    
    @IBOutlet weak var lblNoOfPassenger: UILabel!
    @IBOutlet weak var lblNoIOfLuggage: UILabel!
    
    
    //-------------------------------------------------------------
    // MARK: - Button Actions
    //-------------------------------------------------------------
    var intNumberOfPassenger: Int = 1
    var intNoOfBages: Int = 0
    
    @IBAction func btnNoOfPassenger(_ sender: UIButton) {
        if sender.titleLabel?.text == "-" {
            if intNumberOfPassenger != 1 {
                intNumberOfPassenger = intNumberOfPassenger - 1
            }
        }
        else if sender.titleLabel?.text == "+" {
            if intNumberOfPassenger <= intNoOfPassengersLimites {
                intNumberOfPassenger = intNumberOfPassenger + 1
            }
        }
        lblNoOfPassenger.text = "0\(intNumberOfPassenger)"
       
    }
    
    @IBAction func btnNoOfLuggage(_ sender: UIButton) {
        if sender.titleLabel?.text == "-" {
            if intNoOfBages != 0 {
                intNoOfBages = intNoOfBages - 1
            }
        }
        else if sender.titleLabel?.text == "+" {
            if intNoOfBages <= 20 {
                intNoOfBages = intNoOfBages + 1
            }
        }
        lblNoIOfLuggage.text = "0\(intNoOfBages)"
    }
    
    
    @IBAction func btnApply(_ sender: UIButton) {
        
       lblPromoCode.text = txtPromoCode.text
        
        viewProocode.isHidden = true
        
//        self.view.alpha = 1.0
//        BackView.removeFromSuperview()
//        alertView.removeFromSuperview()
        
        
    }
    @IBAction func btnCancel(_ sender: UIButton) {
        
        viewProocode.isHidden = true
        
        txtPromoCode.text = ""
        lblPromoCode.text = ""
        
//        self.view.alpha = 1.0
//        BackView.removeFromSuperview()
//        alertView.removeFromSuperview()
    }
    
    @IBAction func btnHavePromoCode(_ sender: UIButton) {
        
        txtPromoCode.becomeFirstResponder()
        viewProocode.isHidden = false
        
//        UIApplication.shared.keyWindow!.bringSubview(toFront: alertView)
    }
    
    @IBAction func btnNotes(_ sender: M13Checkbox) {
        
        boolIsSelectedNotes = !boolIsSelectedNotes
        
        if (boolIsSelectedNotes) {
            
            constantNoteHeight.constant = 40
//            constantHavePromoCodeTop.constant = 10
            imgViewLineForNotesHeight.constant = 1
//            txtSelectPaymentMethod.isHidden = false
             txtDescription.isEnabled = true
        }
        else {
            
            constantNoteHeight.constant = 0
//            constantHavePromoCodeTop.constant = 0
            imgViewLineForNotesHeight.constant = 0
//            txtSelectPaymentMethod.isHidden = true
            txtDescription.isEnabled = false

        }
        
    }
    @IBAction func txtSelectPaymentMethod(_ sender: UITextField) {
        
        txtSelectPaymentMethod.inputView = pickerView
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        
    self.navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func viewMySelf(_ sender: M13Checkbox) {
     
        ActionForViewMySelf()
       
    }
    
    @objc func ActionForViewMySelf() {
        
        viewMySelf.checkState = .checked
        viewOthers.checkState = .unchecked
        viewMySelf.stateChangeAnimation = .fill
    
        txtFullName.text = strFullname
        txtMobileNumber.text = strMobileNumber

        strPassengerType = "myself"
        
        btnForOthersAction.setTitleColor(UIColor.init(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0), for: .normal)
        viewUnderlineForBtnOther.backgroundColor = UIColor.white
        
        btnForMySelfAction.setTitleColor(UIColor.black, for: .normal)
        viewUnderlineForBtnMySelf.backgroundColor = UIColor.black
        
    }
    
    @objc func ActionForViewOther() {
        viewMySelf.checkState = .unchecked
        viewOthers.checkState = .checked
        viewOthers.stateChangeAnimation = .fill
      
        txtFullName.text = ""
        txtMobileNumber.text = ""
        
        strPassengerType = "other"
        
        btnForOthersAction.setTitleColor(UIColor.black, for: .normal)
        viewUnderlineForBtnOther.backgroundColor = UIColor.black
        
        btnForMySelfAction.setTitleColor(UIColor.init(red: 146/255, green: 146/255, blue: 146/255, alpha: 1.0), for: .normal)
        viewUnderlineForBtnMySelf.backgroundColor = UIColor.white
    }
    
    @IBAction func viewOthers(_ sender: M13Checkbox) {
        ActionForViewOther()
        
    }
    
    @IBAction func viewFlightNumber(_ sender: M13Checkbox) {
        
        boolIsSelected = !boolIsSelected
        
        if (boolIsSelected) {
            
            constraintsHeightOFtxtFlightNumber.constant = 40
            constaintsOfTxtFlightNumber.constant = 10
            imgViewLineForFlightNumberHeight.constant = 1
            txtFlightNumber.isHidden = false
            txtFlightNumber.isEnabled = true
        }
        else {
            
            constraintsHeightOFtxtFlightNumber.constant = 0
            constaintsOfTxtFlightNumber.constant = 0
            imgViewLineForFlightNumberHeight.constant = 0
            txtFlightNumber.isHidden = true
            txtFlightNumber.isEnabled = false
           
        }
    }
    
    @IBAction func txtPickupLocation(_ sender: UITextField) {

        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        
        BoolCurrentLocation = true
        
        UtilityClass.showNavigationTextColor(color: UIColor.black)
        
        present(acController, animated: true, completion: nil)
        
    }
    @IBAction func txtDropOffLocation(_ sender: UITextField) {
        
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        
        BoolCurrentLocation = false
        UtilityClass.showNavigationTextColor(color: UIColor.black)
        
        present(acController, animated: true, completion: nil)
        
    }
    
    @IBAction func btnCalendar(_ sender: UIButton) {
        
//        selector.optionCalendarFontColorPastDates = UIColor.gray
//
//        selector.optionButtonFontColorDone = themeYellowColor
//        selector.optionSelectorPanelBackgroundColor = themeYellowColor
//        selector.optionCalendarBackgroundColorTodayHighlight = themeYellowColor
//        selector.optionTopPanelBackgroundColor = themeYellowColor
//        selector.optionClockBackgroundColorMinuteHighlightNeedle = themeYellowColor
//        selector.optionClockBackgroundColorHourHighlight = themeYellowColor
//        selector.optionClockBackgroundColorAMPMHighlight = themeYellowColor
//        selector.optionCalendarBackgroundColorPastDatesHighlight = themeYellowColor
//        selector.optionCalendarBackgroundColorFutureDatesHighlight = themeYellowColor
//        selector.optionClockBackgroundColorMinuteHighlight = themeYellowColor
        
        setCalendarSelector(mySelector: selector)
        
//        selector.optionStyles.showDateMonth(true)
//        selector.optionStyles.showYear(false)
//        selector.optionStyles.showMonth(false)
//        selector.optionStyles.showTime(false)
        
        // 2. You can then set delegate, and any customization options

        selector.optionTopPanelTitle = "Please choose date"
        
        selector.optionIdentifier = "Time" as AnyObject


//        selector.optionCurrentDate = dateCurrent.addingTimeInterval(30 * 60)

        // 3. Then you simply present it from your view controller when necessary!
        self.present(selector, animated: true, completion: nil)
   
    }
    
    @IBAction func btnCalenderTime(_ sender: UIButton) {
        
//        selecorTime.optionCalendarFontColorPastDates = UIColor.gray
//        selecorTime.optionButtonFontColorDone = themeYellowColor
//        selecorTime.optionSelectorPanelBackgroundColor = themeYellowColor
//        selecorTime.optionCalendarBackgroundColorTodayHighlight = themeYellowColor
//        selecorTime.optionTopPanelBackgroundColor = themeYellowColor
//        selecorTime.optionClockBackgroundColorMinuteHighlightNeedle = themeYellowColor
//        selecorTime.optionClockBackgroundColorHourHighlight = themeYellowColor
//        selecorTime.optionClockBackgroundColorAMPMHighlight = themeYellowColor
//        selecorTime.optionCalendarBackgroundColorPastDatesHighlight = themeYellowColor
//        selecorTime.optionCalendarBackgroundColorFutureDatesHighlight = themeYellowColor
//        selecorTime.optionClockBackgroundColorMinuteHighlight = themeYellowColor
        
        setCalendarSelector(mySelector: selecorTime)
        
        
//        selecorTime.optionStyles.showDateMonth(false)
//        selecorTime.optionStyles.showYear(false)
//        selecorTime.optionStyles.showMonth(false)
//        selecorTime.optionStyles.showTime(true)
        
        // 2. You can then set delegate, and any customization options
        
        selecorTime.optionTopPanelTitle = "Please choose date"
        
        selecorTime.optionIdentifier = "Time" as AnyObject
        
        
        let isoDate = convertDateToString

        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from:isoDate)
        
        let dateCurrent = date//Date()
        
        
        selecorTime.optionCurrentDate = dateCurrent?.addingTimeInterval(30 * 60) ?? Date().addingTimeInterval(30*60)
        
        // 3. Then you simply present it from your view controller when necessary!
        self.present(selecorTime, animated: true, completion: nil)
    }
    
    func setCalendarSelector(mySelector: WWCalendarTimeSelector) {
        
        mySelector.optionCalendarFontColorPastDates = UIColor.gray
        mySelector.optionButtonFontColorDone = themeYellowColor
        mySelector.optionSelectorPanelBackgroundColor = themeYellowColor
        mySelector.optionCalendarBackgroundColorTodayHighlight = themeYellowColor
        mySelector.optionTopPanelBackgroundColor = themeYellowColor
        mySelector.optionClockBackgroundColorMinuteHighlightNeedle = themeYellowColor
        mySelector.optionClockBackgroundColorHourHighlight = themeYellowColor
        mySelector.optionClockBackgroundColorAMPMHighlight = themeYellowColor
        mySelector.optionCalendarBackgroundColorPastDatesHighlight = themeYellowColor
        mySelector.optionCalendarBackgroundColorFutureDatesHighlight = themeYellowColor
        mySelector.optionClockBackgroundColorMinuteHighlight = themeYellowColor
        
        
        
//        setCalendarSelector(mySelector: selector)
        if mySelector == selector {
            mySelector.optionStyles.showDateMonth(true)
            mySelector.optionStyles.showYear(false)
            mySelector.optionStyles.showMonth(false)
            mySelector.optionStyles.showTime(false)
        }
        else if mySelector == selecorTime {
            mySelector.optionStyles.showDateMonth(false)
            mySelector.optionStyles.showYear(false)
            mySelector.optionStyles.showMonth(false)
            mySelector.optionStyles.showTime(true)
        }
       
    }
    
    
    @IBAction func btnSubmit(_ sender: UIButton) {
        
//        UtilityClass.setCustomAlert(title: "\(appName)", message: "Your ride has been booked.", completionHandler: { (index, title) in
//
//            self.navigationController?.popViewController(animated: true)
//        })
        
        if txtPickupLocation.text == "" {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter pickup location") { (index, title) in
            }
        }
        else if txtDropOffLocation.text == "" {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter dropoff location") { (index, title) in
            }
        }
        else if txtFullName.text == "" {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter passenger name") { (index, title) in
            }
        }
        else if txtMobileNumber.text == "" {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter mobile number") { (index, title) in
            }
        }
        else if lblDataFromCalendar.text == "" || lblDataFromCalendar.text == "Select pickup date" {
            UtilityClass.setCustomAlert(title: appName, message: "Please select pickup date") { (index, title) in
            }
        }
        else if lblTimeFromCalendar.text == "" || lblTimeFromCalendar.text == "Select pickup time" {
            UtilityClass.setCustomAlert(title: appName, message: "Please select pickup time") { (index, title) in
            }
        }
        else if paymentType == "" {
            UtilityClass.setCustomAlert(title: appName, message: "Please select payment type") { (index, title) in
            }
        }
        else {
            webserviceOFBookLater()
        }
        
//        if txtFullName.text == "" || txtMobileNumber.text == "" || txtPickupLocation.text == "" || txtDropOffLocation.text == "" || lblDataFromCalendar.text == "" || lblTimeFromCalendar.text == "" || strPassengerType == "" || paymentType == "" {
//
//            UtilityClass.setCustomAlert(title: appName, message: "All fields are required...") { (index, title) in
//            }
//        }
            
        
            
            
//        else if viewMySelf.checkState == .unchecked && viewOthers.checkState == .unchecked {
//            UtilityClass.setCustomAlert(title: appName, message: "Please Checked Myself or Other") { (index, title) in }
//        }
//        else {
//            webserviceOFBookLater()
//        }
        
    }
    
    var validationsMobileNumber = Validation()
    var inputValidatorMobileNumber = InputValidator()
    
    func checkMobileNumber() {
        
        
        txtMobileNumber.inputType = .integer
        
        
        //        var validation = Validation()
        validationsMobileNumber.maximumLength = 10
        validationsMobileNumber.minimumLength = 10
        validationsMobileNumber.characterSet = NSCharacterSet.decimalDigits
        let inputValidator = InputValidator(validation: validationsMobileNumber)
        txtMobileNumber.inputValidator = inputValidator
        
        print("txtMobileNumber : \(txtMobileNumber.text!)")
    }
    
    var strPickupLocation = String()
    var strDropoffLocation = String()
    
    var doublePickupLat = Double()
    var doublePickupLng = Double()
    
    var doubleDropOffLat = Double()
    var doubleDropOffLng = Double()
    
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        if BoolCurrentLocation {
            txtPickupLocation.text = place.formattedAddress
            strPickupLocation = place.formattedAddress!
            doublePickupLat = place.coordinate.latitude
            doublePickupLng = place.coordinate.longitude
            
        }
        else {
            txtDropOffLocation.text = place.formattedAddress
            strDropoffLocation = place.formattedAddress!
            doubleDropOffLat = place.coordinate.latitude
            doubleDropOffLng = place.coordinate.longitude
        }
        UtilityClass.hideNavigationTextColor()
        
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: \(error)")
        UtilityClass.hideNavigationTextColor()
        dismiss(animated: true, completion: nil)
    }
    
    // User cancelled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        UtilityClass.hideNavigationTextColor()
        dismiss(animated: true, completion: nil)
    }
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txtDropOffLocation {
            
            self.txtDropOffLocation(txtDropOffLocation)
            
            return false
        }
        
        return true
    }
    
    
    func getPlaceFromLatLong()
    {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            //            self.txtCurrentLocation.text = "No current place"
            self.txtPickupLocation.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.strPickupLocation = place.formattedAddress!
                    self.doublePickupLat = place.coordinate.latitude
                    self.doublePickupLng = place.coordinate.longitude
                    self.txtPickupLocation.text = place.formattedAddress?.components(separatedBy: ", ")
                        .joined(separator: "\n")
                }
            }
        })
    }
    
    func setCardIcon(str: String) -> String {
//        visa , mastercard , amex , diners , discover , jcb , other
        var CardIcon = String()
        
        switch str {
        case "visa":
            CardIcon = "Visa"
            return CardIcon
        case "mastercard":
            CardIcon = "MasterCard"
            return CardIcon
        case "amex":
            CardIcon = "Amex"
            return CardIcon
        case "diners":
            CardIcon = "Diners Club"
            return CardIcon
        case "discover":
            CardIcon = "Discover"
            return CardIcon
        case "jcb":
            CardIcon = "JCB"
            return CardIcon
        case "iconCashBlack":
            CardIcon = "iconCashBlack"
            return CardIcon
        case "iconWalletBlack":
            CardIcon = "iconWalletBlack"
            return CardIcon
        case "iconPlusBlack":
            CardIcon = "iconPlusBlack"
            return CardIcon
        case "other":
            CardIcon = "iconDummyCard"
            return CardIcon
        default:
            return ""
        }
        
    }
    
    func didHaveCards() {
        
        aryCards.removeAll()
        webserviceOfCardList()
    }
    
    @objc func IQKeyboardmanagerDoneMethod() {
        
        if (isAddCardSelected) {
             self.addNewCard()
        }
        
//        txtSelectPaymentMethod.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(self.IQKeyboardmanagerDoneMethod))
    }
    
  
    
    //-------------------------------------------------------------
    // MARK: - PickerView Methods
    //-------------------------------------------------------------
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return aryCards.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//
//    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let data = aryCards[row]
        
        let myView = UIView(frame: CGRect(x:0, y:0, width: pickerView.bounds.width - 30, height: 60))
        
        let centerOfmyView = myView.frame.size.height / 4
 
        
        let myImageView = UIImageView(frame: CGRect(x:0, y:centerOfmyView, width:40, height:26))
        myImageView.contentMode = .scaleAspectFit
        
        var rowString = String()
       
     
        switch row {
            
        case 0:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 1:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 2:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 3:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 4:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 5:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 6:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 7:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 8:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 9:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 10:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        default:
            rowString = "Error: too many rows"
            myImageView.image = nil
        }
        let myLabel = UILabel(frame: CGRect(x:60, y:0, width:pickerView.bounds.width - 90, height:60 ))
//        myLabel.font = UIFont(name:some, font, size: 18)
        myLabel.text = rowString
        
        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        
        return myView
    }
    
    var isAddCardSelected = Bool()
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let data = aryCards[row]
        
        imgPaymentOption.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        txtSelectPaymentMethod.text = data["CardNum2"] as? String
        
        if data["CardNum"] as! String == "Add a Card" {
            
            isAddCardSelected = true
//            self.addNewCard()
        }
        
        let type = data["CardNum"] as! String
        
        if type  == "wallet" {
            paymentType = "wallet"
        }
        else if type == "cash" {
            paymentType = "cash"
        }
        else if type == "credit" {
            paymentType = "credit"
        }
        else {
            paymentType = "card"
        }
        
        
        if paymentType == "card" {
            
            if data["Id"] as? String != "" {
                CardID = data["Id"] as! String
            }
        }
        
        // do something with selected row
    }
    
    func addNewCard() {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
        next.delegateAddCardFromBookLater = self
        self.isAddCardSelected = false
        self.navigationController?.present(next, animated: true, completion: nil)
    }
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    var selectedItem = IndexPath()
//    func didCarChoosed(index: Int?) {
//        if SingletonClass.sharedInstance.carList != nil {
//            strModelId = SingletonClass.sharedInstance.carList![index!].id!
//            selectedItem = IndexPath(row: index!, section: 0)
//        }
//
//    }
    
    @IBAction func btnMoreOptions(_ sender: UIButton) {
        self.performSegue(withIdentifier: "segueMoreOptions", sender: self)
    }

    
    //-------------------------------------------------------------
    // MARK: - Prepare For Segue
    //-------------------------------------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueMoreOptions" {
            if let vc = segue.destination as? MoreOptionsViewController {
                vc.isFromBookLater = true
                vc.delegateBookLater = self
                
//                if selectedItem.count == 0 {
//                    vc.selectedItem = IndexPath(row: 0, section: 0)
//                }
//                else {
//                    vc.selectedItem = selectedItem
//                }
                vc.arySelectedCarModelData = arySelectedCarOptions
            }
        }
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Calendar Method
    //-------------------------------------------------------------
    
    var currentDate = Date()
    
    func WWCalendarTimeSelectorDone(_ selector: WWCalendarTimeSelector, date: Date)
    {
        if selector == selecorTime {
            
//            if currentDate < date {
            
                //            let calendarDate = Calendar.current
                //            let hour = calendarDate.component(.hour, from: date)
                //            let minutes = calendarDate.component(.minute, from: date)
                
            let currentTimeInterval = currentDate.addingTimeInterval(30 * 60)
            
            if  date > currentTimeInterval {
        
                let myDateFormatter: DateFormatter = DateFormatter()
                myDateFormatter.dateFormat = "hh:mm a"// "dd/MM/yyyy hh:mm a"
                
                let dateOfPostToApi: DateFormatter = DateFormatter()
                dateOfPostToApi.dateFormat = "yyyy-MM-dd HH:mm:ss a" //"HH:mm:ss"  // "yyyy-MM-dd HH:mm:ss"
                
                convertDateToString = dateOfPostToApi.string(from: date)
                
                let finalDate = myDateFormatter.string(from: date)
                
                // get the date string applied date format
                let mySelectedDate = String(describing: finalDate)
                
                lblTimeFromCalendar.text = mySelectedDate
            }
            else {

                lblTimeFromCalendar.text = "Select pickup time"

                UtilityClass.setCustomAlert(title: "Time should be", message: "Please select 30 minutes greater time from current time!") { (index, title) in
                }
            }
//            }
        }
        else if selector == self.selector {
            
            
            if currentDate.endOfHour <= date.endOfHour {
                
                //            let calendarDate = Calendar.current
                //            let hour = calendarDate.component(.hour, from: date)
                //            let minutes = calendarDate.component(.minute, from: date)
                
//                let currentTimeInterval = currentDate.addingTimeInterval(30 * 60)
//
//                if  date > currentTimeInterval {
                
                    let myDateFormatter: DateFormatter = DateFormatter()
                    myDateFormatter.dateFormat = "yyyy-MM-dd" // "dd/MM/yyyy hh:mm a"
                    
                    let dateOfPostToApi: DateFormatter = DateFormatter()
                    dateOfPostToApi.dateFormat = "yyyy-MM-dd HH:mm:ss" //"yyyy-MM-dd"  // "yyyy-MM-dd HH:mm:ss"
                    
                    convertDateToString = dateOfPostToApi.string(from: date)
                    
                    let finalDate = myDateFormatter.string(from: date)
                    
                    // get the date string applied date format
                    let mySelectedDate = String(describing: finalDate)
                    
                    lblDataFromCalendar.text = mySelectedDate
//                }
//                else {
                
//                    lblDataFromCalendar.text = ""
                    
//                    UtilityClass.setCustomAlert(title: "Time should be", message: "Please select 30 minutes greater time from current time!") { (index, title) in
//                    }
                    
//                }
                
            }
            else {
                lblDataFromCalendar.text = "Select pickup date"
            }
        }
       
    }
    
    func WWCalendarTimeSelectorWillDismiss(_ selector: WWCalendarTimeSelector) {
        
    }
    
    func WWCalendarTimeSelectorDidDismiss(_ selector: WWCalendarTimeSelector) {
        
    }

    func WWCalendarTimeSelectorShouldSelectDate(_ selector: WWCalendarTimeSelector, date: Date) -> Bool {
        
        
        
        if selector != self.selector {
            
            if currentDate < date {
                
                let currentTimeInterval = currentDate.addingTimeInterval(30 * 60)
                
                if  date > currentTimeInterval {
                    
                    
                    return true
                }
                
                return false
            }
        }
        else {
            if currentDate <= date {
                return true
            }
//            return false
        }
        
        return false
    }
    
   
    
    
    //-------------------------------------------------------------
    // MARK: - Webservice For Book Later
    //-------------------------------------------------------------
    
    //PassengerId,ModelId,PickupLocation,DropoffLocation,PassengerType(myself,other),PassengerName,PassengerContact,PickupDateTime,FlightNumber,
    //PromoCode,Notes,PaymentType,CardId(If paymentType is card)
    
    func webserviceOFBookLater()
    {
        
        var dictData = [String:AnyObject]()
        
        dictData["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        dictData["ModelId"] = strModelId as AnyObject
        dictData["PickupLocation"] = txtPickupLocation.text as AnyObject
        dictData["DropoffLocation"] = txtDropOffLocation.text as AnyObject
        dictData["PassengerType"] = strPassengerType as AnyObject
        dictData["PassengerName"] = txtFullName.text as AnyObject
        dictData["PassengerContact"] = txtMobileNumber.text as AnyObject
        dictData["PickupDateTime"] = convertDateToString as AnyObject
        
        if lblPromoCode.text == "" {
            
        }
        else {
            dictData["PromoCode"] = lblPromoCode.text as AnyObject
        }
        
        dictData["Notes"] = txtDescription.text as AnyObject
       
        if paymentType == "" {
            
            UtilityClass.setCustomAlert(title: appName, message: "Select Payment Type") { (index, title) in
            }
        }
        else {
            dictData["PaymentType"] = paymentType as AnyObject
        }
        
        if CardID == "" {
          
        }
        else {
            dictData["CardId"] = CardID as AnyObject
        }
        
        if txtFlightNumber.text!.count == 0 {
            
            dictData["FlightNumber"] = "" as AnyObject
        }
        else {
            dictData["FlightNumber"] = txtFlightNumber.text as AnyObject
        }
        
        dictData[SubmitBookingRequest.kNoOfLuggage] = lblNoIOfLuggage.text as AnyObject
        dictData[SubmitBookingRequest.kNoOfPassenger] = lblNoOfPassenger.text as AnyObject
        
        
        if strServiceType == ServiceType.FlatRate.rawValue {
            if dictFlatRate != nil {
               
                dictData["FlatRateId"] = checkDictionaryHaveValue(dictData: dictFlatRate!, didHaveValue: "Id", isNotHave: "") as AnyObject
            }
        }
        else {
            strServiceType = ServiceType.PointToPoint.rawValue
        }
        
        dictData["ServiceType"] = strServiceType as AnyObject
        
        dictData["TMCardHolder"] = valueTMCardHolde as AnyObject
        dictData["BabySeater"] = valueBabySeater as AnyObject
        dictData["HoistVan"] = valueHoistVan as AnyObject
        
        webserviceForBookLater(dictData as AnyObject) { (result, status) in
            
            if (status) {
                print(result)

                UtilityClass.setCustomAlert(title: "\(appName)", message: "Your ride has been booked.", completionHandler: { (index, title) in
                    
                    self.navigationController?.popViewController(animated: true)
                })
                
 /*
                {
                    info =     {
                        BookingFee = "2.2";
                        Duration = 27;
                        EstimatedFare = "43.28";
                        GrandTotal = "45.48";
                        Id = 1;
                        KM = "9.6";
                        SubTotal = "43.28";
                        Tax = "4.548";
                    };
                    status = 1;
                }
*/
                
            } else {
                
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
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    var aryCards = [[String:AnyObject]]()
    
    func webserviceOfCardList() {
        
        webserviceForCardList(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                if let res = result as? [String:AnyObject] {
                    if let cards = res["cards"] as? [[String:AnyObject]] {
                        self.aryCards = cards
                    }
                }
                
                var dict = [String:AnyObject]()
                dict["CardNum"] = "cash" as AnyObject
                dict["CardNum2"] = "cash" as AnyObject
                dict["Type"] = "iconCashBlack" as AnyObject
                
                var dict2 = [String:AnyObject]()
                dict2["CardNum"] = "wallet" as AnyObject
                dict2["CardNum2"] = "wallet" as AnyObject
                dict2["Type"] = "iconWalletBlack" as AnyObject
                
                
                self.aryCards.append(dict)
                self.aryCards.append(dict2)
                
                
                
                var dict3 = [String:AnyObject]()
                dict3["CardNum"] = "credit" as AnyObject
                dict3["CardNum2"] = "credit" as AnyObject
                dict3["Type"] = "iconWalletBlack" as AnyObject
                
                
                if(UtilityClass.returnValueForCredit(key: "IsRequestCreditAccount") == "2")
                {
                    self.aryCards.append(dict3)
                    
                }
                

                
                if self.aryCards.count == 2 {
                    var dict4 = [String:AnyObject]()
                    dict4["Id"] = "000" as AnyObject
                    dict4["CardNum"] = "Add a Card" as AnyObject
                    dict4["CardNum2"] = "Add a Card" as AnyObject
                    dict4["Type"] = "iconPlusBlack" as AnyObject
                    self.aryCards.append(dict4)
                    
                }
                
                self.pickerView.selectedRow(inComponent: 0)
                let data = self.aryCards[0]
                
                self.imgPaymentOption.image = UIImage(named: self.setCardIcon(str: data["Type"] as! String))
                self.txtSelectPaymentMethod.text = data["CardNum2"] as? String
                
                let type = data["CardNum"] as! String
                
                if type  == "wallet" {
                    self.paymentType = "wallet"
                }
                else if type == "cash" {
                    self.paymentType = "cash"
                }
                else {
                    self.paymentType = "card"
                }
                if self.paymentType == "card" {
                    
                    if data["Id"] as? String != "" {
                        self.CardID = data["Id"] as! String
                    }
                }
                self.pickerView.reloadAllComponents()
              
                /*
                 {
                     cards =     (
                     {
                         Alias = visa;
                         CardNum = 4639251002213023;
                         CardNum2 = "xxxx xxxx xxxx 3023";
                         Id = 59;
                         Type = visa;
                     }
                     );
                     status = 1;
                 }
                 */


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
    
    
    @IBAction func btnClearCurrentLocation(_ sender: UIButton) {
        txtPickupLocation.text = ""
    }
    
    @IBAction func btnClearDropOffLocation(_ sender: UIButton) {
        txtDropOffLocation.text = ""
    }
    
    
}

// Delegates to handle events for the location manager.
extension BookLaterViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
//        print("Location: \(location)")
        
//        self.getPlaceFromLatLong()
     
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: break
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       
        print("Error: \(error)")
    }
}

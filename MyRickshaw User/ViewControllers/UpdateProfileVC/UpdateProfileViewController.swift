//
//  UpdateProfileViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 13/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import SDWebImage
import M13Checkbox
import NVActivityIndicatorView
import ACFloatingTextfield_Swift

class UpdateProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AKRadioButtonsControllerDelegate, UITextFieldDelegate {
    
    
    func selectedButton(sender: AKRadioButton) {
        
        print(sender.currentTitle!)
        
        switch sender.titleLabel?.text?.lowercased()
        {
        case "male":
            gender = "male"
        case "female":
            gender = "female"
        case "yes":
            strTMCardHolder = "1"
            stackViewForTMCardHolderText.isHidden = false
        case "no":
            strTMCardHolder = "0"
            stackViewForTMCardHolderText.isHidden = true
        default:
            gender = "male"
        }
        
    }
    
    @IBOutlet weak var constraintOfHeightOfNavaigationView: NSLayoutConstraint! // 64
    
    @IBOutlet weak var stackViewForTMCardHolderText: UIStackView!
    @IBOutlet weak var txtTMCardHolderText: UITextField!

    var radioButtonsController: AKRadioButtonsController!
    
    var firstName = String()
    var lastName = String()
    var fullName = String()
    var gender = String()
    var strTMCardHolder = String()


    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        txtFirstName.sizeToFit()
      
        
        if (DeviceType.IS_IPHONE_X) {
            constraintOfHeightOfNavaigationView.constant = 88
        }
        

        setData()
        
        btnSave.layer.cornerRadius = 5
        btnSave.layer.masksToBounds = true
        
        self.radioButtonsController = AKRadioButtonsController(radioButtons: self.radioButtons)
        self.radioButtonsController.strokeColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        self.radioButtonsController.startGradColorForSelected = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        self.radioButtonsController.endGradColorForSelected = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)//UIColor.init(red: 255/255, green: 163/255, blue: 0, alpha: 1)
        self.radioButtonsController.selectedImage = UIImage(named: "iconRadioButtonSelected")
        self.radioButtonsController.standartImage = UIImage(named: "iconRadioButtonUnSelected")
        self.radioButtonsController.selectedIndex = 1
        if gender == "Male"  || gender == "male" {
            self.radioButtonsController.selectedIndex = 0
        }
        
        self.radioButtonsController.delegate = self
        
        if !DeviceType.IS_IPHONE_5 || !DeviceType.IS_IPHONE_4_OR_LESS || !DeviceType.IS_IPAD {
//            stackViewForTextField.spacing = 20
//            constraintHeightOfBottomView.constant = 200
        }
        
        self.radioButtonsController = AKRadioButtonsController(radioButtons: self.radioButtonsTMCardHolder)
        self.radioButtonsController.strokeColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        self.radioButtonsController.startGradColorForSelected = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        self.radioButtonsController.endGradColorForSelected = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)//UIColor.init(red: 255/255, green: 163/255, blue: 0, alpha: 1)
        self.radioButtonsController.selectedImage = UIImage(named: "iconRadioButtonSelected")
        self.radioButtonsController.standartImage = UIImage(named: "iconRadioButtonUnSelected")
        self.radioButtonsController.selectedIndex = 1
        self.stackViewForTMCardHolderText.isHidden = true
        if strTMCardHolder == "1" {
            self.radioButtonsController.selectedIndex = 0
            self.stackViewForTMCardHolderText.isHidden = false
        }
        self.radioButtonsController.delegate = self //class should implement AKRadioButtonsControllerDelegate
//        strTMCardHolder = "0"
        
        txtFirstName.delegate = self
        txtLastName.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imgProfile.layer.cornerRadius = imgProfile.frame.width / 2
        imgProfile.layer.borderWidth = 1.0
        imgProfile.layer.borderColor = themeYellowColor.cgColor
        imgProfile.layer.masksToBounds = true

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == txtFirstName {
            txtFirstName.text = txtFirstName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        else if textField == txtLastName {
            txtLastName.text = txtLastName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblEmailId: UILabel!
    @IBOutlet weak var lblContactNumber: UILabel!
    
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: ACFloatingTextfield!
    @IBOutlet weak var txtAddress: ACFloatingTextfield!
    @IBOutlet weak var txtDateOfBirth: ACFloatingTextfield!
    
//    @IBOutlet weak var viewMale: M13Checkbox!
//    @IBOutlet weak var viewFemale: M13Checkbox!
  
    @IBOutlet weak var btnSave: UIButton!
    
//    @IBOutlet var viewChangePassword: UIView!
    @IBOutlet var btnChangePassword: UIButton!
    @IBOutlet var btnProfile: UIButton!
    
    @IBOutlet var radioButtons: [AKRadioButton]!
    @IBOutlet var radioButtonsTMCardHolder: [AKRadioButton]!

    @IBOutlet weak var stackViewForTextField: UIStackView!
    @IBOutlet weak var constraintHeightOfBottomView: NSLayoutConstraint! // 151
    
    
    
//    txtFirstName
//    ACFloatingTextfield
    
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
//    @IBAction func btnMale(_ sender: UIButton) {
        
//        viewMale.checkState = .checked
//        viewMale.tintColor = themeYellowColor
//        viewFemale.checkState = .unchecked
        
//        gender = "Male"
//    }
//    @IBAction func btnFemale(_ sender: UIButton) {
        
//        viewFemale.checkState = .checked
//        viewFemale.tintColor = themeYellowColor
//        viewMale.checkState = .unchecked
        
//        gender = "Female"
//    }
    @IBOutlet weak var btnCall: UIButton!
    @IBAction func btCallClicked(_ sender: UIButton)
    {
        
        let contactNumber = helpLineNumber
        
        if contactNumber == "" {
            
            UtilityClass.setCustomAlert(title: "\(appName)", message: "Contact number is not available") { (index, title) in
            }
        }
        else
        {
            callNumber(phoneNumber: contactNumber)
        }
    }
    
    private func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
    }
    @IBAction func txtDateOfBirthAction(_ sender: ACFloatingTextfield) {
        
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.pickupdateMethod(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func pickupdateMethod(_ sender: UIDatePicker)
    {
        let dateFormaterView = DateFormatter()
        dateFormaterView.dateFormat = "yyyy-MM-dd"
        
        txtDateOfBirth.text = dateFormaterView.string(from: sender.date)
    }
    
    @IBAction func btnChangePassword(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "ChangePasswordVC") as! ChangePasswordVC
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    @IBAction func btnSubmit(_ sender: UIButton) {

        if validation() {
            webserviceOfUpdateProfile()
        }
        
    }
    
    func validation() -> Bool {
        
        if imgProfile.image == UIImage(named: "iconProfileLocation") {
            UtilityClass.setCustomAlert(title: appName, message: "Please select profile picture") { (index, title) in
            }
            return false
        }
        if txtFirstName.text == "" {
            UtilityClass.setCustomAlert(title: appName, message: "Please enter first name") { (index, title) in
            }
            return false
        }
        if gender == "" {
            UtilityClass.setCustomAlert(title: appName, message: "Please select gender") { (index, title) in
            }
            return false
        }
        else if (strTMCardHolder == "1" && txtTMCardHolderText.text?.trimmingCharacters(in: .whitespacesAndNewlines).count == 0)
        {
            UtilityClass.setCustomAlert(title: appName, message: "Please choose TM Card Holder Number") { (index, title) in
            }
            return false
        }
        return true
        
    }
    
    @IBAction func btnUploadImage(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "Choose Image From", message: nil, preferredStyle: .actionSheet)
        
        let Camera = UIAlertAction(title: "Camera", style: .default, handler: { ACTION in
            
            self.PickingImageFromCamera()
        })
        
        let Gallery = UIAlertAction(title: "Gallery", style: .default, handler: { ACTION in
            
             self.PickingImageFromGallery()
        })
        
        let Cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(Camera)
        alert.addAction(Gallery)
        alert.addAction(Cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func PickingImageFromGallery()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        
        // picker.stopVideoCapture()
//        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        picker.mediaTypes = [kUTTypeImage as String]
        present(picker, animated: true, completion: nil)
    }
    
    func PickingImageFromCamera()
    {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        if let pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage {
            imgProfile.contentMode = .scaleToFill
            imgProfile.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
    func setData() {
        
        let getData = SingletonClass.sharedInstance.dictProfile
        
        if getData.count != 0 {
            
            imgProfile.sd_setShowActivityIndicatorView(true)
            imgProfile.sd_setIndicatorStyle(.gray)
            imgProfile.sd_setImage(with: URL(string: getData.object(forKey: "Image") as! String), completed: nil)
            
            lblEmailId.text = getData.object(forKey: "Email") as? String
            lblContactNumber.text = getData.object(forKey: "MobileNo") as? String
            txtDateOfBirth.text = getData.object(forKey: "DOB") as? String
            
            fullName = getData.object(forKey: "Fullname") as! String
            
            let fullNameArr = fullName.components(separatedBy: " ")
            
            firstName = fullNameArr[0]
            lastName = fullNameArr[1]
            
            txtFirstName.text = fullName
            //        txtLastName.text = lastName
            txtAddress.text = getData.object(forKey: "Address") as? String
            
            gender = getData.object(forKey: "Gender") as! String
            
            txtTMCardHolderText.text = getData.object(forKey: "TMCardHolderNumber") as? String ?? ""
            strTMCardHolder = getData.object(forKey: "TMCardHolder") as? String ?? ""
            
        }
        
        
        
        
        
        //        if gender == "male" || gender == "Male" {
        //            viewMale.checkState = .checked
        //            viewMale.tintColor = themeYellowColor
        //            viewFemale.checkState = .unchecked
        //        }
        //        else {
        //            viewMale.checkState = .unchecked
        //            viewFemale.tintColor = themeYellowColor
        //            viewFemale.checkState = .checked
        //        }
    }
    
//    @IBAction func viewMale(_ sender: M13Checkbox) {
        
//        viewMale.checkState = .checked
//        viewMale.tintColor = UIColor.init(red: 255/255, green: 163/255, blue: 0, alpha: 1.0)
//        viewFemale.checkState = .unchecked
//
//        gender = "Male"
        
//    }
    
//    @IBAction func viewFemale(_ sender: M13Checkbox) {
        
//        viewFemale.checkState = .checked
//        viewFemale.tintColor = themeYellowColor
//        viewMale.checkState = .unchecked
        
//        gender = "Female"
        
//    }
    
    @IBAction func btnBack(_ sender: UIButton) {
         self.navigationController?.popViewController(animated: true)
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    func webserviceOfUpdateProfile()
    {
        fullName = txtFirstName.text! //+ " " + txtLastName.text!
        
        var dictData = [String:AnyObject]()
        dictData["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        dictData["Fullname"] = fullName as AnyObject
        dictData["Gender"] = gender as AnyObject
        dictData["Address"] = txtAddress.text as AnyObject
        dictData["DOB"] = txtDateOfBirth.text as AnyObject
        dictData["TMCardHolder"] = strTMCardHolder as AnyObject
        if(strTMCardHolder == "0")
        {
            txtTMCardHolderText.text = ""
        }
        dictData["TMCardHolderNumber"] = txtTMCardHolderText.text?.trimmingCharacters(in: .whitespacesAndNewlines) as AnyObject
        let activityData = ActivityData()
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
        
        webserviceForUpdateProfile(dictData as AnyObject, image1: imgProfile.image!) { (result, status) in
            
            if (status) {
                
                NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                
                print(result)
                SingletonClass.sharedInstance.dictProfile = NSMutableDictionary(dictionary: (result as! NSDictionary).object(forKey: "profile") as! NSDictionary)
                
                UserDefaults.standard.set(SingletonClass.sharedInstance.dictProfile, forKey: "profileData")
                
               
                UtilityClass.setCustomAlert(title: appName, message: "Update Profile Successfully") { (index, title) in
                }
                
                NotificationCenter.default.post(name: Notification.Name("rating"), object: nil)
                
                
            }
            else {
                print(result)
            }
        }
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

//
//  RegistrationNewViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 26/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import ACFloatingTextfield_Swift
import TransitionButton

class RegistrationNewViewController: UIViewController, AKRadioButtonsControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
 
    
    
    var strDateOfBirth = String()

    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    var radioButtonsController: AKRadioButtonsController!
    @IBOutlet var radioButtons: [AKRadioButton]!
    @IBOutlet weak var txtFirstName: ACFloatingTextfield!
    @IBOutlet weak var txtLastName: ACFloatingTextfield!
    @IBOutlet weak var btnSignUp: TransitionButton!
    
    @IBOutlet weak var txtDateOfBirth: ACFloatingTextfield!
    @IBOutlet weak var txtRafarralCode: ACFloatingTextfield!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var constraintProfileImageAspecRatio: NSLayoutConstraint! // 82
    @IBOutlet weak var constraintTopOfBirthDate: NSLayoutConstraint!
    @IBOutlet weak var constaraintTopOfGender: NSLayoutConstraint!
    @IBOutlet weak var constraintTopOfReferralCode: NSLayoutConstraint!
    @IBOutlet weak var stackViewForFirstAndLastName: UIStackView!
    
    
    //-------------------------------------------------------------
    // MARK: - Global Declaration
    //-------------------------------------------------------------
    

    var strPhoneNumber = String()
    var strEmail = String()
    var strPassword = String()
    var gender = String()
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFirstName.delegate = self
        txtLastName.delegate = self
        
        if !(DeviceType.IS_IPHONE_5) {
            constraintProfileImageAspecRatio.constant = 110
            constraintTopOfBirthDate.constant = 20
            constaraintTopOfGender.constant = 30
            constraintTopOfReferralCode.constant = 10
            stackViewForFirstAndLastName.spacing = 20
            
        }
        

        // Do any additional setup after loading the view.
        
        self.radioButtonsController = AKRadioButtonsController(radioButtons: self.radioButtons)
        self.radioButtonsController.strokeColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        self.radioButtonsController.startGradColorForSelected = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)
        self.radioButtonsController.endGradColorForSelected = UIColor.init(red: 0, green: 0, blue: 0, alpha: 1)//UIColor.init(red: 255/255, green: 163/255, blue: 0, alpha: 1)
        self.radioButtonsController.selectedImage = UIImage(named: "iconRadioButtonSelected")
        self.radioButtonsController.standartImage = UIImage(named: "iconRadioButtonUnSelected")
        self.radioButtonsController.selectedIndex = 1
        self.radioButtonsController.delegate = self //class should implement AKRadioButtonsControllerDelegate
        gender = "male"
//        txtFirstName.text = "rahul"
//        txtLastName.text = "patel"
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.size.width/2
        self.imgProfile.layer.masksToBounds = true
        self.imgProfile.contentMode = .scaleAspectFill
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        btnSignUp.layer.cornerRadius = (btnSignUp.frame.size.height / 2)
        btnSignUp.giveShadowToBottomView(item: btnSignUp, shadowColor: themeYellowColor)
        
    }
    
    func selectedButton(sender: AKRadioButton) {

        print(sender.currentTitle!)
        
        switch sender.currentTitle! {
            
        case "Male":
            gender = "male"
        case "Female":
            gender = "female"
        default:
            gender = "male"
        }
        
    }
    
    // MARK: - Pick Image
     func TapToProfilePicture() {
        
        let alert = UIAlertController(title: "Choose Options", message: nil, preferredStyle: .actionSheet)
        
        let Gallery = UIAlertAction(title: "Gallery", style: .default, handler: { ACTION in
            self.PickingImageFromGallery()
        })
        let Camera  = UIAlertAction(title: "Camera", style: .default, handler: { ACTION in
            self.PickingImageFromCamera()
        })
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(Gallery)
        alert.addAction(Camera)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func PickingImageFromGallery()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
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
    
    // MARK: - Image Delegate and DataSource Methods

    
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
    
    @IBAction func txtDateOfBirth(_ sender: ACFloatingTextfield) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.maximumDate = Date()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.pickupdateMethod(_:)), for: UIControl.Event.valueChanged)
    }
    
    @objc func pickupdateMethod(_ sender: UIDatePicker)
    {
        let dateFormaterView = DateFormatter()
        dateFormaterView.dateFormat = "yyyy-MM-dd"
        txtDateOfBirth.text = dateFormaterView.string(from: sender.date)
        strDateOfBirth = txtDateOfBirth.text!
        
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == txtFirstName {
            txtFirstName.text = txtFirstName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        else if textField == txtLastName {
            txtLastName.text = txtLastName.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return true
    }
   
    
    //MARK: - Validation
    
    func checkValidation() -> Bool
    {
        if (txtFirstName.text?.count == 0)
        {

            UtilityClass.setCustomAlert(title: appName, message: "Please enter first name") { (index, title) in
            }
            return false
        }
        else if (txtLastName.text?.count == 0)
        {
            
            UtilityClass.setCustomAlert(title: appName, message: "Please enter last name") { (index, title) in
            }
            return false
        }
//        else if imgProfile.image == UIImage(named: "iconProfileLocation")
//        {
//
//            UtilityClass.setCustomAlert(title: appName, message: "Please choose profile picture") { (index, title) in
//            }
//            return false
//        }
        else if strDateOfBirth == "" {
           
            UtilityClass.setCustomAlert(title: appName, message: "Please choose date of birth") { (index, title) in
            }
            return false
        }
        else if gender == "" {
            
            UtilityClass.setCustomAlert(title: appName, message: "Please choose gender") { (index, title) in
            }
            return false
        }
        return true
    }
    
    
    //MARK: - IBActions
    
    @IBAction func btnChooseImage(_ sender: Any) {
        
        self.TapToProfilePicture()
    }
    
    @IBAction func btnSignUp(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet() {
            
            
            if (checkValidation())
            {
                let registerVC = (self.navigationController?.viewControllers.last as! RegistrationContainerViewController).children[0] as! RegisterViewController

                strPhoneNumber = (registerVC.txtPhoneNumber.text)!
                strEmail = (registerVC.txtEmail.text)!
                strPassword = (registerVC.txtPassword.text)!

                self.btnSignUp.startAnimation()
                
                webServiceCallForRegister()
            }
        }
        else {
            UtilityClass.setCustomAlert(title: InternetConnection.internetConnectionTitle, message: InternetConnection.internetConnectionMessage) { (index, msg) in
            }
        }
        
        
        
    }
    
    // MARK: - WebserviceCall
    
    func webServiceCallForRegister()
    {
//Email,MobileNo,Password,Gender,Firstname,Lastname,DOB,DeviceType,Token,Lat,Lng,ReferralCode,Image
        let dictParams = NSMutableDictionary()
        dictParams.setObject(txtFirstName.text!, forKey: "Firstname" as NSCopying)
        dictParams.setObject(txtLastName.text!, forKey: "Lastname" as NSCopying)
        dictParams.setObject(txtRafarralCode.text!, forKey: "ReferralCode" as NSCopying)
        dictParams.setObject(strPhoneNumber, forKey: "MobileNo" as NSCopying)
        dictParams.setObject(strEmail, forKey: "Email" as NSCopying)
        dictParams.setObject(strPassword, forKey: "Password" as NSCopying)
        
        if SingletonClass.sharedInstance.deviceToken == "" {
            dictParams.setObject("123456789", forKey: "Token" as NSCopying)
        }
        else {
            dictParams.setObject(SingletonClass.sharedInstance.deviceToken, forKey: "Token" as NSCopying)
        }
        
        dictParams.setObject("1", forKey: "DeviceType" as NSCopying)
        dictParams.setObject(gender, forKey: "Gender" as NSCopying)
        dictParams.setObject("12376152367", forKey: "Lat" as NSCopying)
        dictParams.setObject("2348273489", forKey: "Lng" as NSCopying)
        dictParams.setObject(strDateOfBirth, forKey: "DOB" as NSCopying)
        
        
        webserviceForRegistrationForUser(dictParams, image1: imgProfile.image!) { (result, status) in
            
            
            print(result)
            
            if ((result as! NSDictionary).object(forKey: "status") as! Int == 1)
            {
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.btnSignUp.stopAnimation(animationStyle: .normal, completion: {
                        
                        SingletonClass.sharedInstance.dictProfile = NSMutableDictionary(dictionary: (result as! NSDictionary).object(forKey: "profile") as! NSDictionary)   
                        SingletonClass.sharedInstance.isUserLoggedIN = true
                        SingletonClass.sharedInstance.strPassengerID = String(describing: SingletonClass.sharedInstance.dictProfile.object(forKey: "Id")!)
                        SingletonClass.sharedInstance.arrCarLists = NSMutableArray(array: (result as! NSDictionary).object(forKey: "car_class") as! NSArray)
                        UserDefaults.standard.set(SingletonClass.sharedInstance.arrCarLists, forKey: "carLists")

                        UserDefaults.standard.set(SingletonClass.sharedInstance.dictProfile, forKey: "profileData")
                        self.performSegue(withIdentifier: "segueToHomeVC", sender: nil)
                    })
                })
                
            }
            else
            {
                self.btnSignUp.stopAnimation(animationStyle: .shake, revertAfterDelay: 0, completion: {
                  
                    UtilityClass.setCustomAlert(title: appName, message: (result as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    }
                    
                })
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}

//
//  TickPayRegistrationViewController.swift
//  TiCKTOC-Driver
//
//  Created by Excellent Webworld on 20/12/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import FormTextField

class TickPayRegistrationViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CardIOPaymentViewControllerDelegate, UITextFieldDelegate {

    
    var creditCardValidator: CreditCardValidator!
    var validation = Validation()
    var inputValidator = InputValidator()
    
    var CardNumber = String()
    var strMonth = String()
    var strYear = String()
    var strCVV = String()
    
    var isCardDetailsAvailable = Bool()
    
   
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let PadingtxtCompanys = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        txtCompanysName.leftView = PadingtxtCompanys
        txtCompanysName.leftViewMode = .always
        
        let PadingtxtABN = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        txtABN.leftView = PadingtxtABN
        txtABN.leftViewMode = .always
        
        let PadingtxtAliasbank = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        txtAliasbank.leftView = PadingtxtAliasbank
        txtAliasbank.leftViewMode = .always
        
        

        if SingletonClass.sharedInstance.CardsVCHaveAryData.count != 0 {
            
            cardViewStack.isHidden = true
            constraintsHeightOFcardViewStack.constant = 0
        }

        
        giveCornerRadiousToAll()
        
        cardNum()
        cardCVV()
        cardExpiry()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
    
    func giveCornerRadiousToAll() {
        
        btnSignUp.layer.cornerRadius = 5
        btnSignUp.layer.masksToBounds = true
        
        UploadLicenceStackView.layer.cornerRadius = 5
        UploadLicenceStackView.layer.masksToBounds = true
//        btnImgCameras.layer.cornerRadius = 5
//        btnImgCameras.layer.masksToBounds = true
        btnLicence.layer.cornerRadius = 5
        btnLicence.layer.masksToBounds = true
  
        txtCompanysName.layer.cornerRadius = 5
        txtABN.layer.cornerRadius = 5
        txtCardNumbers.layer.cornerRadius = 5
        txtCvv.layer.cornerRadius = 5
        txtAliasbank.layer.cornerRadius = 5
        txtExpireyDate.layer.cornerRadius = 5
        
        txtCompanysName.layer.masksToBounds = true
        txtABN.layer.masksToBounds = true
        txtCardNumbers.layer.masksToBounds = true
        txtCvv.layer.masksToBounds = true
        txtAliasbank.layer.masksToBounds = true
        txtExpireyDate.layer.masksToBounds = true
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    @IBOutlet weak var UploadLicenceStackView: UIView!
    @IBOutlet weak var btnLicence: UIButton!
   
    @IBOutlet var txtExpireyDate: FormTextField!
    @IBOutlet var txtCompanysName: UITextField!
    @IBOutlet var txtABN: UITextField!
    @IBOutlet var txtCardNumbers: FormTextField!
    @IBOutlet var txtCvv: FormTextField!
    @IBOutlet var txtAliasbank: UITextField!
    @IBOutlet var btnImgCameras: UIButton!
    
    @IBOutlet weak var cardViewStack: UIStackView!
    
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var constraintsHeightOFcardViewStack: NSLayoutConstraint! // 325
    
    @IBOutlet var textFieldsAry: [UITextField]!
    

    
    //MARK:- IBActions
    
    
    @IBAction func btnBackToNavigate(_ sender: UIButton) {
        
        for vc in (self.navigationController?.viewControllers ?? []) {
            if vc is CustomSideMenuViewController {
                _ = self.navigationController?.popToViewController(vc, animated: true)
                break
            }
        }
    }
    
    
    @IBAction func btnSignUPs(_ sender: UIButton) {
 
        if SingletonClass.sharedInstance.CardsVCHaveAryData.count != 0 {
            if(validations())
            {
                webserviceOfVarifyPassenger()
            }
        }
        else {
            if (validationIfCardsNotAvailable()) && (validations()) {
                webserviceOfVarifyPassenger()
            }
        }
 
    }
    
    @IBAction func btnScanCards(_ sender: UIButton) {
        
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.modalPresentationStyle = .formSheet
        present(cardIOVC!, animated: true, completion: nil)
    }
    
    @IBAction func btnUploadDrivingLicences(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose Options", message: nil, preferredStyle: .alert)
        
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
    
    func validations() -> Bool {
        
//        CardNo,Cvv,Expiry,Alias,CompanyName,ABN(optional),Image
        
        if(txtCompanysName.text?.count == 0)
        {
            UtilityClass.showAlert("", message: "Please Insert Company Name", vc: self)
            return false
        }
        
        else if(btnImgCameras.imageView?.image == nil)
        {
            UtilityClass.showAlert("", message: "Please Driving Licence Image", vc: self)
            return false
        }
        
        return true
    }
    
    func validationIfCardsNotAvailable() -> Bool {
        
        if(txtCvv.text?.count == 0)
        {
            UtilityClass.showAlert("", message: "Please Insert CVV Number", vc: self)
            return false
        }
        else if(txtCardNumbers.text?.count == 0)
        {
            UtilityClass.showAlert("", message: "Please Insert Card Number", vc: self)
            return false
        }
        else if(txtExpireyDate.text?.count == 0)
        {
            UtilityClass.showAlert("", message: "Please Insert Expiry Date", vc: self)
            return false
        }
        else if(txtAliasbank.text?.count == 0)
        {
            UtilityClass.showAlert("", message: "Please Insert Alias", vc: self)
            return false
        }
        
        
        return true
    }
    
    
    //MARK:- Image picker Delegate
    
    
    func PickingImageFromGallery()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        
        // picker.stopVideoCapture()
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.btnImgCameras.setImage(pickedImage, for: .normal)
            self.btnImgCameras.imageView?.contentMode = .scaleAspectFit
//            imgVehicle.contentMode = .scaleToFill
//            imgVehicle.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //-------------------------------------------------------------
    // MARK: - Scan Card Methods
    //-------------------------------------------------------------
    
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        
        print("CardInfo : \(cardInfo)")
        
        if let info = cardInfo {
            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            //            resultLabel.text = str as String
            
            print("Card Number : \(info.cardNumber)")
            print("Redacted Card Number : \(customStringFormatting(of: info.redactedCardNumber))")
            print("Month : \(info.expiryMonth)")
            print("Year : \(info.expiryYear)")
            print("CVV : \(info.cvv)")
            
            var years = String(info.expiryYear)
            years.removeFirst(2)
            //            customStringFormatting(of: info.redactedCardNumber)
            
            print("Removed Year : \(years)")
            
            txtCardNumbers.text = customStringFormatting(of: info.redactedCardNumber)
            txtExpireyDate.text = "\(info.expiryMonth)/\(years)"
            txtCvv.text = info.cvv
            
            CardNumber = String(info.cardNumber)
            strMonth = String(info.expiryMonth)
            strYear = String(years)
            strCVV = String(info.cvv)
            
        }
        paymentViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        //        resultLabel.text = "user canceled"
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            //            resultLabel.text = str as String
            txtCardNumbers.text = info.redactedCardNumber
            txtExpireyDate.text = "\(info.expiryMonth)/\(info.expiryYear)"
        }
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func customStringFormatting(of str: String) -> String {
        return str.characters.chunk(n: 4)
            .map{ String($0) }.joined(separator: " ")
        
    }
    
    
    func cardNum() {
        txtCardNumbers.inputType = .integer
        txtCardNumbers.formatter = CardNumberFormatter()
        txtCardNumbers.enabledBackgroundColor = UIColor.white
        txtCardNumbers.activeBackgroundColor = UIColor.white
        txtCardNumbers.inactiveBackgroundColor = UIColor.white
        txtCardNumbers.disabledBackgroundColor = UIColor.white
        txtCardNumbers.placeholder = "Card Number"
        txtCardNumbers.backgroundColor = UIColor.white

        validation.maximumLength = 19
        validation.minimumLength = 14
        let characterSet = NSMutableCharacterSet.decimalDigit()
        characterSet.addCharacters(in: " ")
        validation.characterSet = characterSet as CharacterSet
        inputValidator = InputValidator(validation: validation)
        
        txtCardNumbers.inputValidator = inputValidator
    }
    
    func cardExpiry() {
        txtExpireyDate.inputType = .integer
        txtExpireyDate.formatter = CardExpirationDateFormatter()
        txtExpireyDate.enabledBackgroundColor = UIColor.white
        txtExpireyDate.activeBackgroundColor = UIColor.white
        txtExpireyDate.inactiveBackgroundColor = UIColor.white
        txtExpireyDate.disabledBackgroundColor = UIColor.white
        txtExpireyDate.placeholder = "Expiration Date (MM/YY)"
        txtExpireyDate.backgroundColor = UIColor.white
        
        //        var validation = Validation()
        validation.minimumLength = 1
        let inputValidator = CardExpirationDateInputValidator(validation: validation)
        txtExpireyDate.inputValidator = inputValidator
        
        
        print("")
        
    }
    
    func cardCVV() {
        
        txtCvv.inputType = .integer
        txtCvv.placeholder = "CVC"
        txtCvv.backgroundColor = UIColor.white
        txtCvv.enabledBackgroundColor = UIColor.white
        txtCvv.activeBackgroundColor = UIColor.white
        txtCvv.inactiveBackgroundColor = UIColor.white
        txtCvv.disabledBackgroundColor = UIColor.white
        
        //        var validation = Validation()
        validation.maximumLength = 3
        validation.minimumLength = 3
        validation.characterSet = NSCharacterSet.decimalDigits
        let inputValidator = InputValidator(validation: validation)
        txtCvv.inputValidator = inputValidator
        
        print("txtCVV.text : \(txtCvv.text)")
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    func webserviceOfVarifyPassenger() {
//        PassengerId,CardNo,Cvv,Expiry,Alias,CompanyName,ABN(optional),Image
        
        var param = Dictionary<String,AnyObject>()
        param["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
       
        param["CompanyName"] = txtCompanysName.text as AnyObject
        param["ABN"] = txtABN.text as AnyObject
        
        if SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0 {
      
            if CardNumber.count != 0 {
                param["CardNo"] = CardNumber as AnyObject
            }
            else {
                param["CardNo"] = (txtCardNumbers.text!).replacingOccurrences(of: " ", with: "") as AnyObject
            }
            if strCVV.count != 0 {
                param["Cvv"] = strCVV as AnyObject
            }
            else {
                param["Cvv"] = txtCvv.text! as AnyObject
            }
          
            if strMonth.count != 0 && strYear.count != 0 {
                param["Expiry"] = "\(strMonth)/\(strYear)" as AnyObject
            }
            else {
                param["Expiry"] = txtExpireyDate.text as AnyObject
            }
        
            param["Alias"] = txtAliasbank.text as AnyObject
        }
        
        
        webserviceForVarifyPassenger(param, image1: (btnImgCameras.imageView?.image)!) { (result, status) in
            
            if (status) {
                print(result)
                if let res = result as? NSDictionary {
                
                    let alert = UIAlertController(title: nil, message: "TickPay register successfully.", preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default, handler: { ACTION in
                        
                        let next = self.storyboard?.instantiateViewController(withIdentifier: "TiCKPayNeedToVarifyViewController") as! TiCKPayNeedToVarifyViewController
                        next.strMSG = res.object(forKey: "message") as! String
                        self.navigationController?.pushViewController(next, animated: true)
                    })
                    alert.addAction(OK)
                    self.present(alert, animated: true, completion: nil)
                    
                }
            }
            else {
                print(result)
                
                if let res = result as? String {
                    UtilityClass.showAlert("", message: res, vc: self)
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.showAlert("", message: resDict.object(forKey: "message") as! String, vc: self)
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.showAlert("", message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)
                }
            }
        }
    }
    
  

}
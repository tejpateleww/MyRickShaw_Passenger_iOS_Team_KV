//
//  WalletTransferViewController.swift
//  TiCKTOC-Driver
//
//  Created by Excelent iMac on 23/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import AVFoundation
import SDWebImage

class WalletTransferViewController: ParentViewController, UITextFieldDelegate {

   
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        CustomCameraVC = imagePicker
//        viewQRCodeScanner = imagePicker.view

        scrollObj.isScrollEnabled = false
        
        btnSubmitMoney.layer.cornerRadius = 5
        btnSubmitMoney.layer.masksToBounds = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         
         
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var scrollObj: UIScrollView!
    @IBOutlet weak var btnSendMoney: UIButton!
    @IBOutlet weak var viewEnterMoney: UIView!
    
    @IBOutlet weak var btnSubmitMoney: UIButton!
    
    
    
    @IBAction func btnSendMoney(_ sender: UIButton) {
        
        viewEnterMoney.isHidden = true
        
        scrollObj.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        
    }
    
    
    @IBAction func btnReceiveMoney(_ sender: UIButton) {
        
        viewEnterMoney.isHidden = true
        
        scrollObj.setContentOffset(CGPoint(x: self.view.frame.size.width, y: 0), animated: true)
        
    }
    
    @IBAction func btnSendBankAccount(_ sender: UIButton) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletTransferToBankVC") as! WalletTransferToBankVC
        self.navigationController?.pushViewController(next, animated: true)
        
    }
    
    

    
}
// ----------------------------------------------------------------------

// ----------------------------------------------------------------------


//-------------------------------------------------------------
// MARK: - Send Money
//-------------------------------------------------------------

class WalletTransferSend: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var amount = String()
    
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var isReading: Bool = false
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.lblQRScanner.isHidden = false
        lblFullName.isHidden = true
        lblMobileNumber.isHidden = true
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(self, selector: #selector(self.isSendMoneySucessfully), name: Notification.Name("isSendMoneySucessfully"), object: nil)
        
//        self.lblQRScanner.isHidden = false
        lblFullName.isHidden = true
        lblMobileNumber.isHidden = true

        captureSession = nil
//        startStopClick()
    }
    
    @objc func isSendMoneySucessfully() {
//        self.lblQRScanner.isHidden = false
        lblFullName.isHidden = true
        lblMobileNumber.isHidden = true
        
        captureSession = nil
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    @IBOutlet weak var viewQRCodeScanner: UIView!
    @IBOutlet weak var lblFullName: UILabel!
    @IBOutlet weak var lblMobileNumber: UILabel!
    @IBOutlet weak var imgQRCode: UIImageView!
    @IBOutlet weak var lblQRScanner: UILabel!
    @IBOutlet weak var txtEnterMoney: UITextField!
    
    @IBOutlet weak var txtSendMoney: UITextField!
    
    
    //-------------------------------------------------------------
    // MARK: - Action
    //-------------------------------------------------------------
    
    @IBAction func btnOpenCameraForQRCode(_ sender: UIBarButtonItem) {
        
        startStopClick()
        
        if SingletonClass.sharedInstance.isSendMoneySuccessFully {
            
        }
    }
    
    @IBAction func btnSendAndTransferMoney(_ sender: UIButton) {
        
        if SingletonClass.sharedInstance.strQRCodeForSendMoney != "" && amount != "" {
            let currrentBalance = SingletonClass.sharedInstance.strCurrentBalance
            let enterdAmount = (amount as NSString).doubleValue
            
            print("enterdAmount : \(enterdAmount)")
            print("currrentBalance : \(currrentBalance)")
            
            if enterdAmount > currrentBalance {
                
                UtilityClass.setCustomAlert(title: appName, message: "You have insufficient balance.") { (index, title) in
                }
            }
            else {
                    self.webserviceOfSendMoney()
            }
        }
        else if SingletonClass.sharedInstance.strQRCodeForSendMoney == "" {
            
            UtilityClass.setCustomAlert(title: appName, message: "Please Scan QR Code") { (index, title) in
            }
        }
        else if txtSendMoney.text!.count == 0 {
            
            UtilityClass.setCustomAlert(title: appName, message: "Please enter amount") { (index, title) in
            }
        }
        else {
            
            UtilityClass.setCustomAlert(title: appName, message: "Please enter amount") { (index, title) in
            }
        }
    }
    
    @IBAction func txtEnterForTransferMoney(_ sender: UITextField) {
        
        if let amountString = txtSendMoney.text?.currencyInputFormatting() {
            txtSendMoney.text = amountString
            
            
            let unfiltered = amountString   //  "!   !! yuahl! !"
            
            
            let space = " "
            let comma = " "
            let currencySymboleInString = "\(currencySign),\(comma),\(space)"
            let currencySymboleInCharacter = [Character](currencySymboleInString)
            
            
            // Array of Characters to remove
            let removal: [Character] = currencySymboleInCharacter    // ["!"," "]
            
            
            
            // Array of Characters to remove
            //            let removal: [Character] = ["$",","," "]    // ["!"," "]
            
            // turn the string into an Array
            let unfilteredCharacters = unfiltered.characters
            
            // return an Array without the removal Characters
            let filteredCharacters = unfilteredCharacters.filter { !removal.contains($0) }
            
            // build a String with the filtered Array
            let filtered = String(filteredCharacters)
            
            print(filtered) // => "yeah"
            
            // combined to a single line
            print(String(unfiltered.characters.filter { !removal.contains($0) })) // => "yuahl"
            
            amount = String(unfiltered.characters.filter { !removal.contains($0) })
            print("amount : \(amount)")
            
            print("QRCode : \(SingletonClass.sharedInstance.strQRCodeForSendMoney)")
            
        }
        
    }
  
    
    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func startStopClick() {
        
        if !isReading {
            if (self.startReading()) {
//                btnStartStop.setTitle("Stop", for: .normal)
//                lblQRScanner.text = "Scanning for QR Code..."
            }
        }
        else {
            stopReading()
//            btnStartStop.setTitle("Start", for: .normal)
        }
        isReading = !isReading
    }
    
    func startReading() -> Bool {
//        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let captureDevice = AVCaptureDevice.default(for: .video)
        
//        let captureDevice = AVCaptureDevice.default(for: .video)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            // Do the rest of your work...
        } catch let error as NSError {
            // Handle any errors
            print(error)
            return false
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = viewQRCodeScanner.layer.bounds
        viewQRCodeScanner.layer.addSublayer(videoPreviewLayer)
        
        /* Check for metadata */
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession?.addOutput(captureMetadataOutput)
        captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes
        print(captureMetadataOutput.availableMetadataObjectTypes)
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureSession?.startRunning()
        
        return true
    }
    
    @objc func stopReading() {
        
        captureSession?.stopRunning()
        captureSession = nil
        videoPreviewLayer.removeFromSuperlayer()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for data in metadataObjects {
            let metaData = data
            print(metaData.description)
            let transformed = videoPreviewLayer?.transformedMetadataObject(for: metaData) as? AVMetadataMachineReadableCodeObject
            if let unwraped = transformed {
                print(unwraped.stringValue!)
                
                
                SingletonClass.sharedInstance.strQRCodeForSendMoney = unwraped.stringValue!
                
                print("Singletons.sharedInstance.strQRCodeForSendMoney  ::  \(SingletonClass.sharedInstance.strQRCodeForSendMoney)")
                
                self.webserviceOfQRCodeDetails()
                
//                lblQRScanner.text = unwraped.stringValue
//                btnStartStop.setTitle("Start", for: .normal)
                self.performSelector(onMainThread: #selector(stopReading), with: nil, waitUntilDone: false)
                isReading = false;
            }
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    func webserviceOfSendMoney() {
        // QRCode,SenderId,Amount
        
        
        var dictParam = [String:AnyObject]()
        
        //        amount.removeFirst()
        
        dictParam["Amount"] = amount.trimmingCharacters(in: .whitespacesAndNewlines) as AnyObject
        dictParam["QRCode"] = SingletonClass.sharedInstance.strQRCodeForSendMoney as AnyObject
        dictParam["SenderId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        
        print("dictParam : \(dictParam)")
        
        webserviceForSendMoney(dictParam as AnyObject) { (result, status) in
            
            if (status) {
                print(result)
                
                if let res = result as? String {
                    
                    UtilityClass.setCustomAlert(title: "Done", message: res) { (index, title) in
                    }
                }
                else {
                    
                    SingletonClass.sharedInstance.strCurrentBalance = ((result as! NSDictionary).object(forKey: "walletBalance") as AnyObject).doubleValue
                    
                    self.txtSendMoney.text = ""
                    
                    NotificationCenter.default.post(name: Notification.Name("isSendMoneySucessfully"), object: nil)
                    
                    SingletonClass.sharedInstance.isSendMoneySuccessFully = true
                    
                    UtilityClass.setCustomAlert(title: "Transaction", message: (result as! NSDictionary).object(forKey: "message")! as! String) { (index, title) in
                    }
                    
                }
                
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
 
    func webserviceOfQRCodeDetails() {
        
        var param = [String:AnyObject]()
        param["QRCode"] = SingletonClass.sharedInstance.strQRCodeForSendMoney as AnyObject
 
        webserviceForGetQRCodeDetails(param as AnyObject) { (result, status) in
        
            if (status) {
                print(result)
                
//                self.lblQRScanner.isHidden = true
                self.lblFullName.isHidden = false
                self.lblMobileNumber.isHidden = false
                
                let Fullname = "Name: \(((result as! NSDictionary).object(forKey: "data") as! NSDictionary).object(forKey: "Fullname") as! String)"
                let MobileNo = "Mobile No.: \(((result as! NSDictionary).object(forKey: "data") as! NSDictionary).object(forKey: "MobileNo") as! String)"
                _ = ((result as! NSDictionary).object(forKey: "data") as! NSDictionary).object(forKey: "Id") as! String
                _ = ((result as! NSDictionary).object(forKey: "data") as! NSDictionary).object(forKey: "QRCode") as! String
                
                self.lblFullName.text = Fullname
                self.lblMobileNumber.text = MobileNo
                self.imgQRCode.isHidden = true
                
/*                {
                    data =     {
                        Fullname = "developer eww";
                        Id = 19;
                        MobileNo = 9998359464;
                        QRCode = "jsbS2dDmzpxqa2tdiaKXoag=";
                    };
                    status = 1;
                }
*/
            }
            else {
                print(result)
                
//                self.lblQRScanner.isHidden = false
                self.lblFullName.isHidden = true
                self.lblMobileNumber.isHidden = true
            }
        }

    }
 
}
// ----------------------------------------------------------------------

//-------------------------------------------------------------
// MARK: - Receive Money
//-------------------------------------------------------------

class WalletTransferRecieve: UIViewController {
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setImage()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var imgQRCode: UIImageView!
    
    
    //-------------------------------------------------------------
    // MARK: - Custom Method
    //-------------------------------------------------------------
    
    func setImage() {

        let profileData = SingletonClass.sharedInstance.dictProfile
        if let QRCodeImage = (profileData).object(forKey: "QRCode") as? String {
            let baseURL = QRCodeImage
            imgQRCode.sd_setImage(with: URL(string: baseURL), completed: nil)
        }
 
    }
    
}





//
//  EditProfileViewController.swift
//  TickTok User
//
//  Created by Excelent iMac on 23/12/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {

    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (DeviceType.IS_IPHONE_X) {
            constraintOfNavigationViewHeight.constant = 88
        }

        viewEditProfile.layer.cornerRadius = 10
        viewEditProfile.layer.masksToBounds = true
        
        viewAccount.layer.cornerRadius = 10
        viewAccount.layer.masksToBounds = true
       
//        self.ConstraintEditProfileX.constant = self.view.frame.origin.x - viewEditProfile.frame.size.width - 20
//        self.constraintAccountTailing.constant = -(viewEditProfile.frame.size.width + 20)
//
        
//        AnimationToView()

        setImageColor()
        
        iconProfile.image = setImageColorOfImage(name: "iconEditProfile")
        iconAccount.image = setImageColorOfImage(name: "iconAccount")
       
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

//        ConstraintEditProfileX.constant = -(self.view.frame.size.width)
//        constraintAccountTailing.constant = -(self.view.frame.size.width)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        AnimationToView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
    
    func setImageColor() {
        
        let img = UIImage(named: "iconArrowGrey")
        imgArrowProfile.image = img?.maskWithColor(color: UIColor.white)
        imgArrowAccount.image = img?.maskWithColor(color: UIColor.white)
    }
    
    func setImageColorOfImage(name: String) -> UIImage {
        
        var imageView = UIImageView()
        
        let img = UIImage(named: name)
        imageView.image = img?.maskWithColor(color: UIColor.white)
       
        
        return imageView.image!
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var viewEditProfile: UIView!
    @IBOutlet weak var viewAccount: UIView!
    
    @IBOutlet weak var imgArrowProfile: UIImageView!
    @IBOutlet weak var imgArrowAccount: UIImageView!
    
    @IBOutlet weak var ConstraintEditProfileX: NSLayoutConstraint!
    @IBOutlet weak var constraintAccountTailing: NSLayoutConstraint!
    
    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var iconProfile: UIImageView!
    @IBOutlet weak var iconAccount: UIImageView!
    
    @IBOutlet weak var constraintOfNavigationViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblProfileTitle: UILabel!
    @IBOutlet weak var lblProfile: UILabel!
    @IBOutlet weak var lblAccount: UILabel!
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
//        AnimationToView()
        
        print("Back Button Clicked")
        
        
    }
    
    @IBAction func btnEditProfile(_ sender: UIButton) {
        
    }
    
    @IBAction func btnEditAccount(_ sender: UIButton) {
        
    }
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
    func AnimationToView() {

        self.ConstraintEditProfileX.constant = self.view.frame.origin.x - viewEditProfile.frame.size.width - 20
        self.constraintAccountTailing.constant = -(viewEditProfile.frame.size.width + 20)
        
        self.viewMain.layoutIfNeeded()
        
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseIn, animations: {

            
            self.ConstraintEditProfileX.constant = 20
            self.constraintAccountTailing.constant = 20
            
            self.viewMain.layoutIfNeeded()
            
            
        }, completion: { finished in
            
        })
        
        
    }
    

}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

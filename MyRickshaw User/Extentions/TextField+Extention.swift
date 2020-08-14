//
//  TextField+Extention.swift
//  MyRickshaw User
//
//  Created by Apple on 19/11/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation


extension UITextField: UITextFieldDelegate {
    
    func checkForTrimm(txtField: UITextField) {
    
        func textFieldDidBeginEditing(_ textField: UITextField) {
            
            txtField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            txtField.text = txtField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
   
}


//func textFieldTrimming(vc: UIViewController, textField: UITextField) {
//
//
//
//}

class textFieldTrimmingViewController: UIViewController, UITextFieldDelegate {
    
 
    
}

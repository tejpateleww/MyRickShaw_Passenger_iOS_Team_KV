//
//  GoogleMapMarkerInfoView.swift
//  MyRickshaw User
//
//  Created by Excelent iMac on 28/06/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit


protocol MapMarkerDelegate: class {
    func didTapInfoButton(data: NSDictionary)
}

class GoogleMapMarkerInfoView: UIView {

    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    @IBOutlet weak var lblCurrentAddress: UILabel!
    @IBOutlet weak var lblMinutesInDigits: UILabel!
    @IBOutlet weak var lblMinutesInString: UILabel!
    
    @IBOutlet weak var viewMain: UIView!
    
    //-------------------------------------------------------------
    // MARK: - Global Declaration
    //-------------------------------------------------------------
    
    weak var delegate: MapMarkerDelegate?
    var spotData: NSDictionary?
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "GoogleMapMarkerInfoView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
    
    @IBAction func didTapInfoButton(_ sender: UIButton) {
        delegate?.didTapInfoButton(data: spotData!)
    }
    
    
    
   
}

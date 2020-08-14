//
//  FlatRateTableViewCell.swift
//  MyRickshaw User
//
//  Created by Apple on 29/10/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

class FlatRateTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if lblFlateRateFare != nil {
            lblFlateRateFare.layer.cornerRadius = 5
            lblFlateRateFare.layer.masksToBounds = true
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBOutlet weak var lblPickupLocation: UILabel!
    @IBOutlet weak var lblDropOffLocation: UILabel!    
    @IBOutlet weak var lblFlateRateFare: UILabel!
    
    
    /// set data of Flat Rate
    func setDataOnFlatRate(dict: [String:Any]) {
        
        self.lblPickupLocation.text = dict["PickupLocation"] as? String
        self.lblDropOffLocation.text = dict["DropoffLocation"] as? String
        self.lblFlateRateFare.text = "\(currencySign)\(dict["Price"] as? String ?? "00.00")"
    }
    
}

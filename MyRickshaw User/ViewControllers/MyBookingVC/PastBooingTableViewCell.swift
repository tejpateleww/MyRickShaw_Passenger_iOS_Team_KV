//
//  PastBooingTableViewCell.swift
//  TickTok User
//
//  Created by Excellent Webworld on 09/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class PastBooingTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------

    
    @IBOutlet weak var viewDetails: UIView!
    
  
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblBookingID: UILabel!
    

    @IBOutlet weak var lblDropoffAddress: UILabel!  // DropOff Address is PickupAddress
    

    @IBOutlet weak var lblDateAndTime: UILabel!
    

    @IBOutlet weak var lblPickupAddress: UILabel! // Pickup Address is PickupAddress
    
    @IBOutlet weak var stackViewPickupTime: UIStackView!
    @IBOutlet weak var lblPickupTime: UILabel!

    @IBOutlet weak var stackViewDropoffTime: UIStackView!
    @IBOutlet weak var lblDropoffTime: UILabel!
    
    @IBOutlet weak var stackViewVehicleType: UIStackView!
    @IBOutlet weak var lblVehicleType: UILabel!
    
    @IBOutlet var lblNoOfPassenger: UILabel!
    @IBOutlet var lblNoOfLuggage: UILabel!
    @IBOutlet var lblDistanceFare: UILabel!
    @IBOutlet var lblSoilageCharge: UILabel!
    @IBOutlet var lblLoadingCharge: UILabel!
    @IBOutlet var lblFlagFallFee: UILabel!
    @IBOutlet var lblTripStatus: UILabel!
    
    
    @IBOutlet weak var stackViewDistanceTravelled: UIStackView!
    @IBOutlet weak var lblDistanceTravelled: UILabel!
    
    @IBOutlet weak var stackViewTripFare: UIStackView!
    @IBOutlet weak var lblTripFare: UILabel!
    
    @IBOutlet weak var stackViewNightFare: UIStackView!
    @IBOutlet weak var lblNightFare: UILabel!
    
    @IBOutlet weak var stackViewTollFee: UIStackView!
    @IBOutlet weak var lblTollFee: UILabel!
    
    @IBOutlet weak var stackViewWaitingCost: UIStackView!
    @IBOutlet weak var lblWaitingCost: UILabel!
    @IBOutlet weak var lblWaitingTime: UILabel!
    
    @IBOutlet weak var stackViewBookingCharge: UIStackView!
    @IBOutlet weak var lblBookingCharge: UILabel!
    
    @IBOutlet weak var stackViewTax: UIStackView!
    @IBOutlet weak var lblTax: UILabel!
    
    @IBOutlet weak var stackViewDiscount: UIStackView!
    @IBOutlet weak var lblDiscount: UILabel!
    
    @IBOutlet weak var stackViewPaymentType: UIStackView!
    @IBOutlet weak var lblPaymentType: UILabel!
    
    @IBOutlet weak var stackViewTotalCost: UIStackView!
    @IBOutlet weak var lblTotalCost: UILabel!
   
}

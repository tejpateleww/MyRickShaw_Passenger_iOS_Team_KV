//
//  ContentTableViewCell.swift
//  TickTok User
//
//  Created by Excellent Webworld on 26/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class ContentTableViewCell: UITableViewCell {

    @IBOutlet weak var imgDetail: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    @IBOutlet weak var viewUnderLineOfImage: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        imgDetail?.image = UIImage(named: "\(arrMenuIcons[indexPath.row])Selected")
        self.lblTitle.highlightedTextColor = UIColor.init(red: 249/255, green: 179/255, blue: 48/255, alpha: 1.0)
//        self.viewUnderLineOfImage.hi = UIColor.init(red: 249/255, green: 179/255, blue: 48/255, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

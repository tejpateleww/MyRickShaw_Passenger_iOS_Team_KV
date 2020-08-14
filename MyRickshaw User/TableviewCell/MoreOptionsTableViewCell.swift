//
//  MoreOptionsTableViewCell.swift
//  MyRickshaw User
//
//  Created by Excelent iMac on 02/08/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import UIKit

class MoreOptionsTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var lblCarModelName: UILabel!
    @IBOutlet weak var imgCarModelSelectedOrNot: UIImageView!
    

}

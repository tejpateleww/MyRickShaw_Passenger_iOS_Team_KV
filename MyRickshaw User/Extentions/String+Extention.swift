//
//  String+Extention.swift
//  MyRickshaw User
//
//  Created by Apple on 19/11/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation



extension String
{
    
    /// Remove first and last space from string and textFirld
    func trimFirstAndLastSpace() -> String
    {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}


extension String
{
    func onlyDateToString(dateFormat format  : String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: self)
        {
            dateFormatter.dateFormat = "dd-MM-yyyy"
            // again convert your date to string
            let myStringafd = dateFormatter.string(from: date)
            return myStringafd
        }
        
        return ""
    }
    
    func onlyTimeToString(dateFormat format  : String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: self)
        {
            dateFormatter.dateFormat = "hh:mm:ss"
            // again convert your date to string
            let myStringafd = dateFormatter.string(from: date)
            return myStringafd
        }
        
        return ""
    }
}

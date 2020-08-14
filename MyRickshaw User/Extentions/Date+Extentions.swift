//
//  Date+Extentions.swift
//  MyRickshaw User
//
//  Created by Apple on 02/11/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation

extension Date {
    
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var dayAfterTomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 2, to: toDay)!
    }
    var dayBeforeYesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -2, to: toDay)!
    }
    var toDay: Date {
        return Date()
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var currentMonth: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != currentMonth
    }
    var oneHourLater: Date {
        return Calendar.current.date(byAdding: .hour, value: 1, to: toDay)!
    }
    var oneHourBefore: Date {
        return Calendar.current.date(byAdding: .hour, value: -1, to: toDay)!
    }
}

//
//  ConstantData.swift
//  TickTok User
//
//  Created by Excellent Webworld on 28/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import Foundation

let themeYellowColor: UIColor = UIColor.init(red: 249/255, green: 188/255, blue: 54/255, alpha: 1.0)
let themeFontColor: UIColor = UIColor.white
let themeGrayColor: UIColor = UIColor.init(red: 114/255, green: 114/255, blue: 114/255, alpha: 1.0)
//let ThemeYellowColor : UIColor = UIColor.init(hex: "F9B330")

var aryCarListConstant = ["Max Van", "Waiheke Express", "Budget Taxi", "Car X4", "Van X6", "Van X9", "TM Card Holder (TM)", "Baby Seat (BS)", "Hoist Van (HV)"]
let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
let currencySign = "$"
let appName = "My Rickshaw"
let helpLineNumber = "911"

var aboutUs = String()

struct WebserviceURLs {
    
    
    static let kBaseURL                                 = "http://18.189.177.63/web/Passenger_Api/"//"http://rickshaw.co.nz/web/Passenger_Api/" // "http://52.14.34.50/web/Passenger_Api/"
    static let kInit                                    = "Init/"   // 1.0.1/AndroidPassenger
    static let kOtpForRegister                          = "OtpForRegister"
    static let kDriverRegister                          = "Register"
    static let kDriverLogin                             = "Login"
    static let kChangePassword                          = "ChangePassword"
    static let kUpdateProfile                           = "UpdateProfile"
    static let kForgotPassword                          = "ForgotPassword" 
    static let kDriver                                  = "Driver"
    static let kImageBaseURL                            = "http://18.189.177.63/web/"//"http://rickshaw.co.nz/web/" // "http://52.14.34.50/web/"
    
    
 

//    static let kBaseURL                                 = "http://54.169.67.226/web/Passenger_Api/"// "https://pickngolk.info/web/Passenger_Api/" // "http://54.255.222.125/web/Passenger_Api/" // "https://pickngolk.info/web/Passenger_Api/"
//    static let kDriverRegister                          = "Register"
//    static let kDriverLogin                             = "Login"
//    static let kChangePassword                          = "ChangePassword"
//    static let kUpdateProfile                           = "UpdateProfile"
//    static let kForgotPassword                          = "ForgotPassword"
    static let kGetCarList                              = "GetCarClass"
    static let kMakeBookingRequest                      = "SubmitBookingRequest"
    static let kAdvancedBooking                         = "AdvancedBooking"
//    static let kDriver                                  = "Driver"
    static let kBookingHistory                          = "BookingHistory/"
    static let kGetEstimateFare                         = "GetEstimateFare"
//    static let kImageBaseURL                            = "http://54.169.67.226/web/" // "https://pickngolk.info/web/" // "http://54.255.222.125/web/" // "https://pickngolk.info/web/"
    
    static let kCardsList                               = "Cards/"
    static let kPackageBookingHistory                   = "PackageBookingHistory"
    static let kBookPackage                             = "BookPackage"
    static let kCurrentBooking                          = "CurrentBooking/"
    static let kAddNewCard                              = "AddNewCard"
    static let kAddMoney                                = "AddMoney"
    static let kTransactionHistory                      = "TransactionHistory/"
    static let kSendMoney                               = "SendMoney"
    static let kQRCodeDetails                           = "QRCodeDetails"
    static let kRemoveCard                              = "RemoveCard/"
    static let kTickpay                                 = "Tickpay"
    static let kAddAddress                              = "AddAddress"
    static let kGetAddress                              = "GetAddress/"
    static let kRemoveAddress                           = "RemoveAddress/"
    static let kVarifyUser                              = "VarifyUser"
    static let kTickpayInvoice                          = "TickpayInvoice"
    static let kGetTickpayRate                          = "GetTickpayRate"
//    static let kInit                                    = "Init/"
    
    static let kReviewRating                            = "ReviewRating"
    static let kGetTickpayApprovalStatus                = "GetTickpayApprovalStatus/"
    static let kTransferToBank                          = "TransferToBank"
    static let kUpdateBankAccountDetails                = "UpdateBankAccountDetails"
//    static let kOtpForRegister                          = "OtpForRegister"
    static let kGetPackages                             = "Packages"
    static let kMissBokkingRequest                      = "BookingMissRequest"
    static let kTrackRunningTrip                        = "TrackRunningTrip/"

    static let kFlatRateList                            = "FlatRateList/"
    
    static let kChating                                 = "chat_history/"
    
    static let kPastBooking                             = "PastBooking/"
    static let kUpcomingBooking                         = "UpcomingBooking/"
    static let kOngoingBooking                          = "OngoingBooking/"
    static let kCreditAccountRequest                    = "CreditAccountRequest/"
    static let kPayCreditAccount                        = "CreditAccountPayment/"
    static let kCreditHistory                           = "CreditHistory/"
    static let kCreditAccountPaymentHistory             = "CreditAccountPaymentHistory/"
//    https://pickngolk.info/web/Passenger_Api/OtpForRegister
    
}

struct SocketData {
    
    static let kBaseURL                                     = "http://18.189.177.63:8080"//"http://52.14.34.50:8080" // "https://pickngolk.info:8081" // "http://54.255.222.125:8080/" // "https://pickngolk.info:8081"
    static let kNearByDriverList                            = "NearByDriverListIOS"
    static let kUpdatePassengerLatLong                      = "UpdatePassengerLatLong"
    static let kAcceptBookingRequestNotification            = "AcceptBookingRequestNotification"
    static let kRejectBookingRequestNotification            = "RejectBookingRequestNotification"
    static let kPickupPassengerNotification                 = "PickupPassengerNotification"
    static let kBookingCompletedNotification                = "BookingDetails"
    static let kCancelTripByPassenger                       = "CancelTripByPassenger"
    static let kCancelTripByDriverNotficication             = "PassengerCancelTripNotification"
    static let kSendDriverLocationRequestByPassenger        = "DriverLocation"
    static let kReceiveDriverLocationToPassenger            = "DriverLocationNew"
    static let kReceiveHoldingNotificationToPassenger       = "TripHoldNotification"
    static let kSendRequestForGetEstimateFare               = "EstimateFare"
    static let kReceiveGetEstimateFare                      = "GetEstimateFare"
    
    static let kAcceptAdvancedBookingRequestNotification    = "AcceptAdvancedBookingRequestNotification"
    static let kRejectAdvancedBookingRequestNotification    = "RejectAdvancedBookingRequestNotification"
    static let kAdvancedBookingPickupPassengerNotification  = "AdvancedBookingPickupPassengerNotification"
    static let kAdvancedBookingTripHoldNotification         = "AdvancedBookingTripHoldNotification"
    static let kAdvancedBookingDetails                      = "AdvancedBookingDetails"
    static let kAdvancedBookingCancelTripByPassenger        = "AdvancedBookingCancelTripByPassenger"
    
    static let kInformPassengerForAdvancedTrip              = "InformPassengerForAdvancedTrip"
    static let kAcceptAdvancedBookingRequestNotify          = "AcceptAdvancedBookingRequestNotify"
    
    static let kReceiveMessage                              = "receive_message"
    static let kSendMessage                                 = "send_message"
    
}

struct SocketDataKeys {
    
    static let kBookingIdNow    = "BookingId"
}

struct RegistrationData {
    static let kRegMobileNumber = "kRegMobileNumber"
    static let kRegEmail        = "kRegEmail"
    
   static let kPassword         = ""
    
//    Email,MobileNo,Password,Gender,Firstname,Lastname,DOB,DeviceType,Token,Lat,Lng,ReferralCode,Image
}



struct SubmitBookingRequest {
// PassengerId,ModelId,PickupLocation,DropoffLocation,PickupLat,PickupLng,DropOffLat,DropOffLon
// PassengerId,ModelId,PickupLocation,DropoffLocation,PickupLat,PickupLng,DropOffLat,DropOffLon,PromoCode,Notes,PaymentType,CardId(If paymentType is card)
    
    
    static let kModelId                 = "ModelId"
    static let kPickupLocation          = "PickupLocation"
    static let kDropoffLocation         = "DropoffLocation"
    static let kPickupLat               = "PickupLat"
    static let kPickupLng               = "PickupLng"
    static let kDropOffLat              = "DropOffLat"
    static let kDropOffLon              = "DropOffLon"
    
    static let kPromoCode               = "PromoCode"
    static let kNotes                   = "Notes"
    static let kPaymentType             = "PaymentType"
    static let kCardId                  = "CardId"
    static let kSpecial                 = "Special"
    
    static let kNoOfLuggage             = "NoOfLuggage"
    static let kNoOfPassenger           = "NoOfPassenger"
   
}

struct NotificationCenterName {
    
    // Define identifier
    static let keyForOnGoing   = "keyForOnGoing"
    static let keyForUpComming = "keyForUpComming"
    static let keyForPastBooking = "keyForPastBooking"
    

}

struct PassengerDataKeys {
    static let kPassengerID = "PassengerId"
    
}

struct setAllDevices {
    
    static let allDevicesStatusBarHeight = 20
    static let allDevicesNavigationBarHeight = 44
    static let allDevicesNavigationBarTop = 20
}

struct setiPhoneX {
    
    static let iPhoneXStatusBarHeight = 44
    static let iPhoneXNavigationBarHeight = 40
    static let iPhoneXNavigationBarTop = 44
    
    
}

struct InternetConnection {
   static let internetConnectionTitle = "No internet connection"
   static let internetConnectionMessage = "Please check your internet connection!"
}


struct ModelDataConstant {
    static let kLoginResponse = "LoginResponse"
}


let NotificationKeyFroAllDriver =  NSNotification.Name("NotificationKeyFroAllDriver")

let NotificationBookNow = NSNotification.Name("NotificationBookNow")
let NotificationBookLater = NSNotification.Name("NotificationBookLater")

let NotificationTrackRunningTrip = NSNotification.Name("NotificationTrackRunningTrip")
let NotificationForBookingNewTrip = NSNotification.Name("NotificationForBookingNewTrip")
let NotificationForAddNewBooingOnSideMenu = NSNotification.Name("NotificationForAddNewBooingOnSideMenu")

let NotificationgetResponseOfChatting = NSNotification.Name("NotificationgetResponseOfChatting")
let NotificationgetResponseOfChattingOfSpecificDriver = NSNotification.Name("NotificationgetResponseOfChattingOfSpecificDriver")


/// Convert Any data to String From Dictionary
func checkDictionaryHaveValue(dictData: [String:Any], didHaveValue paramString: String, isNotHave: String) -> String {
    
    var currentData = dictData
    
    if currentData[paramString] == nil {
        return isNotHave
    }
    
    if ((currentData[paramString] as? Int) != nil) {
        if String(currentData[paramString] as! Int) == "" {
            return isNotHave
        }
        return String((currentData[paramString] as! Int))
        
    } else if ((currentData[paramString] as? String) != nil) {
        if String(currentData[paramString] as! String) == "" {
            return isNotHave
        }
        return String(currentData[paramString] as! String)
        
    } else if ((currentData[paramString] as? Double) != nil) {
        if String(currentData[paramString] as! Double) == "" {
            return isNotHave
        }
        return String(currentData[paramString] as! Double)
        
    }
    else {
        return isNotHave
    }
}


//let NotificationHotelReservation = NSNotification.Name("NotificationHotelReservation")
//let NotificationBookaTable = NSNotification.Name("NotificationBookaTable")
//let NotificationShopping = NSNotification.Name("NotificationShopping")

//struct iPhoneDevices {
//    
//    static func getiPhoneXDevice() -> String {
//        
//        var deviceName = String()
//        
//        if UIDevice().userInterfaceIdiom == .phone {
//            switch UIScreen.main.nativeBounds.height {
//            case 1136:
//                print("iPhone 5 or 5S or 5C")
//                return deviceName = "iPhone 5"
//                
//            case 1334:
//                print("iPhone 6/6S/7/8")
//                deviceName = "iPhone 6"
//                
//            case 2208:
//                print("iPhone 6+/6S+/7+/8+")
//                deviceName = "iPhone 6+"
//                
//            case 2436:
//                print("iPhone X")
//                deviceName = "iPhone X"
//                
//            default:
//                print("unknown")
//            }
//        }
//    }
//}

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6_7        = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P_7P      = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    static let IS_IPAD_PRO          = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1366.0
}

struct Version
{
    static let SYS_VERSION_FLOAT = (UIDevice.current.systemVersion as NSString).floatValue
    static let iOS7 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
    static let iOS8 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
    static let iOS9 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
    static let iOS10 = (Version.SYS_VERSION_FLOAT >= 10.0 && Version.SYS_VERSION_FLOAT < 11.0)
    static let iOS11 = (Version.SYS_VERSION_FLOAT >= 11.0 && Version.SYS_VERSION_FLOAT < 12.0)
}



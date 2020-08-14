//
//  UtilityClass.swift
//  TickTok User
//
//  Created by Excellent Webworld on 27/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Alamofire

typealias CompletionHandler = (_ success:Bool) -> Void

class UtilityClass: NSObject, alertViewMethodsDelegates {
    
    var delegateOfAlert : alertViewMethodsDelegates!

    class func showAlert(_ title: String, message: String, vc: UIViewController) -> Void
    {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        let cancelAction = UIAlertAction(title: "OK",
                                         style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        
//        if((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.presentedViewController != nil)
//        {
//            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.dismiss(animated: true, completion: {
////                vc.present(alert, animated: true, completion: nil)
//                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
//            })
//        }
//        else {
        
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        
        
//            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
//        }
        
        
        //vc will be the view controller on which you will present your alert as you cannot use self because this method is static.
        
    }
    
    class func showAlertWithCompletion(_ title: String, message: String, vc: UIViewController,completionHandler: @escaping CompletionHandler) -> Void
    {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
//        if((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.presentedViewController != nil)
//        {
//            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.dismiss(animated: true, completion: {
//                //                vc.present(alert, animated: true, completion: nil)
//                (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
//            })
//        }
//        else {
        
            let alertWindow = UIWindow(frame: UIScreen.main.bounds)
            alertWindow.rootViewController = UIViewController()
            alertWindow.windowLevel = UIWindowLevelAlert + 1;
            alertWindow.makeKeyAndVisible()
            alertWindow.rootViewController?.present(alert, animated: true, completion: nil)
        
//            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
//        }

    }
    
    
    class func presentAlertVC(selfVC: UIViewController) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(selfVC, animated: true, completion: nil)
    }
    
    class func CustomAlertViewMethod(_ title: String, message: String, vc: UIViewController, completionHandler: @escaping CompletionHandler) -> Void {
        
        let next = vc.storyboard?.instantiateViewController(withIdentifier: "CustomAlertsViewController") as! CustomAlertsViewController
        
//        next.delegateOfAlertView = vc as! alertViewMethodsDelegates
        next.strTitle = title
        next.strMessage = message
        
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(next, animated: true, completion: nil)
        
        
//        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: false, completion: nil)
        
    }
    
    class func presentOverAlert(vc: UIViewController) {
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(vc, animated: true, completion: nil)
        
    }
    
    typealias alertCompletionBlockAJ = ((Int, String) -> Void)?
    
    class func setCustomAlert(title: String, message: String,completionHandler: alertCompletionBlockAJ) -> Void {
       
        AJAlertController.initialization().showAlertWithOkButton(aStrTitle: title, aStrMessage: message) { (index,title) in
            
            if index == 0 {
                completionHandler!(0,title)
            }
            else if index == 2 {
                completionHandler!(2,title)
            }
        }
    }
    
    /// Response may be Any Type
    class func showAlertOfAPIResponse(param: Any, vc: UIViewController) {
        
        if let res = param as? String {
            UtilityClass.showAlert(appName, message: res, vc: vc)
        }
        else if let resDict = param as? NSDictionary {
            if let msg = resDict.object(forKey: "message") as? String {
                UtilityClass.showAlert(appName, message: msg, vc: vc)
            }
            else if let msg = resDict.object(forKey: "msg") as? String {
                UtilityClass.showAlert(appName, message: msg, vc: vc)
            }
            else if let msg = resDict.object(forKey: "message") as? [String] {
                UtilityClass.showAlert(appName, message: msg.first ?? "", vc: vc)
            }
        }
        else if let resAry = param as? NSArray {
            
            if let dictIndxZero = resAry.firstObject as? NSDictionary {
                if let message = dictIndxZero.object(forKey: "message") as? String {
                    UtilityClass.showAlert(appName, message: message, vc: vc)
                }
                else if let msg = dictIndxZero.object(forKey: "msg") as? String {
                    UtilityClass.showAlert(appName, message: msg, vc: vc)
                }
                else if let msg = dictIndxZero.object(forKey: "message") as? [String] {
                    UtilityClass.showAlert(appName, message: msg.first ?? "", vc: vc)
                }
            }
            else if let msg = resAry as? [String] {
                UtilityClass.showAlert(appName, message: msg.first ?? "", vc: vc)
            }
        }
    }
    
    
//    convenience init(title: String, message: String, buttons buttonArray: [Any], completion block: @escaping (_ buttonIndex: Int) -> Void) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        for buttonTitle: String in buttonArray {
//            let action = UIAlertAction(title: buttonTitle, style: .default, handler: {(_ action: UIAlertAction) -> Void in
//                let index: Int = (buttonArray as NSArray).index(of: action.title ?? "")
//                block(index)
//            })
//            alertController.addAction(action)
//        }
//        self.topMostController().present(alertController, animated: true) {() -> Void in }
//    }
    
    class func showHUD()
    {
        let activityData = ActivityData()
        
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
    }
    
    class func hideHUD()
    {
       
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

    }
    class func showACProgressHUD() {
        
//        let progressView = ACProgressHUD.shared
//        /*
//         ACProgressHUD.shared.configureStyle(withProgressText: "", progressTextColor: .black, progressTextFont: <#T##UIFont#>, shadowColor: UIColor.black, shadowRadius: 3, cornerRadius: 5, indicatorColor: UIColor.init(red: 204/255, green: 3/255, blue: 0, alpha: 1.0), hudBackgroundColor: .white, enableBackground: false, backgroundColor: UIColor.black, backgroundColorAlpha: 0.3, enableBlurBackground: false, showHudAnimation: .growIn, dismissHudAnimation: .growOut)
//         */
//        progressView.progressText = ""
//
//        progressView.hudBackgroundColor = .black
//
//        progressView.indicatorColor = themeYellowColor
//        //        progressView.shadowRadius = 0.5
//
//
//        progressView.showHUD()
        
        let activityData = ActivityData()
//        NVActivityIndicatorView.DEFAULT_BLOCKER_MINIMUM_DISPLAY_TIME = 55
//        NVActivityIndicatorView.DEFAULT_BLOCKER_DISPLAY_TIME_THRESHOLD = 55
        NVActivityIndicatorView.DEFAULT_TYPE = .ballClipRotateMultiple // .ballRotate
        NVActivityIndicatorView.DEFAULT_COLOR = themeYellowColor
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityData)
        
    }
    
    class func hideACProgressHUD() {
    
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()

    }
    
    class func showNavigationTextColor(color: UIColor) {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: color], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: color], for: UIControlState.highlighted)
    }
    
    class func hideNavigationTextColor() {
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.clear], for: UIControlState.highlighted)
    }

}

extension UILabel {
    func underlineToLabel() {
        if let textString = self.text {
            let attributedString = NSMutableAttributedString(string: textString)
            attributedString.addAttribute(NSAttributedStringKey.underlineStyle,
                                          value: NSUnderlineStyle.styleSingle.rawValue,
                                          range: NSRange(location: 0, length: attributedString.length))
            attributedText = attributedString
        }
    }
}


// ----------------------------------------------------------------------
//-------------------------------------------------------------
// MARK: - Draw Circle
//-------------------------------------------------------------

class PieChart : UIView {
    
    override func draw(_ rect: CGRect) {
        
        drawSlice(rect: rect, startPercent: 0, endPercent: 50, color: UIColor.black)
//        drawSlice(rect: rect, startPercent: 50, endPercent: 75, color: UIColor.red)
    }
    
    private func drawSlice(rect: CGRect, startPercent: CGFloat, endPercent: CGFloat, color: UIColor) {
        let center = CGPoint(x: rect.origin.x + rect.width / 2, y: rect.origin.y + rect.height / 2)
        let radius = min(rect.width, rect.height) / 2
        let startAngle = startPercent / 100 * CGFloat(M_PI) * 2 - CGFloat(M_PI)
        let endAngle = endPercent / 100 * CGFloat(M_PI) * 2 - CGFloat(M_PI)
        let path = UIBezierPath()
        path.move(to: center)
        path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.close()
        color.setFill()
        path.fill()
    }
}



//-------------------------------------------------------------
// MARK: - Internet Connection Check Methods
//-------------------------------------------------------------

class Connectivity {
    class func isConnectedToInternet() ->Bool {
        return NetworkReachabilityManager()!.isReachable
    }
}

extension Dictionary {
    func safeGet<T>(key:Key) throws -> T {
        if let value = self[key] as? AnyObject {
            if let typedValue = value as? T {
                return typedValue
            }
            
            let typedValue: T? = parseNumber(value: value)
            if typedValue != nil {
                return typedValue!
            }
            
            let typeData = Mirror(reflecting: value)
            throw generateNSError(
                domain: "DictionaryError.WrongType",
                message: "Could not convert `\(key)` to `\(T.self)`, it was `\(typeData.subjectType)` and had the value `\(value)`"
            )
        } else {
            throw generateNSError(
                domain: "DictionaryError.MissingValue",
                message: "`\(key)` was not in dictionary. The dictionary was:\n\(self.description)"
            )
        }
    }
    
    private func parseNumber<T>(value: AnyObject) -> T? {
        if Int8.self == T.self {
            if let numericValue = value as? NSNumber {
                return numericValue.int8Value as? T
            } else if let stringValue = value as? String {
                return Int8(stringValue) as? T
            }
        } else if Int16.self == T.self {
            if let numericValue = value as? NSNumber {
                return numericValue.int16Value as? T
            } else if let stringValue = value as? String {
                return Int16(stringValue) as? T
            }
        } else if Int32.self == T.self {
            if let numericValue = value as? NSNumber {
                return numericValue.int32Value as? T
            } else if let stringValue = value as? String {
                return Int32(stringValue) as? T
            }
        } else if Int64.self == T.self {
            if let numericValue = value as? NSNumber {
                return numericValue.int64Value as? T
            } else if let stringValue = value as? String {
                return Int64(stringValue) as? T
            }
        } else if UInt8.self == T.self {
            if let numericValue = value as? NSNumber {
                return numericValue.uint8Value as? T
            } else if let stringValue = value as? String {
                return UInt8(stringValue) as? T
            }
        } else if UInt16.self == T.self {
            if let numericValue = value as? NSNumber {
                return numericValue.uint16Value as? T
            } else if let stringValue = value as? String {
                return UInt16(stringValue) as? T
            }
        } else if UInt32.self == T.self {
            if let numericValue = value as? NSNumber {
                return numericValue.uint32Value as? T
            } else if let stringValue = value as? String {
                return UInt32(stringValue) as? T
            }
        } else if UInt64.self == T.self {
            if let numericValue = value as? NSNumber {
                return numericValue.uint64Value as? T
                
            } else if let stringValue = value as? String {
                return UInt64(stringValue) as? T
            }
        } else if Double.self == T.self {
            if let numericValue = value as? NSNumber {
                return numericValue.doubleValue as? T
            } else if let stringValue = value as? String {
                return Double(stringValue) as? T
            }
        } else if Float.self == T.self {
            if let numericValue = value as? NSNumber {
                return numericValue.floatValue as? T
            } else if let stringValue = value as? String {
                return Float(stringValue) as? T
            }
        } else if String.self == T.self {
            if let numericValue = value as? NSNumber {
                return numericValue.stringValue as? T
            } else if let stringValue = value as? String {
                return stringValue as? T
            }
        }
        return nil
    }
    
    private func generateNSError(domain: String, message: String) -> NSError {
        return NSError(
            domain: domain,
            code: -1,
            userInfo: [
                NSLocalizedDescriptionKey: message
            ])
    }
}


//
//  ValidationClass.swift
//  MyRickshaw User
//
//  Created by Apple on 19/11/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation


func isValidEmailAddress(emailID: String) -> Bool
{
    var returnValue = true
    let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z)-9.-]+\\.[A-Za-z]{2,3}"
    
    do{
        let regex = try NSRegularExpression(pattern: emailRegEx)
        let nsString = emailID as NSString
        let results = regex.matches(in: emailID, range: NSRange(location: 0, length: nsString.length))
        
        if results.count == 0
        {
            returnValue = false
        }
    }
    catch _ as NSError
    {
        returnValue = false
    }
    
    return returnValue
}

extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    static func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        if let navigationController = vc as? UINavigationController,
            let visibleController = navigationController.visibleViewController  {
            return UIWindow.getVisibleViewControllerFrom( vc: visibleController )
        } else if let tabBarController = vc as? UITabBarController,
            let selectedTabController = tabBarController.selectedViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: selectedTabController )
        } else {
            if let presentedViewController = vc.presentedViewController {
                return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController)
            } else {
                return vc
            }
        }
    }
}

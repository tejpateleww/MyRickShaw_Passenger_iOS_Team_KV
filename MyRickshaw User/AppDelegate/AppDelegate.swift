//
//  AppDelegate.swift
//  TickTok User
//
//  Created by Excellent Webworld on 25/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
//import Fabric
//import Crashlytics
import SideMenuController
import SocketIO
import UserNotifications
import Firebase
import FirebaseCore
import FirebaseMessaging


let googleMapAddress = "AIzaSyC-SFqp8tjooejbFiIa-hwq2Gl-og7ZeSQ"//"AIzaSyDfI6F_8lFtv_Cf-QhfwsGzCiS2V-ladSA"//
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    
    

     let SocketManager = SocketIOClient(socketURL: URL(string: SocketData.kBaseURL)!, config: [.log(false), .compress])

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UIFont.overrideInitialize()

        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: UIControl.State.highlighted)
        
        // Firebase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        
        IQKeyboardManager.shared.enable = true
        
        
        GMSServices.provideAPIKey(googleMapAddress)
        GMSPlacesClient.provideAPIKey(googleMapAddress)
        
        
         // TODO: Move this to where you establish a user session
     //   self.logUser()
        
        // ------------------------------------------------------------
        
        SideMenuController.preferences.drawing.menuButtonImage = UIImage(named: "menu")
        SideMenuController.preferences.drawing.sidePanelPosition = .overCenterPanelLeft
        SideMenuController.preferences.drawing.sidePanelWidth = (((window?.frame.width)! / 2) + ((window?.frame.width)! / 4))
        SideMenuController.preferences.drawing.centerPanelShadow = true
        SideMenuController.preferences.animating.statusBarBehaviour = .showUnderlay
        
        
        
        
        // ------------------------------------------------------------

        if ((UserDefaults.standard.object(forKey: "profileData")) != nil)
        {
            
            if let dictProfile = UserDefaults.standard.object(forKey: "profileData") as? NSMutableDictionary
            {
                SingletonClass.sharedInstance.dictProfile = dictProfile
            }
            else if let dictProfile = UserDefaults.standard.object(forKey: "profileData") as? NSDictionary
            {
                SingletonClass.sharedInstance.dictProfile = NSMutableDictionary(dictionary: dictProfile)
            }
            
            
//            SingletonClass.sharedInstance.dictProfile = UserDefaults.standard.object(forKey: "profileData") as! NSMutableDictionary
            SingletonClass.sharedInstance.strPassengerID = String(describing: SingletonClass.sharedInstance.dictProfile.object(forKey: "Id")!)
            SingletonClass.sharedInstance.arrCarLists = NSMutableArray(array:  UserDefaults.standard.object(forKey: "carLists") as? NSArray ?? NSArray())
            SingletonClass.sharedInstance.isUserLoggedIN = true
        }
        else
        {
            SingletonClass.sharedInstance.isUserLoggedIN = false
        }
        
         // For Passcode Set
        if UserDefaults.standard.object(forKey: "Passcode") as? String == nil || UserDefaults.standard.object(forKey: "Passcode") as? String == "" {
            SingletonClass.sharedInstance.setPasscode = ""
            UserDefaults.standard.set(SingletonClass.sharedInstance.setPasscode, forKey: "Passcode")
        }
        else {
            SingletonClass.sharedInstance.setPasscode = UserDefaults.standard.object(forKey: "Passcode") as! String
        }
        
        // For Passcode Switch
        if let isSwitchOn = UserDefaults.standard.object(forKey: "isPasscodeON") as? Bool {
            
            SingletonClass.sharedInstance.isPasscodeON = isSwitchOn
            UserDefaults.standard.set(SingletonClass.sharedInstance.isPasscodeON, forKey: "isPasscodeON")
        }
        else {
            SingletonClass.sharedInstance.isPasscodeON = false
            UserDefaults.standard.set(SingletonClass.sharedInstance.isPasscodeON, forKey: "isPasscodeON")
        }

        
        if UserDefaults.standard.object(forKey: ModelDataConstant.kLoginResponse) != nil {
            
            let carlist = getCarListData()
            if carlist != nil {
                SingletonClass.sharedInstance.carList = carlist
            }
            
        }
        
        
        // Push Notification Code
        registerForPushNotification()
        
        let remoteNotif = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary
        
        if remoteNotif != nil {
            let key = (remoteNotif as! NSDictionary).object(forKey: "gcm.notification.type")!
            NSLog("\n Custom: \(String(describing: key))")
            self.pushAfterReceiveNotification(typeKey: key as! String)
        }
        else {
            //            let aps = remoteNotif!["aps" as NSString] as? [String:AnyObject]
            NSLog("//////////////////////////Normal launch")
            //            self.pushAfterReceiveNotification(typeKey: "")
            
        }
        
        
        self.GoToFirstScreen()
        
        /*
         if let notification = launchOptions?[.remoteNotification] as? [String:AnyObject] {
         
         //            let aps = notification["aps"] as! [String:AnyObject]
         //            _ = NewsItems.makeNewsItems(aps)
         
         //            (window?.rootViewController as? UITabBarController)?.selectedIndex = 0
         }
         */
        
        
        
        
        return true
    }
    
//    func logUser() {
//        // TODO: Use the current user's information
//        // You can call any combination of these three methods
//
//        if ((UserDefaults.standard.object(forKey: "profileData")) != nil)
//        {
//            SingletonClass.sharedInstance.dictProfile = UserDefaults.standard.object(forKey: "profileData") as! NSMutableDictionary
//            Crashlytics.sharedInstance().setUserEmail("user@fabric.io")
//            Crashlytics.sharedInstance().setUserIdentifier("12345")
//            Crashlytics.sharedInstance().setUserName("Test User")
//        }
//
//    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
//        let isSwitchOn = UserDefaults.standard.object(forKey: "isPasscodeON") as? Bool
//        let passCode = SingletonClass.sharedInstance.setPasscode
//        
//        SingletonClass.sharedInstance.isPasscodeON = isSwitchOn!
//        
//        if (passCode != "" && SingletonClass.sharedInstance.isPasscodeON) {
//            
//            let mainStoryboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let initialViewController = mainStoryboard.instantiateViewController(withIdentifier: "VerifyPasswordViewController") as! VerifyPasswordViewController
//            
//            initialViewController.isFromAppDelegate = true
//            self.window?.rootViewController?.present(initialViewController, animated: true, completion: nil)
//        }
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // Push Notification Methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let toketParts = deviceToken.map({ (data)-> String in
            return String(format: "%0.2.2hhx", data)
        })
        
        let token = toketParts.joined()
        print("Device Token: \(token)")

        
        Messaging.messaging().apnsToken = deviceToken as Data
        
        print("deviceToken : \(deviceToken)")
        
        
        let fcmToken = Messaging.messaging().fcmToken
        print("FCM token: \(fcmToken ?? "")")
        
        if fcmToken == nil {
            
        }
        else {
            SingletonClass.sharedInstance.deviceToken = fcmToken!
            UserDefaults.standard.set(SingletonClass.sharedInstance.deviceToken, forKey: "Token")
        }
        
        
        print("SingletonClass.sharedInstance.deviceToken : \(SingletonClass.sharedInstance.deviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
        
        let currentDate = Date()
        print("currentDate : \(currentDate)")
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let key = (userInfo as NSDictionary).object(forKey: "gcm.notification.type")!
        
        if(application.applicationState == .background)
        {
            self.pushAfterReceiveNotification(typeKey: key as! String)
        }
        

        
        // Let FCM know about the message for analytics etc.
        Messaging.messaging().appDidReceiveMessage(userInfo)
        // handle your message
        
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        /*
         // 1
         let userInfo = response.notification.request.content.userInfo
         let aps = userInfo["aps"] as! [String:AnyObject]
         
         // 2
         if let newsItem = NewsItem.makeNewsItems(aps) {
         (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
         
         // 3
         if response.actionIdentifier == "viewActionIdentifier",
         let url = URL(string: newsItem.link) {
         let safari = SFSafariViewController(url: url)
         window?.rootViewController?.present(safari, animated: true, completion: nil)
         }
         }
         // 4
         completionHandler()
         */
    }
    
    
      // MARK:- Login & Logout Methods

        func GoToHome() {
            let storyborad = UIStoryboard(name: "Main", bundle: nil)
            let CustomSideMenu = storyborad.instantiateViewController(withIdentifier: "CustomSideMenuViewController") as! SideMenuController
            let NavHomeVC = UINavigationController(rootViewController: CustomSideMenu)
            NavHomeVC.isNavigationBarHidden = true
            UIApplication.shared.keyWindow?.rootViewController = NavHomeVC
        }


        func GoToFirstScreen() {
            let storyborad = UIStoryboard(name: "Main", bundle: nil)
            let CustomSideMenu = storyborad.instantiateViewController(withIdentifier: "FirstScreenViewController") as! FirstScreenViewController
            let NavHomeVC = UINavigationController(rootViewController: CustomSideMenu)
            NavHomeVC.isNavigationBarHidden = true
            UIApplication.shared.keyWindow?.rootViewController = NavHomeVC
        }


        func GoToLogin() {

            let storyborad = UIStoryboard(name: "Main", bundle: nil)
            let Login = storyborad.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            let NavHomeVC = UINavigationController(rootViewController: Login)
            NavHomeVC.isNavigationBarHidden = true
            UIApplication.shared.keyWindow?.rootViewController = NavHomeVC

        }

        func GoToLogout() {
            
    //        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.children.first?.children.first?.children.first as! HomeViewController
            //1. Clear Singleton class
//            SingletonClass.sharedInstance.clearSingletonClass()

            //2. Clear all userdefaults
            for (key, _) in UserDefaults.standard.dictionaryRepresentation() {
    //            print("\(key) = \(value) \n")
                if key == "Token" || key  == "i18n_language" {
                }
                else {
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            //3. Set isLogin USer Defaults to false
            UserDefaults.standard.set(false, forKey: "isUserLogin")
            self.GoToLogin()
        }
    
    //-------------------------------------------------------------
    // MARK: - Push Notification Methods
    //-------------------------------------------------------------
    
    func registerForPushNotification() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            
            print("Permissin granted: \(granted)")

            self.getNotificationSettings()

        })
        
    }

    
    func getNotificationSettings() {
        
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {(settings) in
            
            print("Notification Settings: \(settings)")
  
            
            guard settings.authorizationStatus == .authorized else { return }
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()

            }
            
        })
    }
    
    //-------------------------------------------------------------
    // MARK: - FireBase Methods
    //-------------------------------------------------------------
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
        
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Actions On Push Notifications
    //-------------------------------------------------------------
    
    func pushAfterReceiveNotification(typeKey : String)
    {
        
        if(typeKey == "AddMoney")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let navController = self.window?.rootViewController as? UINavigationController
                let notificationController: UIViewController? = navController?.storyboard?.instantiateViewController(withIdentifier: "WalletHistoryViewController")
                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                    
                })
            }
        }
        else if(typeKey == "TransferMoney")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let navController = self.window?.rootViewController as? UINavigationController
                let notificationController: UIViewController? = navController?.storyboard?.instantiateViewController(withIdentifier: "WalletHistoryViewController")
                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                    
                })
            }
        }
        else if(typeKey == "Tickpay")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let navController = self.window?.rootViewController as? UINavigationController
                let notificationController: UIViewController? = navController?.storyboard?.instantiateViewController(withIdentifier: "PayViewController")
                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                    
                })
            }
        }
        else if(typeKey == "AcceptBooking")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let navController = self.window?.rootViewController as? UINavigationController
                let notificationController = navController?.storyboard?.instantiateViewController(withIdentifier: "MyBookingViewController") as! MyBookingViewController
                notificationController.bookingType = "accept"
                notificationController.isFromPushNotification = true
                
                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                    
                })
            }
        }
        else if(typeKey == "RejectBooking")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let navController = self.window?.rootViewController as? UINavigationController
                let notificationController = navController?.storyboard?.instantiateViewController(withIdentifier: "MyBookingViewController")  as! MyBookingViewController
                notificationController.bookingType = "reject"
                notificationController.isFromPushNotification = true
                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                    
                })
            }
        }
        else if(typeKey == "OnTheWay")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let navController = self.window?.rootViewController as? UINavigationController
                let notificationController = navController?.storyboard?.instantiateViewController(withIdentifier: "MyBookingViewController") as! MyBookingViewController
                notificationController.bookingType = "accept"
                notificationController.isFromPushNotification = true
                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                    
                })
            }
        }
        else if(typeKey == "Booking")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let navController = self.window?.rootViewController as? UINavigationController
                let notificationController = navController?.storyboard?.instantiateViewController(withIdentifier: "MyBookingViewController")  as! MyBookingViewController
                notificationController.bookingType = "reject"
                notificationController.isFromPushNotification = true
                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                    
                })
            }
        }
        else if(typeKey == "AdvanceBooking")
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let navController = self.window?.rootViewController as? UINavigationController
                let notificationController = navController?.storyboard?.instantiateViewController(withIdentifier: "MyBookingViewController")  as! MyBookingViewController
                notificationController.bookingType = "reject"
                notificationController.isFromPushNotification = true
                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
                    
                })
            }
        }
        
//        else if(typeKey == "RejectDispatchJobRequest")
//        {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                let navController = self.window?.rootViewController as? UINavigationController
//                let notificationController: UIViewController? = navController?.storyboard?.instantiateViewController(withIdentifier: "PastJobsListVC")
//                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
//
//                })
//            }
//        }
//        else if(typeKey == "BookLaterDriverNotify")
//        {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                let navController = self.window?.rootViewController as? UINavigationController
//                let notificationController: UIViewController? = navController?.storyboard?.instantiateViewController(withIdentifier: "FutureBookingVC")
//                navController?.present(notificationController ?? UIViewController(), animated: true, completion: {
//
//                })
//            }
//        }
    }
    
   

}


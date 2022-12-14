//
//  HomeVCSocketMethods.swift
//  MyRickshaw User
//
//  Created by Excelent iMac on 05/06/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation
import NVActivityIndicatorView
import CoreLocation
import GoogleMaps
import GooglePlaces
import SocketIO
import SDWebImage
import SwiftMessages

extension HomeViewController {
    
    //MARK: - Socket Methods
    func socketMethods()
    {
        
        var isSocketConnected = Bool()
        
        socket.on(clientEvent: .disconnect) { (data, ack) in
            print ("socket is disconnected please reconnect")
        }
        
        socket.on(clientEvent: .reconnect) { (data, ack) in
            print ("socket is disconnected please reconnect")
        }
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            
            self.timerForUpdatingPassengerLocation()
            
            if self.socket.status != .connected {
                
                // print("socket.status != .connected")
            }
            
            if (isSocketConnected == false) {
                isSocketConnected = true
                
                self.socketMethodForGettingBookingAcceptNotification()  // Accept Now Req
                self.socketMethodForGettingBookingRejectNotification()  // Reject Now Req
                self.socketMethodForGettingPickUpNotification()         // Start Now Req
                self.socketMethodForGettingTripCompletedNotification()  // CompleteTrip Now Req
                self.onTripHoldingNotificationForPassengerLater()       // Hold Trip Later
                self.onReceiveDriverLocationToPassenger()               // Driver Location Receive
                self.socketMethodForGettingBookingRejectNotificatioByDriver()   // Reject By Driver
                self.onAcceptBookLaterBookingRequestNotification()              // Accept Later Req
                self.onRejectBookLaterBookingRequestNotification()              // Reject Later Req
                self.onPickupPassengerByDriverInBookLaterRequestNotification()
                self.onTripHoldingNotificationForPassenger()                    // Hold Trip Now
                self.onBookingDetailsAfterCompletedTrip()                       // Booking Details After Complete Trip
                self.onGetEstimateFare()                                        // Get Estimate
                self.onAdvanceTripInfoBeforeStartTrip()                         // Start Later Req
                self.onReceiveNotificationWhenDriverAcceptRequest()
                self.onGetChetMessage()                                     // Chating to Driver
                
            }
            
            self.socket.on(SocketData.kNearByDriverList, callback: { (data, ack) in
//                print("Driver List is \(data)")
                //                var lat : Double!
                //                var long : Double!
                
                self.arrNumberOfAvailableCars = NSMutableArray(array: ((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "driver") as! NSArray)
                self.setData()
                
                //                self.collectionViewCars.reloadData()
                if (((data as NSArray).object(at: 0) as! NSDictionary).count != 0)
                {
                    for i in 0..<(((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "driver") as! NSArray).count
                    {
                        
                        //                        _ = ((((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "driver") as! NSArray).object(at: i) as! NSDictionary).object(forKey: "Location") as! NSArray
                        //Timer.scheduledTimer
                        //                        lat = arrayOfCoordinte.object(at: 0) as! Double
                        //                        long = arrayOfCoordinte.object(at: 1) as! Double
                        
                        let DriverId = ((((data as NSArray).object(at: 0) as! NSDictionary).object(forKey: "driver") as! NSArray).object(at: i) as! NSDictionary).object(forKey: "DriverId") as! String
                        
                        self.aryOfTempOnlineCarsIds.append(DriverId)
                        self.aryOfOnlineCarsIds = self.uniq(source: self.aryOfTempOnlineCarsIds)
                        
                        /*
                         DispatchQueue.main.async
                         {
                         let position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                         let marker = GMSMarker(position: position)
                         marker.tracksViewChanges = false
                         marker.icon = UIImage(named: "iconCar") // iconCurrentLocation
                         marker.map = self.mapView
                         }
                         */
                    }
                }
                self.postPickupAndDropLocationForEstimateFare()
                
            })
            
        }
        
        socket.connect()
    }
    
    
    
    
    func timerForUpdatingPassengerLocation(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        DispatchQueue.global(qos: .background).sync {
            if(timerToUpdatePassengerLocation == nil)
            {
                timerToUpdatePassengerLocation = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
            }
        }
        
    }
    
    func socketMethodForGettingBookingAcceptNotification()
    {
        // Socket Accepted
        self.socket.on(SocketData.kAcceptBookingRequestNotification, callback: { (data, ack) in
            // // print("AcceptBooking data is \(data)")
            self.txtDestinationLocation.text = ""
            self.strLocationType = ""
            //            self.socket.off(SocketData.kAcceptBookingRequestNotification)
            
            
            //            self.clearMap()
            //            RequestConfirm.mp3
            //            self.playSound(fileName: "RequestConfirm", extensionType: "mp3")
            
            //            UtilityClass.showAlertWithCompletion("", message: "Your request has been Accepted.", vc: self, completionHandler: { ACTION in
            //
            //                self.stopSound(fileName: "RequestConfirm", extensionType: "mp3")
            //            })
            
            
            //                self.stopSound(fileName: "RequestConfirm", extensionType: "mp3")
            //            }
            if let getInfoFromData = data as? [[String:AnyObject]] {
                
                //                self.aryBookingAcceptedData = getInfoFromData
                self.dictCurrentBookingInfoData = ((getInfoFromData.first)?["BookingInfo"])?.firstObject as? NSDictionary ?? [:]
                if let infoData = getInfoFromData[0] as? [String:AnyObject] {
                    if let bookingInfo = infoData["BookingInfo"] as? [[String:AnyObject]] {
                        var bookingIdIs = String()
                        if let nowBookingID: Int = (bookingInfo[0])["Id"] as? Int {
                            bookingIdIs = "\(nowBookingID)"
                        }
                        else if let nowBookingID: String = (bookingInfo[0])["Id"] as? String {
                            bookingIdIs = nowBookingID
                        }
                        // print("bookingIdIs: \(bookingIdIs)")
                        
                        if let moreInfo = infoData["ModelInfo"] as? [[String:Any]] {
                            if moreInfo.count != 0 {
                                if let intCancellationFee = moreInfo[0]["CancellationFee"] as? Int {
                                    self.CancellationFee = "\(intCancellationFee)"
                                }
                                else if let strCancellationFee = moreInfo[0]["CancellationFee"] as? String {
                                    self.CancellationFee = strCancellationFee
                                }
                            }
                        }
                        
                        if SingletonClass.sharedInstance.bookingId != "" {
                            if SingletonClass.sharedInstance.bookingId == bookingIdIs {
                                self.DriverInfoAndSetToMap(driverData: NSArray(array: data))
                            }
                        }
                        else {
                            self.DriverInfoAndSetToMap(driverData: NSArray(array: data))
                            
                        }
                    }
                }
            }
            
            self.performSegue(withIdentifier: "segueBookingConfirmed", sender: nil)
            
            
            //            self.DriverInfoAndSetToMap(driverData: NSArray(array: data))
            
            
            
        })
    }
    
    func socketMethodForGettingBookingRejectNotification()
    {
        // Socket Accepted
        self.socket.on(SocketData.kRejectBookingRequestNotification, callback: { (data, ack) in
            // print("socketMethodForGettingBookingRejectNotification() is \(data)")
            
            self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
            
            var bookingId = String()
            
            if let bookingInfoData = (data as! [[String:AnyObject]])[0] as? [String:AnyObject] {
                if let bookingInfo = bookingInfoData["BookingId"] as? Int {
                    bookingId = "\(bookingInfo)"
                }
                else if let bookingInfo = bookingInfoData["BookingId"] as? String {
                    bookingId = bookingInfo
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    if SingletonClass.sharedInstance.bookingId == bookingId {
                        self.viewActivity.stopAnimating()
                        self.viewMainActivityIndicator.isHidden = true
                        UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                            
                        })
                    }
                }
                else {
                    self.viewActivity.stopAnimating()
                    self.viewMainActivityIndicator.isHidden = true
                    UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                        
                    })
                }
            }
            
            self.setClearTextFieldsOfExtra()
            self.clearDestinationLocation()
            
            //            self.strBookingType = ""
            self.btnDoneForLocationSelected.isHidden = true
            
            //            self.viewActivity.stopAnimating()
            //            self.viewMainActivityIndicator.isHidden = true
            //            UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
            //
            //            })
            
            /*
             [{
             BookingId = 7623;
             message = "Your Booking request has been canceled";
             type = BookingRequest;
             }]
             */
            
            
        })
    }
    
    func socketMethodForGettingPickUpNotification()
    {
        self.socket.on(SocketData.kPickupPassengerNotification, callback: { (data, ack) in
            // print("socketMethodForGettingPickUpNotification() is \(data)")
            //            self.stopTimer()
            /*
             [{
             BookingId = 7625;
             DriverId = 70;
             message = "Your trip has now started.";
             }]
             */
            var bookingIdIs = String()
            
            if let bookingData = data as? [[String:AnyObject]] {
                if let id = bookingData[0]["BookingId"] as? String {
                    bookingIdIs = id
                }
                else if let id = bookingData[0]["BookingId"] as? Int {
                    bookingIdIs = "\(id)"
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    if SingletonClass.sharedInstance.bookingId == bookingIdIs {
                        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                        UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                            
                        })
                        
                        self.btnRequest.isHidden = true
                        self.btnCancelStartedTrip.isHidden = true
                        
                        self.methodAfterStartTrip(tripData: NSArray(array: data))
                    }
                }
                else {
                    NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
                    UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                        
                    })
                    
                    self.btnRequest.isHidden = true
                    self.btnCancelStartedTrip.isHidden = true
                    
                    self.methodAfterStartTrip(tripData: NSArray(array: data))
                }
                
            }
            
            
            //            NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
            //            UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
            //
            //            })
            //
            //            self.btnRequest.isHidden = true
            //            self.btnCancelStartedTrip.isHidden = true
            //
            //            self.methodAfterStartTrip(tripData: NSArray(array: data))
            
        })
    }
    
    func socketMethodForGettingTripCompletedNotification()
    {
        self.socket.on(SocketData.kBookingCompletedNotification, callback: { (data, ack) in
            // print("socketMethodForGettingTripCompletedNotification() is \(data)")
            self.strLocationType = ""
            
            // Restarting Timer For updating Passenger location which was stopped on STart trip
            self.timerForUpdatingPassengerLocation()
            /////
            
            SingletonClass.sharedInstance.isTripContinue = false
            self.aryCompleterTripData = data
            
            
            //            SingletonClass.sharedInstance.creditHistoryData["AvailableCreditLimit"] = "\(Int(data["AvailableCreditLimit"]))"
            if let getInfoFromData = data as? [[String:AnyObject]] {
                
                if let infoData = getInfoFromData[0] as? [String:AnyObject] {
                    
                    if let AvailableCredit = infoData["AvailableCreditLimit"] as? Int
                    {
                        SingletonClass.sharedInstance.creditHistoryData["AvailableCreditLimit"] = "\(AvailableCredit)"
                    }
                    else if let AvailableCredit = infoData["AvailableCreditLimit"] as? String
                    {
                        SingletonClass.sharedInstance.creditHistoryData["AvailableCreditLimit"] = AvailableCredit
                    }
                    
                    
                    if let bookingInfo = infoData["Info"] as? [[String:AnyObject]] {
                        var bookingIdIs = String()
                        if let nowBookingID: Int = (bookingInfo[0])["Id"] as? Int {
                            bookingIdIs = "\(nowBookingID)"
                        }
                        else if let nowBookingID: String = (bookingInfo[0])["Id"] as? String {
                            bookingIdIs = nowBookingID
                        }
                        // print("bookingIdIs: \(bookingIdIs)")
                        
                        if SingletonClass.sharedInstance.bookingId != "" {
                            if SingletonClass.sharedInstance.bookingId == bookingIdIs {
                                if (SingletonClass.sharedInstance.passengerTypeOther) {
                                    
                                    SingletonClass.sharedInstance.passengerTypeOther = false
                                    self.completeTripInfo()
                                }
                                else {
                                    self.completeTripInfo()
                                    //                self.performSegue(withIdentifier: "showRating", sender: nil)
                                }
                            }
                        }
                    }
                }
            }
            
            /*
             
             let bookingId = ((((data as! [[String:AnyObject]])[0] as! [String:AnyObject])["Info"] as! [[String:AnyObject]])[0] as! [String:AnyObject])["Id"]
             
             //            self.viewMainFinalRating.isHidden = false
             
             if (SingletonClass.sharedInstance.passengerTypeOther) {
             
             SingletonClass.sharedInstance.passengerTypeOther = false
             self.completeTripInfo()
             }
             else {
             
             self.completeTripInfo()
             //                self.performSegue(withIdentifier: "showRating", sender: nil)
             }
             
             //            let next = self.storyboard?.instantiateViewController(withIdentifier: "GiveRatingViewController") as! GiveRatingViewController
             //            next.strBookingType = self.strBookingType
             //            next.delegate = self
             //            next.modalPresentationStyle = .overCurrentContext
             //            self.present(next, animated: true, completion: nil)
             */
            
        })
    }
    
    
    func onAcceptBookLaterBookingRequestNotification() {
        
        self.socket.on(SocketData.kAcceptAdvancedBookingRequestNotification, callback: { (data, ack) in
            // print("onAcceptBookLaterBookingRequestNotification() is \(data)")
            
            //            self.playSound(fileName: "RequestConfirm", extensionType: "mp3")
            
            //            UtilityClass.showAlertWithCompletion("", message: "Your request has been Accepted.", vc: self, completionHandler: { ACTION in
            //
            //                self.stopSound(fileName: "RequestConfirm", extensionType: "mp3")
            //            })
            
            var bookingId = String()
            
            if let bookingInfoData = (data as! [[String:AnyObject]])[0]["BookingInfo"] as? [[String:AnyObject]] {
                if let bookingInfo = bookingInfoData[0]["Id"] as? Int {
                    bookingId = "\(bookingInfo)"
                }
                else if let bookingInfo = bookingInfoData[0]["Id"] as? String {
                    bookingId = bookingInfo
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    if SingletonClass.sharedInstance.bookingId == bookingId {
                        
                        UtilityClass.setCustomAlert(title: "\(appName)", message: "Your request has been Accepted.") { (index, title) in
                            //               self.stopSound(fileName: "RequestConfirm", extensionType: "mp3")
                        }
                        self.strBookingType = "BookLater"
                        self.DriverInfoAndSetToMap(driverData: NSArray(array: data))
                    }
                }
                else {
                    UtilityClass.setCustomAlert(title: "\(appName)", message: "Your request has been Accepted.") { (index, title) in
                        //               self.stopSound(fileName: "RequestConfirm", extensionType: "mp3")
                    }
                    self.strBookingType = "BookLater"
                    self.DriverInfoAndSetToMap(driverData: NSArray(array: data))
                }
            }
            
            if let moreInfo = (data as! [[String:Any]])[0]["ModelInfo"] as? [[String:Any]] {
                if moreInfo.count != 0 {
                    if let intCancellationFee = moreInfo[0]["CancellationFee"] as? Int {
                        self.CancellationFee = "\(intCancellationFee)"
                    }
                    else if let strCancellationFee = moreInfo[0]["CancellationFee"] as? String {
                        self.CancellationFee = strCancellationFee
                    }
                }
            }
            
            
        })
    }
    
    func onRejectBookLaterBookingRequestNotification() {
        
        self.socket.on(SocketData.kRejectAdvancedBookingRequestNotification, callback: { (data, ack) in
            // print("onRejectBookLaterBookingRequestNotification() is \(data)")
            
            //            self.playSound(fileName: "PickNGo", extensionType: "mp3")
            
            let alert = UIAlertController(title: nil, message: "Your request has been rejected.", preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: { (ACTION) in
                //                self.stopSound(fileName: "PickNGo", extensionType: "mp3")
                //                self.strBookingType = ""
                SingletonClass.sharedInstance.bookingId = ""
                self.btnDoneForLocationSelected.isHidden = false
            })
            alert.addAction(OK)
            //            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
            UtilityClass.presentOverAlert(vc: alert)
        })
    }
    
    func onPickupPassengerByDriverInBookLaterRequestNotification() {
        
        self.socket.on(SocketData.kAdvancedBookingPickupPassengerNotification, callback: { (data, ack) in
            // print("onPickupPassengerByDriverInBookLaterRequestNotification() is \(data)")
            
            var bookingId = String()
            self.stopUpdatingPassengerLocationTimer()
            
            if let bookingInfoData = (data as! [[String:AnyObject]])[0]["BookingInfo"] as? [[String:AnyObject]] {
                if let bookingInfo = bookingInfoData[0]["Id"] as? Int {
                    bookingId = "\(bookingInfo)"
                }
                else if let bookingInfo = bookingInfoData[0]["Id"] as? String {
                    bookingId = bookingInfo
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    
                    if SingletonClass.sharedInstance.bookingId == bookingId {
                        self.strBookingType = "BookLater"
                        let alert = UIAlertController(title: nil, message: "Your trip has now started.", preferredStyle: .alert)
                        let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(OK)
                        //                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                        UtilityClass.presentOverAlert(vc: alert)
                        self.btnRequest.isHidden = true
                        self.btnCancelStartedTrip.isHidden = true
                        //            SingletonClass.sharedInstance.isTripContinue = true
                        self.methodAfterStartTrip(tripData: NSArray(array: data))
                        
                    }
                }
                else {
                    self.strBookingType = "BookLater"
                    let alert = UIAlertController(title: nil, message: "Your trip has now started.", preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OK)
                    //                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                    UtilityClass.presentOverAlert(vc: alert)
                    self.btnRequest.isHidden = true
                    self.btnCancelStartedTrip.isHidden = true
                    //            SingletonClass.sharedInstance.isTripContinue = true
                    self.methodAfterStartTrip(tripData: NSArray(array: data))
                }
            }
            
        })
    }
    
    func onTripHoldingNotificationForPassenger() {
        
        self.socket.on(SocketData.kReceiveHoldingNotificationToPassenger, callback: { (data, ack) in
            // print("onTripHoldingNotificationForPassenger() is \(data)")
            
            var message = String()
            message = "Trip on Hold"
            
            if let resAry = NSArray(array: data) as? NSArray {
                message = (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String
                //                UtilityClass.showAlert("", message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)
            }
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(OK)
            
            //            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
            UtilityClass.presentOverAlert(vc: alert)
        })
    }
    
    func onTripHoldingNotificationForPassengerLater() {
        
        self.socket.on(SocketData.kAdvancedBookingTripHoldNotification, callback: { (data, ack) in
            // print("onTripHoldingNotificationForPassengerLater() is \(data)")
            
            var message = String()
            message = "Trip on Hold"
            
            if let resAry = NSArray(array: data) as? NSArray {
                message = (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String
                //                UtilityClass.showAlert("", message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String, vc: self)
            }
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(OK)
            
            //            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
            
            UtilityClass.presentOverAlert(vc: alert)
        })
    }
    
    func onReceiveDriverLocationToPassenger() {
        
        self.socket.on(SocketData.kReceiveDriverLocationToPassenger, callback: { (data, ack) in
            print("onReceiveDriverLocationToPassenger() is \(data)")
            
            SingletonClass.sharedInstance.driverLocation = (data as NSArray).object(at: 0) as! [String : AnyObject]
            
            var lati = Double()
            var lng = Double()
            
            if let doubleAry = SingletonClass.sharedInstance.driverLocation["Location"]! as? [Double] {
                lati = doubleAry.first ?? 23.0733308
                lng = doubleAry[1]
            }
            else if let stringAry = SingletonClass.sharedInstance.driverLocation["Location"]! as? [String] {
                lati = Double(stringAry.first ?? "23.0733308") ?? 23.0733308
                lng = Double(stringAry[1]) ?? 72.5145669
            }
            
            var DriverCordinate = CLLocationCoordinate2D(latitude: lati , longitude: lng )
            
            let camera = GMSCameraPosition.camera(withLatitude: DriverCordinate.latitude,longitude: DriverCordinate.longitude, zoom: 17)
            self.mapView.animate(to: camera)
            
            if let _ = self.driverMarker?.map { // RJ Change
                self.driverMarker.map = self.mapView
            }
            
            DriverCordinate = CLLocationCoordinate2DMake(DriverCordinate.latitude, DriverCordinate.longitude)
            
            if(self.destinationCordinate == nil)
            {
                self.destinationCordinate = CLLocationCoordinate2DMake(DriverCordinate.latitude, DriverCordinate.longitude)
            }
            
            if self.driverMarker == nil {
                
                self.driverMarker = GMSMarker(position: DriverCordinate) // self.originCoordinate
                
                self.driverMarker.map = self.mapView
                
                // Bhavesh changes 2-1-2019
                self.driverMarker.icon = UIImage(named: "dummyCar") //  UIImage(named: self.markerCarIconName(modelId: vehicleID))
            }
            
            if let bearing = SingletonClass.sharedInstance.driverLocation["bearing"] as? String {
                SingletonClass.sharedInstance.floatBearing = Float(bearing) ?? SingletonClass.sharedInstance.floatBearing
            }
            self.moveMent.ARCarMovement(marker: self.driverMarker, oldCoordinate: self.destinationCordinate, newCoordinate: DriverCordinate, mapView: self.mapView, bearing: Float(SingletonClass.sharedInstance.floatBearing))
            self.destinationCordinate = DriverCordinate
            print("The degree is \(SingletonClass.sharedInstance.floatBearing)")
            self.MarkerCurrntLocation.isHidden = true
            
            self.checkRouteOnMap(DriverCordinate: DriverCordinate)
            
        })
        
        
    }
    
    
    func checkRouteOnMap(DriverCordinate : CLLocationCoordinate2D)
    {
        if self.arrivedRoutePath != nil {
            
            if (GMSGeometryIsLocationOnPathTolerance(self.driverMarker.position, self.arrivedRoutePath!, true, 200) == false)
            {
                if self.dictCurrentBookingInfoData.count != 0 {
                    
                    if let dictBookingData = self.dictCurrentBookingInfoData as? [String:Any]
                    {
                        if dictBookingData.count != 0 {
                            
                            self.mapView.clear()
                            
                            if self.driverMarker == nil {
                                self.driverMarker = GMSMarker(position: DriverCordinate)
                                self.driverMarker.map = self.mapView
                                self.driverMarker.icon = UIImage(named: "dummyCar")
                            }
                            
                            //Rahul
                            if(SingletonClass.sharedInstance.dictDriverProfile.count != 0) {
                                
                                let PickupLat = self.driverMarker.position.latitude  // Double("\(strLat )")
                                let PickupLng = self.driverMarker.position.longitude // Double("\(strLng )")
                                
                                let DropOffLat = Double("\(dictBookingData["DropOffLat"] ?? "0" )")
                                let DropOffLon = Double("\(dictBookingData["DropOffLon"] ?? "0" )")
                                
                                let tempLat = Double("\(dictBookingData["PickupLat"] ?? "0" )")
                                let tempLon = Double("\(dictBookingData["PickupLng"] ?? "0" )")
                                
                                let originalLoc: String = "\(PickupLat ),\(PickupLng)"
                                var destiantionLoc: String = "\(DropOffLat ?? 0),\(DropOffLon ?? 0)"
                                
                                if !SingletonClass.sharedInstance.isTripContinue {
                                    destiantionLoc = "\(tempLat ?? 0),\(tempLon ?? 0)"
                                }
                                
                                
                                DispatchQueue.main.async {
                                    
                                    self.setDirectionLineOnMapForSourceAndDestinationShow(origin: originalLoc, destination: destiantionLoc, completionHandler: nil)
                                    
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    /*func onReceiveDriverLocationToPassenger() {
     
     self.socket.on(SocketData.kReceiveDriverLocationToPassenger, callback: { (data, ack) in
     print("onReceiveDriverLocationToPassenger() is \(data)")
     
     if SingletonClass.sharedInstance.bookingId != "" {
     SingletonClass.sharedInstance.driverLocation = (data as NSArray).object(at: 0) as! [String : AnyObject]
     
     var DoubleLat = Double()
     var DoubleLng = Double()
     
     if let lat = SingletonClass.sharedInstance.driverLocation["Location"]! as? [Double] {
     DoubleLat = lat[0]
     DoubleLng = lat[1]
     }
     else if let lat = SingletonClass.sharedInstance.driverLocation["Location"]! as? [String] {
     DoubleLat = Double(lat[0])!
     DoubleLng = Double(lat[1])!
     }
     
     let DriverCordinate = CLLocationCoordinate2D(latitude: DoubleLat , longitude: DoubleLng)
     
     //                DriverCordinate = CLLocationCoordinate2DMake(DriverCordinate.latitude, DriverCordinate.longitude)
     
     if(self.destinationCordinate == nil)
     {
     self.destinationCordinate = CLLocationCoordinate2DMake(DriverCordinate.latitude, DriverCordinate.longitude)
     }
     
     if self.driverMarker == nil {
     self.driverMarker = GMSMarker(position: DriverCordinate) // self.originCoordinate
     self.driverMarker.map = self.mapView
     }
     
     //                let distanceInMeters = self.destinationCordinate.distance(from: DriverCordinate) // result is in meters
     //                // print("the distance in meters is \(distanceInMeters)")
     let degrees = self.destinationCordinate.bearing(to: DriverCordinate)
     let clLocation = CLLocation(latitude: DriverCordinate.latitude, longitude: DriverCordinate.longitude)
     
     var kmh = clLocation.speed / 1000.0 * 60.0 * 60.0
     if(kmh < 0) {
     kmh = 0
     }
     print("\nThe speed of Driver is \(kmh)\n")
     //                if(kmh > 4)
     //                {
     self.moveMent.ARCarMovement(marker: self.driverMarker, oldCoordinate: self.destinationCordinate, newCoordinate: DriverCordinate, mapView: self.mapView, bearing: Float(SingletonClass.sharedInstance.floatBearing))
     //                }
     self.driverMarker.icon = UIImage(named:"dummyCar")
     
     self.destinationCordinate = DriverCordinate
     self.MarkerCurrntLocation.isHidden = true
     
     
     let camera = GMSCameraPosition.camera(withLatitude: DriverCordinate.latitude,longitude: DriverCordinate.longitude, zoom: 17)
     self.mapView.animate(to: camera)
     self.driverMarker.map = self.mapView
     // ***********************************************
     // ***********************************************
     
     /*if self.arrivedRoutePath != nil {
     
     if GMSGeometryIsLocationOnPathTolerance(self.driverMarker.position, self.arrivedRoutePath!, true, 200) { // GMSGeometryContainsLocation(self.driverMarker.position, self.arrivedRoutePath!, true) {
     //                        // print("GMSGeometryIsLocationOnPathTolerance = true")
     } else {
     //                        // print("GMSGeometryIsLocationOnPathTolerance = false")
     
     if self.aryBookingDropoffInfo.count != 0 {
     
     let aryFilterData = self.aryBookingDropoffInfo.filter{$0["Status"] as! String == "" }
     if aryFilterData.count != 0 {
     
     self.mapView.clear()
     
     //                                if self.driverMarker == nil {
     //                                    self.driverMarker = GMSMarker(position: DriverCordinate) // self.originCoordinate
     //                                    self.driverMarker.map = self.mapView
     //                                }
     
     if self.driverMarker == nil {
     self.driverMarker = GMSMarker(position: DriverCordinate)
     self.driverMarker.map = self.mapView
     self.driverMarker.icon = UIImage(named: "dummyCar")
     }
     //                                else {
     //                                    self.driverMarker.position = DriverCordinate
     //                                }
     
     //Rahul
     if(SingletonClass.sharedInstance.dictDriverProfile.count != 0) {
     
     let PickupLat = self.driverMarker.position.latitude  // Double("\(strLat )")
     let PickupLng = self.driverMarker.position.longitude // Double("\(strLng )")
     
     let DropOffLat = Double("\(aryFilterData.first?["DropOffLat"]! ?? "0")")
     let DropOffLon = Double("\(aryFilterData.first?["DropOffLng"]! ?? "0")")
     
     let tempLat = Double("\(aryFilterData.first?["PickupLat"]! ?? "0")")
     let tempLon = Double("\(aryFilterData.first?["PickupLng"]! ?? "0")")
     
     let originalLoc: String = "\(PickupLat ),\(PickupLng)"
     var destiantionLoc: String = "\(DropOffLat ?? 0),\(DropOffLon ?? 0)"
     
     if !SingletonClass.sharedInstance.isTripContinue {
     destiantionLoc = "\(tempLat ?? 0),\(tempLon ?? 0)"
     }
     
     let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: PickupLat , longitude: PickupLng ), coordinate: CLLocationCoordinate2D(latitude: DropOffLat ?? 0, longitude: DropOffLon ?? 0))
     let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(150))
     
     self.mapView.animate(with: update)
     self.mapView.moveCamera(update)
     //                        self.setDirectionLineOnMapForSourceAndDestinationShow(origin: originalLoc, destination: destiantionLoc, waypoints: nil, completionHandler: nil)
     
     
     DispatchQueue.main.async {
     if SingletonClass.sharedInstance.isTripContinue {
     self.setDirectionLineOnMapForSourceAndDestinationShow(origin: originalLoc, destination: destiantionLoc, isFromArrivedReq: false, isFromStartTrip: true, waypoints: nil, completionHandler: nil)
     } else {
     self.setDirectionLineOnMapForSourceAndDestinationShow(origin: originalLoc, destination: destiantionLoc, isFromArrivedReq: true, waypoints: nil, completionHandler: nil)
     }
     }
     }
     }
     }
     }
     }*/
     
     // ***********************************************
     // ***********************************************
     }
     })
     }*/
    
    func onReceiveNotificationWhenDriverAcceptRequest() {
        
        self.socket.on(SocketData.kAcceptAdvancedBookingRequestNotify, callback: { (data, ack) in
            // print("onReceiveNotificationWhenDriverAcceptRequest is \(data)")
            
            var bookingId = String()
            
            if let bookingInfoData = (data as! [[String:AnyObject]])[0]["BookingInfo"] as? [[String:AnyObject]] {
                if let bookingInfo = bookingInfoData[0]["Id"] as? Int {
                    bookingId = "\(bookingInfo)"
                }
                else if let bookingInfo = bookingInfoData[0]["Id"] as? String {
                    bookingId = bookingInfo
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    
                    if SingletonClass.sharedInstance.bookingId == bookingId {
                        var message = String()
                        message = "Trip on Hold"
                        
                        if let resAry = NSArray(array: data) as? NSArray {
                            message = (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String
                        }
                        
                        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                        let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(OK)
                        //                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                        UtilityClass.presentOverAlert(vc: alert)
                    }
                }
                else {
                    var message = String()
                    message = "Trip on Hold"
                    
                    if let resAry = NSArray(array: data) as? NSArray {
                        message = (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String
                    }
                    
                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(OK)
                    //                    (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                    
                    UtilityClass.presentOverAlert(vc: alert)
                    
                }
            }
            
        })
        
    }
    
    func onAdvanceTripInfoBeforeStartTrip() {
        
        self.socket.on(SocketData.kInformPassengerForAdvancedTrip, callback: { (data, ack) in
            // print("onAdvanceTripInfoBeforeStartTrip() is \(data)")
            
            var message = String()
            message = "Trip on Hold"
            
            if let resAry = NSArray(array: data) as? NSArray {
                message = (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String
                
            }
            
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alert.addAction(OK)
            
            //            (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
            UtilityClass.presentOverAlert(vc: alert)
        })
        
    }
    
    func onGetEstimateFare() {
        
        self.socket.on(SocketData.kReceiveGetEstimateFare, callback: { (data, ack) in
            print("onGetEstimateFare() is \(data)")
            
            var estimateData = (data as! [[String:AnyObject]])
            estimateData =  estimateData[0]["estimate_fare"] as! [[String:AnyObject]]
            
            let sortedArray = estimateData.sorted {($0["sort"] as! Int) < ($1["sort"] as! Int)}
            var newArray = [[String:Any]]()
            self.arrNumberOfOnlineCars = NSMutableArray(array: sortedArray)
            self.arrTotalNumberOfCars = NSMutableArray(array: sortedArray).mutableCopy() as! NSMutableArray
            
            //            self.setData()
            if(self.valueTMCardHolde == 1)
            {
                //                let arraySlice = sortedArray.suffix(2)
                //                let newArray = Array(arraySlice)
                newArray = sortedArray.filter({ (dictionary) -> Bool in
                    if let value = dictionary["ReferenceId"] as? Int{
                        return value != 0
                    }
                    return false
                })
                self.arrTotalNumberOfCars.removeAllObjects()
                self.arrTotalNumberOfCars = NSMutableArray(array: newArray).mutableCopy() as! NSMutableArray
                self.arrNumberOfOnlineCars = self.arrTotalNumberOfCars.mutableCopy() as! NSMutableArray
//                self.setData()
            }
            else
            {
                newArray = sortedArray.filter({ (dictionary) -> Bool in
                    if let value = dictionary["ReferenceId"] as? Int{
                        return value == 0
                    }
                    return false
                })
                self.arrTotalNumberOfCars.removeAllObjects()
                self.arrTotalNumberOfCars = NSMutableArray(array: newArray).mutableCopy() as! NSMutableArray
                self.arrNumberOfOnlineCars = self.arrTotalNumberOfCars.mutableCopy() as! NSMutableArray
//                self.setData()
            }
            
           
            
            if self.aryEstimateFareData == self.aryEstimateFareData {
                
                let ary1 = self.aryEstimateFareData as! [[String:AnyObject]]
                let ary2 = sortedArray
                
                for i in 0..<self.aryEstimateFareData.count {
                    
                    let dict1 = ary1[i] as NSDictionary
                    let dict2 = ary2[i] as NSDictionary
                    
                    if dict1 != dict2 {
                        
//                        UIView.performWithoutAnimation {
//                            self.collectionViewCars.reloadData()
//                        }
                    }
                    
                }
                
                
            }
            self.aryEstimateFareData.removeAllObjects()
            self.aryEstimateFareData = NSMutableArray(array: newArray).mutableCopy() as! NSMutableArray
            self.setData()
//            self.aryEstimateFareData = NSMutableArray(array: sortedArray as NSArray)
//            if(self.valueTMCardHolde == 1)
//            {
          
//            }
            var count = Int()
            for i in 0..<self.arrNumberOfOnlineCars.count
            {
                let dictOnlineCarData = (self.arrNumberOfOnlineCars.object(at: i) as! NSDictionary)
                count = count + (dictOnlineCarData["carCount"] as? Int ?? 0)
                if (count == 0)
                {
                    
                    if(self.arrNumberOfOnlineCars.count == 0)
                    {
                        
                        let alert = UIAlertController(title: appName,
                                                      message: "Book Now cars not available. Please click OK to Book Later.",
                                                      preferredStyle: UIAlertController.Style.alert)
                        
                        
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.btnBookLater((Any).self)
                        }))
                        
                        
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { (action) in
                        }))
                        
                        
                        //                        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(alert, animated: true, completion: nil)
                        UtilityClass.presentOverAlert(vc: alert)
                    }
                    
                }
            }
            
            
            
            UIView.performWithoutAnimation {
                self.collectionViewCars.reloadData()
            }
            
            
        })
    }
    
    func onBookingDetailsAfterCompletedTrip() {
        
        self.socket.on(SocketData.kAdvancedBookingDetails, callback: { (data, ack) in
            // print("onBookingDetailsAfterCompletedTrip() is \(data)")
            
            SingletonClass.sharedInstance.isTripContinue = false
            
            self.aryCompleterTripData = data
            
            //            self.viewMainFinalRating.isHidden = false
            
            var bookingId = String()
            if let bookingData = data as? [[String:AnyObject]] {
                
                if let info = bookingData[0]["Info"] as? [[String:AnyObject]] {
                    
                    if let infoId = info[0]["Id"] as? String {
                        bookingId = infoId
                    }
                    else if let infoId = info[0]["Id"] as? Int {
                        bookingId = "\(infoId)"
                    }
                    
                    if SingletonClass.sharedInstance.bookingId != "" {
                        if SingletonClass.sharedInstance.bookingId == bookingId {
                            
                            if (SingletonClass.sharedInstance.passengerTypeOther) {
                                
                                SingletonClass.sharedInstance.passengerTypeOther = false
                                self.completeTripInfo()
                            }
                            else {
                                self.completeTripInfo()
                                //                let next = self.storyboard?.instantiateViewController(withIdentifier: "GiveRatingViewController") as! GiveRatingViewController
                                //                next.strBookingType = self.strBookingType
                                //                next.delegate = self
                                //                //            self.presentingViewController?.modalPresentationStyle
                                //                self.present(next, animated: true, completion: nil)
                            }
                        }
                    }
                    
                }
                
            }
        })
    }
    
    func socketMethodForGettingBookingRejectNotificatioByDriver()
    {
        // Socket Accepted
        self.socket.on(SocketData.kCancelTripByDriverNotficication, callback: { (data, ack) in
            // print("socketMethodForGettingBookingRejectNotificatioByDriver() is \(data)")
            // Restarting Timer For updating Passenger location which was stopped on STart trip
            self.timerForUpdatingPassengerLocation()
            /////
            self.CancellationFee = ""
            var bookingId = String()
            
            if let bookingInfoData = (data as! [[String:AnyObject]])[0]["BookingInfo"] as? [[String:AnyObject]] {
                if let bookingInfo = bookingInfoData[0]["Id"] as? Int {
                    bookingId = "\(bookingInfo)"
                }
                else if let bookingInfo = bookingInfoData[0]["Id"] as? String {
                    bookingId = bookingInfo
                }
                
                if SingletonClass.sharedInstance.bookingId != "" {
                    if SingletonClass.sharedInstance.bookingId == bookingId {
                        self.viewActivity.stopAnimating()
                        self.viewMainActivityIndicator.isHidden = true
                        self.currentLocationAction()
                        self.getPlaceFromLatLong()
                        self.clearDataAfteCompleteTrip()
                        self.currentLocationAction()
                        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                        self.setClearTextFieldsOfExtra()
                        self.timerToUpdatePassengerLocation?.invalidate()
                        self.timerToGetDriverLocation?.invalidate()
                        self.viewTripActions.isHidden = true
                        SingletonClass.sharedInstance.passengerTypeOther = false
                        SingletonClass.sharedInstance.bookingId = ""
                        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                        UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                            //                            self.strBookingType = ""
                            self.btnDoneForLocationSelected.isHidden = false
                        })
                    }
                } else {
                    self.viewActivity.stopAnimating()
                    self.viewMainActivityIndicator.isHidden = true
                    self.currentLocationAction()
                    self.getPlaceFromLatLong()
                    self.clearDataAfteCompleteTrip()
                    self.currentLocationAction()
                    self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                    
                    self.viewTripActions.isHidden = true
                    SingletonClass.sharedInstance.passengerTypeOther = false
                    self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                    UtilityClass.setCustomAlert(title: "\(appName)", message: (data as! [[String:AnyObject]])[0]["message"]! as! String, completionHandler: { (index, title) in
                        //                        self.strBookingType = ""
                        self.btnDoneForLocationSelected.isHidden = false
                    })
                }
                
                self.btnPointToPoint(self.btnPointToPoint)
            }
        })
    }
    
    func onGetChetMessage() {
        
        self.socket.on(SocketData.kReceiveMessage) { (data, ack) in
            // print(#function,": \(data)")
            
            if let aryData = data as? [[String:Any]] {
                
                if aryData.count != 0 {
                    
                    let obj = MessageObject()
                    obj.bookingId = aryData.first!["BookingId"] as? String
                    obj.date = aryData.first!["Date"] as? String
                    obj.message = aryData.first!["Message"] as? String
                    obj.strMessage = (aryData.first!["Message"] as? String)!
                    obj.receiver = aryData.first!["Receiver"] as? String
                    obj.receiverId = aryData.first!["ReceiverId"] as? String
                    
                    obj.sender = aryData.first!["Sender"] as? String
                    obj.senderId = aryData.first!["SenderId"] as? String
                    obj.type = aryData.first!["Type"] as? String
                    obj.isSender = false
                    
                    if SingletonClass.sharedInstance.strChatingNowBookingId == aryData.first!["BookingId"] as? String {
                        
                        SingletonClass.sharedInstance.ChattingMessages = obj
                        NotificationCenter.default.post(name: NotificationgetResponseOfChatting, object: nil)
                    }
                    
                    if ((((UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! UINavigationController).visibleViewController as? ChatViewController) != nil) || SingletonClass.sharedInstance.isChatingPresented {
                        return
                    }
                    
                    // ----------------------------------------------------------
                    // Chating POP UP
                    // ----------------------------------------------------------
                    
                    let view = MessageView.viewFromNib(layout: .cardView)
                    view.configureTheme(.warning)
                    view.configureDropShadow()
                    view.button?.isHidden = false
                    view.button?.setTitle("GO", for: .normal)
                    //                    view.button?.backgroundColor = UIColor.clear
                    //                    view.button?.tintColor = UIColor.clear
                    
                    view.iconImageView?.image = UIImage(named: "iconLogoWithText")
                    //                        let iconText = ["🤔", "😳", "🙄", "😶"].sm_random()!
                    view.configureContent(title: obj.sender!, body: obj.strMessage, iconText: "")
                    view.layoutMarginAdditions = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
                    view.backgroundView.cornerRadius = 10
                    
                    view.buttonTapHandler = { _ in
                        
                        self.openChatMessanger(bookingType: obj.type!, bookingId: obj.bookingId!)
                    }
                    SwiftMessages.show(view: view)
                    
                    // ----------------------------------------------------------
                }
            }
        }
    }
    
    
    func stopUpdatingPassengerLocationTimer()
    {
        if(timerToUpdatePassengerLocation != nil)
        {
            timerToUpdatePassengerLocation?.invalidate()
            timerToUpdatePassengerLocation = nil
        }
    }
    
    func openChatMessanger(bookingType: String, bookingId: String) {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        next.strBookingId = bookingId
        next.strBookingType = bookingType
        //        self.present(next, animated: true, completion: nil)
        UtilityClass.presentOverAlert(vc: next)
    }
}

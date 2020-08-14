//
//  HomeVCDrawGoogleMapOnHomeScreen.swift
//  MyRickshaw User
//
//  Created by Excelent iMac on 05/06/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces
import SocketIO
import SDWebImage
import NVActivityIndicatorView





extension HomeViewController {
    
    //-------------------------------------------------------------
    // MARK: - Draw Google Map Trip Methods
    //-------------------------------------------------------------
    
    
    // ------------------------------------------------------------
    func getDirectionsSeconMethod(origin: String!, destination: String!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?)
    {
        
        clearMap()
        
//        MarkerCurrntLocation.isHidden = true
        self.MarkerCurrntLocation.isHidden = true
        self.btnDoneForLocationSelected.isHidden = true
        
        UtilityClass.showACProgressHUD()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            
            if let originLocation = origin {
                if let destinationLocation = destination {
                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + googleMapAddress //googlApiKey
//                    if let routeWaypoints = waypoints {
//                        directionsURLString += "&waypoints=optimize:true"
//
//                        for waypoint in routeWaypoints {
//                            directionsURLString += "|" + waypoint
//                        }
//                    }
                    
                    // .addingPercentEscapes(using: String.Encoding.utf8)!
                    
                     print("directionsURLString: \(directionsURLString)")
                    
                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    
                    
                    // .addingPercentEscapes(using: String.Encoding.utf8)!
                    let directionsURL = NSURL(string: directionsURLString)
                    DispatchQueue.main.async( execute: { () -> Void in
                        let directionsData = NSData(contentsOf: directionsURL! as URL)
                        do{
                            let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                            
                            let status = dictionary["status"] as! String
                            
                            if status == "OK" {
                                self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                                self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                                
                                let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                                
                                let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                
                                let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                
                                self.locationManager.startUpdatingLocation()
                                self.MarkerCurrntLocation.isHidden = true
                                self.btnDoneForLocationSelected.isHidden = true
                                
                                let originAddress = legs[0]["start_address"] as! String
                                let destinationAddress = legs[legs.count - 1]["end_address"] as! String
                                //                                if(SingletonClass.sharedInstance.isTripContinue)
                                //                                {
                                if self.driverMarker == nil {
                                    
                                    self.driverMarker = GMSMarker(position: self.originCoordinate) // self.originCoordinate
                                    self.driverMarker.map = self.mapView
                                    var vehicleID = Int()
                                    //                                    var vehicleID = Int()
                                    if let vID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? Int {
                                        
                                        if vID == 0 {
                                            vehicleID = 7
                                        }
                                        else {
                                            vehicleID = vID
                                        }
                                    }
                                    else if let sID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? String
                                    {
                                        
                                        if sID == "" {
                                            vehicleID = 7
                                        }
                                        else {
                                            vehicleID = Int(sID)!
                                        }
                                    }
                                    
                                    // Bhavesh changes 2-1-2019
                                    self.driverMarker.icon = UIImage(named: "dummyCar") //  UIImage(named: self.markerCarIconName(modelId: vehicleID))
                                    
                                    self.driverMarker.title = originAddress
                                }
                                
                                let destinationMarker = GMSMarker(position: self.destinationCoordinate)// self.destinationCoordinate  // self.destinationCoordinate
                                destinationMarker.map = self.mapView
                                destinationMarker.icon = UIImage(named: "iconCurrentLocation") // GMSMarker.markerImage(with: UIColor.red)
//                                destinationMarker.title = destinationAddress
                                
                                
                                var aryDistance = [String]()
                                var finalDistance = Double()
                                
                                
                                for i in 0..<legs.count
                                {
                                    let legsData = legs[i]
                                    let distanceKey = legsData["distance"] as! Dictionary<String, AnyObject>
                                    let distance = distanceKey["text"] as! String
                                    //                                    print(distance)
                                    
                                    let stringDistance = distance.components(separatedBy: " ")
                                    //                                    print(stringDistance)
                                    
                                    if stringDistance[1] == "m"
                                    {
                                        finalDistance += Double(stringDistance[0])! / 1000
                                    }
                                    else
                                    {
                                        finalDistance += Double(stringDistance[0].replacingOccurrences(of: ",", with: ""))!
                                    }
                                    
                                    aryDistance.append(distance)
                                    
                                }
                                
                                if finalDistance == 0 {
                                    
                                }
                                else
                                {
                                    self.sumOfFinalDistance = finalDistance
                                    
                                    
                                }
                                
                                let route = self.overviewPolyline["points"] as! String
                                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                                let routePolyline = GMSPolyline(path: path)
                                routePolyline.map = self.mapView
                                routePolyline.strokeColor = themeYellowColor
                                routePolyline.strokeWidth = 3.0
                                
                                
                                
                                UtilityClass.hideACProgressHUD()
                                
                                //                                UtilityClass.showAlert("", message: "Line Drawn", vc: self)
                                
                                print("Line Drawn")
                                
                            }
                            else {
                                print("status")
                                UtilityClass.hideACProgressHUD()
//                                self.getDirectionsSeconMethod(origin: origin, destination: destination, waypoints: waypoints, travelMode: nil, completionHandler: nil)
                                UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, due to OVER_QUERY_LIMIT") { (index, title) in
                                }
                                print("OVER_QUERY_LIMIT")
                            }
                        }
                        catch {
                            print("catch")
                            
                            
                            UtilityClass.hideACProgressHUD()
                            
                            UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, please restart app") { (index, title) in
                            }
                            // completionHandler(status: "", success: false)
                        }
                    })
                }
                else {
                    print("Destination is nil.")
                    
                    UtilityClass.hideACProgressHUD()
                    
                    UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location Destination, please restart app") { (index, title) in
                    }
                    //completionHandler(status: "Destination is nil.", success: false)
                }
            }
            else {
                print("Origin is nil")
                
                UtilityClass.hideACProgressHUD()
                
                UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location Origin, please restart app") { (index, title) in
                }
                //completionHandler(status: "Origin is nil", success: false)
            }
        }
    }
    
    // ----------------------------------------------------------------------
    // ----------------------------------------------------------------------
    
    func changePolyLine(origin: String!, destination: String!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?)
    {
        
        self.MarkerCurrntLocation.isHidden = true
        self.btnDoneForLocationSelected.isHidden = true
        
        if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + googleMapAddress //googlApiKey
//                if let routeWaypoints = waypoints {
//                    directionsURLString += "&waypoints=optimize:true"
//
//                    for waypoint in routeWaypoints {
//                        directionsURLString += "|" + waypoint
//                    }
//                }
                
                directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                
                print("directionsURLString: \(directionsURLString)")
                
                let directionsURL = NSURL(string: directionsURLString)
                DispatchQueue.main.async( execute: { () -> Void in
                    let directionsData = NSData(contentsOf: directionsURL! as URL)
                    do{
                        let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                        
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                            
                            self.locationManager.startUpdatingLocation()
                            self.MarkerCurrntLocation.isHidden = true
                            self.btnDoneForLocationSelected.isHidden = true
                            
                            
                            self.demoPolylineOLD = self.routePolyline
                            self.demoPolylineOLD.strokeColor = themeYellowColor
                            self.demoPolylineOLD.strokeWidth = 3.0
                            self.demoPolylineOLD.map = self.mapView
                            self.routePolyline.map = nil
                            
                            let route = self.overviewPolyline["points"] as! String
                            let path: GMSPath = GMSPath(fromEncodedPath: route)!
                            self.routePolyline = GMSPolyline(path: path)
                            self.routePolyline.map = self.mapView
                            self.routePolyline.strokeColor = themeYellowColor
                            self.routePolyline.strokeWidth = 3.0
                            self.demoPolylineOLD.map = nil
                            print("Line Drawn")
                            
                        }
                        else {
                            print("status")
                            UtilityClass.hideACProgressHUD()
//                            self.changePolyLine(origin: origin, destination: destination, waypoints: waypoints, travelMode: nil, completionHandler: nil)
                            UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, due to OVER_QUERY_LIMIT") { (index, title) in
                            }
                            print("changePolyLine OVER_QUERY_LIMIT")
                        }
                    }
                    catch {
                        print("catch")
                        
                        
                        UtilityClass.hideACProgressHUD()
                        
                        UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, please restart app") { (index, title) in
                        }
                        // completionHandler(status: "", success: false)
                    }
                })
            }
            else {
                print("Destination is nil.")
                
                UtilityClass.hideACProgressHUD()
                
                UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location Destination, please restart app") { (index, title) in
                }
                //completionHandler(status: "Destination is nil.", success: false)
            }
        }
        else {
            print("Origin is nil")
            
            UtilityClass.hideACProgressHUD()
            
            UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location Origin, please restart app") { (index, title) in
            }
            //completionHandler(status: "Origin is nil", success: false)
        }
    }
    
    // ----------------------------------------------------------------------
    // ----------------------------------------------------------------------
    
    func getDirectionsAcceptRequest(origin: String!, destination: String!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?)
    {
        
        clearMap()
        
        self.MarkerCurrntLocation.isHidden = true
        self.btnDoneForLocationSelected.isHidden = true
        
        UtilityClass.showACProgressHUD()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            
            if let originLocation = origin {
                if let destinationLocation = destination {
                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + googleMapAddress //googlApiKey
//                    if let routeWaypoints = waypoints {
//                        directionsURLString += "&waypoints=optimize:true"
//
//                        for waypoint in routeWaypoints {
//                            directionsURLString += "|" + waypoint
//                        }
//                    }
                    
                    // .addingPercentEscapes(using: String.Encoding.utf8)!
                    
                     print("directionsURLString: \(directionsURLString)")
                    
                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    
                    
                    // .addingPercentEscapes(using: String.Encoding.utf8)!
                    let directionsURL = NSURL(string: directionsURLString)
                    DispatchQueue.main.async( execute: { () -> Void in
                        let directionsData = NSData(contentsOf: directionsURL! as URL)
                        do{
                            let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                            
                            let status = dictionary["status"] as! String
                            
                            if status == "OK" {
                                self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                                self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                                
                                let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                                
                                
                                
                                let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                
                                let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                
                                self.locationManager.startUpdatingLocation()
                                self.MarkerCurrntLocation.isHidden = true
                                self.btnDoneForLocationSelected.isHidden = true
                                
                                let originAddress = legs[0]["start_address"] as! String
                                let destinationAddress = legs[legs.count - 1]["end_address"] as! String
                                if(SingletonClass.sharedInstance.isTripContinue)
                                {
                                    if self.driverMarker == nil {
                                        
                                        self.driverMarker = GMSMarker(position: self.destinationCoordinate) // self.originCoordinate
                                        self.driverMarker.map = self.mapView
                                        var vehicleID = Int()
                                        //                                    var vehicleID = Int()
                                        if let vID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? Int {
                                            
                                            if vID == 0 {
                                                vehicleID = 7
                                            }
                                            else {
                                                vehicleID = vID
                                            }
                                        }
                                        else if let sID = SingletonClass.sharedInstance.dictCarInfo["VehicleModel"] as? String
                                        {
                                            
                                            if sID == "" {
                                                vehicleID = 7
                                            }
                                            else {
                                                vehicleID = Int(sID)!
                                            }
                                        }
                                        // Bhavesh changes 2-1-2019
                                        self.driverMarker.icon = UIImage(named: "dummyCar") //  UIImage(named: self.markerCarIconName(modelId: vehicleID))
                                        
//                                        self.driverMarker.title = originAddress
                                    }
                                    
                                }
                                
                                let destinationMarker = GMSMarker(position: self.originCoordinate)// self.destinationCoordinate  // self.destinationCoordinate
                                destinationMarker.map = self.mapView
                                destinationMarker.icon = UIImage(named: "iconCurrentLocation") // GMSMarker.markerImage(with: UIColor.red)
//                                destinationMarker.title = destinationAddress
                                
                                
                                var aryDistance = [String]()
                                var finalDistance = Double()
                                
                                
                                for i in 0..<legs.count
                                {
                                    let legsData = legs[i]
                                    let distanceKey = legsData["distance"] as! Dictionary<String, AnyObject>
                                    let distance = distanceKey["text"] as! String
                                    //                                    print(distance)
                                    
                                    let stringDistance = distance.components(separatedBy: " ")
                                    //                                    print(stringDistance)
                                    
                                    if stringDistance[1] == "m"
                                    {
                                        finalDistance += Double(stringDistance[0])! / 1000
                                    }
                                    else
                                    {
                                        finalDistance += Double(stringDistance[0].replacingOccurrences(of: ",", with: ""))!
                                    }
                                    
                                    aryDistance.append(distance)
                                    
                                }
                                
                                if finalDistance == 0 {
                                    
                                }
                                else
                                {
                                    self.sumOfFinalDistance = finalDistance
                                    
                                    
                                }
                                
                                let route = self.overviewPolyline["points"] as! String
                                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                                let routePolyline = GMSPolyline(path: path)
                                routePolyline.map = self.mapView
                                routePolyline.strokeColor = themeYellowColor
                                routePolyline.strokeWidth = 3.0
                                
                                UtilityClass.hideACProgressHUD()
                                
                                //                                UtilityClass.showAlert("", message: "Line Drawn", vc: self)
                                
                                print("Line Drawn")
                                
                            }
                            else {
                                print("status")
                                UtilityClass.hideACProgressHUD()
//                                self.getDirectionsAcceptRequest(origin: origin, destination: destination, waypoints: waypoints, travelMode: nil, completionHandler: nil)
                                UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, due to OVER_QUERY_LIMIT") { (index, title) in
                                }
                                print("OVER_QUERY_LIMIT")
                            }
                        }
                        catch {
                            print("catch")
                            
                            
                            UtilityClass.hideACProgressHUD()
                            
                            UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, please restart app") { (index, title) in
                            }
                            // completionHandler(status: "", success: false)
                        }
                    })
                }
                else {
                    print("Destination is nil.")
                    
                    UtilityClass.hideACProgressHUD()
                    
                    UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get Destination location, please restart app") { (index, title) in
                    }
                    //completionHandler(status: "Destination is nil.", success: false)
                }
            }
            else {
                print("Origin is nil")
                
                UtilityClass.hideACProgressHUD()
                
                UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get  Origin location, please restart app") { (index, title) in
                }
                //completionHandler(status: "Origin is nil", success: false)
            }
        }
    }
    
    // ----------------------------------------------------------------------
    // ----------------------------------------------------------------------
    
    func setDirectionLineOnMapForSourceAndDestinationShow(origin: String!, destination: String!, completionHandler: ((_ status:   String, _ success: Bool) -> Void)?)
    {
        //        clearMap()
        //        UtilityClass.showACProgressHUD()
        //
        //        self.routePolyline.map = nil
        
        self.MarkerCurrntLocation.isHidden = true
        self.btnDoneForLocationSelected.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            
            if let originLocation = origin {
                if let destinationLocation = destination {
                    var directionsURLString = self.baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation + "&key=" + googleMapAddress //googlApiKey
//                    if let routeWaypoints = waypoints {
//                        directionsURLString += "&waypoints=optimize:true"
//
//                        for waypoint in routeWaypoints {
//                            directionsURLString += "|" + waypoint
//                        }
//                    }
                    
                    directionsURLString = directionsURLString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    
                    print("directionsURLString: \(directionsURLString)")
                    
                    let directionsURL = NSURL(string: directionsURLString)
                    DispatchQueue.main.async( execute: { () -> Void in
                        let directionsData = NSData(contentsOf: directionsURL! as URL)
                        do{
                            let dictionary: Dictionary<String, AnyObject> = try JSONSerialization.jsonObject(with: directionsData! as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as! Dictionary<String, AnyObject>
                            
                            let status = dictionary["status"] as! String
                            
                            if status == "OK" {
                                self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<String, AnyObject>>)[0]
                                self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<String, AnyObject>
                                
                                let legs = self.selectedRoute["legs"] as! Array<Dictionary<String, AnyObject>>
                                
                                let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                                self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                                
                                let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                                self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                                
                                self.locationManager.startUpdatingLocation()
                                self.MarkerCurrntLocation.isHidden = true
                                self.btnDoneForLocationSelected.isHidden = true
                                
                                //                                if SingletonClass.sharedInstance.isTripContinue {
                                
                                
                                // Set currentLocationMarker
                                self.currentLocationMarker = GMSMarker(position: self.originCoordinate) // destinationCoordinate
                                self.currentLocationMarker.map = self.mapView
//                                self.currentLocationMarker.snippet = self.currentLocationMarkerText
                                self.currentLocationMarker.icon = UIImage(named: "iconCurrentLocation")
                                //                                self.currentLocationMarker.isDraggable = true
                                
                                // Set destinationLocationMarker
                                self.destinationLocationMarker = GMSMarker(position: self.destinationCoordinate) // originCoordinate
                                self.destinationLocationMarker.map = self.mapView
//                                self.destinationLocationMarker.snippet = self.destinationLocationMarkerText
                                self.destinationLocationMarker.icon = UIImage(named: "iconCurrentLocation")
                                
                                //                                     }
                                
                                let route = self.overviewPolyline["points"] as! String
                                let path: GMSPath = GMSPath(fromEncodedPath: route)!
                                self.routePolyline = GMSPolyline(path: path)
                                self.routePolyline.map = self.mapView
                                self.routePolyline.strokeColor = themeYellowColor
                                self.routePolyline.strokeWidth = 3.0
                                
                                
                                UtilityClass.hideACProgressHUD()
                                
                                print("Line Drawn")
                                
                            }
                            else {
                                print("status")
                                //completionHandler(status: status, success: false)
                                UtilityClass.hideACProgressHUD()
//                                self.setDirectionLineOnMapForSourceAndDestinationShow(origin: origin, destination: destination, waypoints: waypoints, travelMode: nil, completionHandler: nil)
                                UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, due to OVER_QUERY_LIMIT") { (index, title) in
                                }
                                print("OVER_QUERY_LIMIT")
                            }
                        }
                        catch {
                            print("catch")
                            
                            
                            UtilityClass.hideACProgressHUD()
                            
                            UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get location data, please restart app") { (index, title) in
                            }
                            // completionHandler(status: "", success: false)
                        }
                    })
                }
                else {
                    print("Destination is nil.")
                    
                    UtilityClass.hideACProgressHUD()
                    
                    UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get Destination location, please restart app") { (index, title) in
                    }
                    //completionHandler(status: "Destination is nil.", success: false)
                }
            }
            else {
                print("Origin is nil")
                
                UtilityClass.hideACProgressHUD()
                
                UtilityClass.setCustomAlert(title: "\(appName)", message: "Not able to get  Origin location, please restart app") { (index, title) in
                }
                //completionHandler(status: "Origin is nil", success: false)
            }
        }
    }
    

}

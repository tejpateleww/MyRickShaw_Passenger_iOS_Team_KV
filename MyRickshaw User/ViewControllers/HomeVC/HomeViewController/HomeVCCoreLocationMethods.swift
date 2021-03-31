//
//  HomeVCCoreLocationMethods.swift
//  MyRickshaw User
//
//  Created by Excelent iMac on 05/06/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation
import CoreLocation
import GoogleMaps
import GooglePlaces


// Delegates to handle events for the location manager.
extension HomeViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        //        print("Location: \(location)")
        
        defaultLocation = location
        SingletonClass.sharedInstance.currentLatitude = "\(location.coordinate.latitude)"
        SingletonClass.sharedInstance.currentLongitude = "\(location.coordinate.longitude)"
        
        
        if(SingletonClass.sharedInstance.isFirstTimeDidupdateLocation)
        {
            SingletonClass.sharedInstance.isFirstTimeDidupdateLocation = false
        }
        
        if SingletonClass.sharedInstance.isTripContinue {
            let currentCordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            
            if(destinationCordinate == nil)
            {
                destinationCordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
            }
            
            
            if driverMarker == nil {
                driverMarker = GMSMarker(position: destinationCordinate)
                
                var vehicleID = Int()
                //                                    var vehicleID = Int()
                if SingletonClass.sharedInstance.dictCarInfo.count != 0 {
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
                    // Bhavesh changes in 2-1-2019 
                    self.driverMarker.icon = UIImage(named: "dummyCar") // UIImage(named: self.markerCarIconName(modelId: vehicleID))
                    
                }
                else {
                    driverMarker.icon = UIImage(named: "dummyCar") // UIImage(named: "iconActiveDriver") // driverMarker
                }
                
                
                driverMarker.map = mapView
            }
            
            //            self.moveMent.ARCarMovement(marker: driverMarker, oldCoordinate: destinationCordinate, newCoordinate: currentCordinate, mapView: mapView, bearing: Float(SingletonClass.sharedInstance.floatBearing))
            destinationCordinate = currentCordinate
            self.MarkerCurrntLocation.isHidden = true
        }
        
        
        if mapView.isHidden {
            mapView.isHidden = false
            self.getPlaceFromLatLong()
            self.socketMethods()
            
            mapView.delegate = self
            
//            let position = CLLocationCoordinate2D(latitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude)
            
            MarkerCurrntLocation.isHidden = false
            
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,longitude: location.coordinate.longitude, zoom: 17)
            mapView.animate(to: camera)
            
            
        }
        
//        let latitude: CLLocationDegrees = (location.coordinate.latitude)
//        let longitude: CLLocationDegrees = (location.coordinate.longitude)
        
//        let locations = CLLocation(latitude: latitude, longitude: longitude) //changed!!!
//        CLGeocoder().reverseGeocodeLocation(locations, completionHandler: {(placemarks, error) -> Void in
//            if error != nil {
//                return
//            }else if let _ = placemarks?.first?.country,
//                let city = (placemarks?.first?.addressDictionary as! [String : AnyObject])["City"] {
//
//                SingletonClass.sharedInstance.strCurrentCity = city as! String
//            }
//            else {
//            }
//        })
        
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
//            mapView.isHidden = true
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways:
//            mapView.isHidden = false
            locationManager.startUpdatingLocation()
            
        case .authorizedWhenInUse:
//            mapView.isHidden = false
            locationManager.startUpdatingLocation()
            
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        return touch.view == gestureRecognizer.view
    }
    
}

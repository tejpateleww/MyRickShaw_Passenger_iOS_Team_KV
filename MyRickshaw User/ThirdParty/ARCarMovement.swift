//
//  ARCarMovement.swift
//  ARCarMovement
//
//  Created by Mac05 on 24/10/17.
//  Copyright © 2017 Antony Raphel. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps

extension Int {
    var degreesToRadiansAR: Double { return Double(self) * .pi / 180 }
}

extension FloatingPoint {
    var degreesToRadiansAR: Self { return self * .pi / 180 }
    var radiansToDegreesAR: Self { return self * 180 / .pi }
}

// MARK: - delegate protocol
@objc public protocol ARCarMovementDelegate {
    
    /**
     *  Tells the delegate that the specified marker will be move with animation.
     */
    func ARCarMovementMoved(_ Marker: GMSMarker)
}

public class ARCarMovement: NSObject {

    // MARK: Public properties
    public weak var delegate: ARCarMovementDelegate?
    public var duration: Float = 2.0
    
    public func ARCarMovement(marker: GMSMarker, oldCoordinate: CLLocationCoordinate2D, newCoordinate:CLLocationCoordinate2D, mapView: GMSMapView, bearing: Float) {
        
            //calculate the bearing value from old and new coordinates
            //

            let degree = oldCoordinate.bearing(to: newCoordinate)
            let calBearing: Float = getHeadingForDirection(fromCoordinate: oldCoordinate, toCoordinate: newCoordinate)
            marker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
            marker.rotation = degree//CLLocationDegrees(calBearing); //found bearing value by calculation when marker add
            marker.position = oldCoordinate; //this can be old position to make car movement to new position
        
            //marker movement animation
            CATransaction.begin()
            CATransaction.setValue(duration, forKey: kCATransactionAnimationDuration)
            CATransaction.setCompletionBlock({() -> Void in
                marker.rotation = degree//(Int(calBearing) != 0) ? CLLocationDegrees(bearing) : CLLocationDegrees(calBearing)
            })

            // delegate method pass value
            //
            delegate?.ARCarMovementMoved(marker)
        
            marker.position = newCoordinate; //this can be new position after car moved from old position to new position with animation
            marker.map = mapView;


    //        print ("\n Another angle is \(oldCoordinate.bearing(to: newCoordinate))\n" )

//            SingletonClass.sharedInstance.floatBearing = Float(degree)//getHeadingForDirection(fromCoordinate: oldCoordinate, toCoordinate: newCoordinate)//Float(degrees)
        marker.rotation = CLLocationDegrees(bearing)//CLLocationDegrees(getHeadingForDirection(fromCoordinate: oldCoordinate, toCoordinate: newCoordinate))//CLLocationDegrees(calBearing);
            CATransaction.commit()
            
        }
    
    private func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float {
        
        let fLat: Float = Float((fromLoc.latitude).degreesToRadiansAR)
        let fLng: Float = Float((fromLoc.longitude).degreesToRadiansAR)
        let tLat: Float = Float((toLoc.latitude).degreesToRadiansAR)
        let tLng: Float = Float((toLoc.longitude).degreesToRadiansAR)
        let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegreesAR
        return (degree >= 0) ? degree : (360 + degree)
    }
    
}


extension CLLocationCoordinate2D {

    func bearing(to point: CLLocationCoordinate2D) -> Double {
        func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
        func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }

        let lat1 = degreesToRadians(latitude)
        let lon1 = degreesToRadians(longitude)

        let lat2 = degreesToRadians(point.latitude);
        let lon2 = degreesToRadians(point.longitude);

        let dLon = lon2 - lon1;

        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        let degree = radiansToDegrees(radiansBearing)
        return (degree >= 0) ? degree : (360 + degree)
    }

}

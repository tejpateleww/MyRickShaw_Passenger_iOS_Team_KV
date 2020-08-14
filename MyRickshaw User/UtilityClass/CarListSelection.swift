//
//  CarListSelection.swift
//  MyRickshaw User
//
//  Created by Excelent iMac on 24/08/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation
import UIKit


var CarListConstant: [carListIs] = {

    var CarListConstantData = [carListIs]()
    
//    let vanX4 = ["id": 1, "name": "Van x4", "image": "iconVanX4Unselected"] as [String : Any]
//    let vanX6 = ["id": 2, "name": "Van x6", "image": "iconVanX6Unselected"] as [String : Any]
//    let vanX9 = ["id": 3, "name": "Van x9", "image": "iconVanX9Unselected"] as [String : Any]
//    let van11 = ["id": 4, "name": "Van 11", "image": "iconVan11Unselected"] as [String : Any]
//    let TMCarHolder = ["id": 5, "name": "TM Card Holder (TM)", "image": "iconTMCarHolderUnselected"] as [String : Any]
//    let BabySeat = ["id": 6, "name": "Baby Seat (BS)", "image": "iconBabySeatUnselected"] as [String : Any]
//    let HoistVan = ["id": 7, "name": "Hoist Van (HV)", "image": "iconHositVanUnselected"] as [String : Any]
    
//    CarListConstantData.append(vanX4)
//    CarListConstantData.append(vanX6)
//    CarListConstantData.append(vanX9)
//    CarListConstantData.append(van11)
//    CarListConstantData.append(TMCarHolder)
//    CarListConstantData.append(BabySeat)
//    CarListConstantData.append(HoistVan)
    
//    carListIs.init(id: 1, name: "Van x4", image: "iconVanX4Unselected")
//    carListIs.init(id: 2, name: "Van x6", image: "iconVanX6Unselected")
//    carListIs.init(id: 3, name: "Van x9", image: "iconVanX9Unselected")
//    carListIs.init(id: 4, name: "Van 11", image: "iconVan11Unselected")
//    carListIs.init(id: 5, name: "TM Card Holder (TM)", image: "iconTMCarHolderUnselected")
//    carListIs.init(id: 6, name: "Baby Seat (BS)", image: "iconBabySeatUnselected")
//    carListIs.init(id: 7, name: "Hoist Van (HV)", image: "iconHositVanUnselected")
    
    CarListConstantData.append(carListIs.init(id: 1, name: "Van x4", image: "iconVanX4Unselected", status: false, selectedImage: "iconVanX4Selected"))
    CarListConstantData.append(carListIs.init(id: 2, name: "Van x6", image: "iconVanX6Unselected", status: false, selectedImage: "iconVanX6Selected"))
    CarListConstantData.append(carListIs.init(id: 3, name: "Van x9", image: "iconVanX9Unselected", status: false, selectedImage: "iconVanX9Selected"))
    CarListConstantData.append(carListIs.init(id: 4, name: "Van 11", image: "iconVan11Unselected", status: false, selectedImage: "iconVan11Selected"))
    CarListConstantData.append(carListIs.init(id: 5, name: "TM Card Holder (TM)", image: "iconTMCarHolderUnselected", status: false, selectedImage: "iconTMCarHolderSelected"))
    CarListConstantData.append(carListIs.init(id: 6, name: "Baby Seat (BS)", image: "iconBabySeatUnselected", status: false, selectedImage: "iconBabySeatSelected"))
    CarListConstantData.append(carListIs.init(id: 7, name: "Hoist Van (HV)", image: "iconHositVanUnselected", status: false, selectedImage: "iconHositVanSelected"))
    
    return CarListConstantData

}()

struct carListIs {
    var id: Int?
    var name: String?
    var image: String?
    var status: Bool?
    var selectedImage: String?
    
}





//let vanX4 = ["id": 1, "name": "Van x4", "image": "iconVanX4Unselected"] as [String : Any]
//let vanX6 = ["id": 2, "name": "Van x6", "image": "iconVanX6Unselected"] as [String : Any]
//let vanX9 = ["id": 3, "name": "Van x9", "image": "iconVanX9Unselected"] as [String : Any]
//let van11 = ["id": 4, "name": "Van 11", "image": "iconVan11Unselected"] as [String : Any]
//let TMCarHolder = ["id": 5, "name": "TM Card Holder (TM)", "image": "iconTMCarHolderUnselected"] as [String : Any]
//let BabySeat = ["id": 6, "name": "Baby Seat (BS)", "image": "iconBabySeatUnselected"] as [String : Any]
//let HoistVan = ["id": 7, "name": "Hoist Van (HV)", "image": "iconHositVanUnselected"] as [String : Any]
//
//CarListConstantData.append(vanX4)
//CarListConstantData.append(vanX6)
//CarListConstantData.append(vanX9)
//CarListConstantData.append(van11)
//CarListConstantData.append(TMCarHolder)
//CarListConstantData.append(BabySeat)
//CarListConstantData.append(HoistVan)




//["Max Van", "Waiheke Express", "Budget Taxi", "Car X4", "Van X6", "Van X9", "TM Card Holder (TM)", "Baby Seat (BS)", "Hoist Van (HV)"]
















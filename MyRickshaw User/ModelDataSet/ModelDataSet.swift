//
//  ModelDataSet.swift
//  MyRickshaw User
//
//  Created by Excelent iMac on 06/09/18.
//  Copyright © 2018 Excellent Webworld. All rights reserved.
//

import Foundation


func getCarListData() -> [CarListModel]? {
    
    var Personal : [CarListModel]?
    
    if let savedPerson = UserDefaults.standard.object(forKey: ModelDataConstant.kLoginResponse) as? Data {
        
        do {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(LoginDataModel.self, from: savedPerson) {
                Personal = loadedPerson.CarListDataModel
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    return Personal
}


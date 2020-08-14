/* 
Copyright (c) 2018 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct LoginDataModel : Codable {
	var status : Bool?
	var message : String?
    var walletBalance : String?
    var profile : ProfileData?
	var CarListDataModel : [CarListModel]?

	enum CodingKeys: String, CodingKey {

		case status = "status"
		case message = "message"
        case walletBalance = "walletBalance"
		case profile = "profile"
		case CarListDataModel = "car_class"
	}

	init(from decoder: Decoder) throws {
        
		let values = try decoder.container(keyedBy: CodingKeys.self)
        
        status = try values.decodeIfPresent(Bool.self, forKey: .status)
        message = try values.decodeIfPresent(String.self, forKey: .message)
        profile = try values.decodeIfPresent(ProfileData.self, forKey: .profile)
        CarListDataModel = try values.decodeIfPresent([CarListModel].self, forKey: .CarListDataModel)
        
        do {
            walletBalance = try values.decodeIfPresent(String.self, forKey: .walletBalance)
        }
        catch {
            do {
                let intWalletBalance = try values.decodeIfPresent(Int.self, forKey: .walletBalance)
                walletBalance = "\(intWalletBalance ?? 0)"
            }
            catch {
                do {
                    let floatWalletBalance = try values.decodeIfPresent(Float.self, forKey: .walletBalance)
                    walletBalance = "\(floatWalletBalance ?? 0)"
                }
                catch {
                    let doubleWalletBalance = try values.decodeIfPresent(Double.self, forKey: .walletBalance)
                    walletBalance = "\(doubleWalletBalance ?? 0)"
                }
            }
        }
        
    }
    
    init(status: Bool?, message: String?, walletBalance: String, profile: ProfileData?, carList: [CarListModel]?) {
        self.status = status
        self.message = message
        self.walletBalance = walletBalance
        self.profile = profile
        self.CarListDataModel = carList
    }

}

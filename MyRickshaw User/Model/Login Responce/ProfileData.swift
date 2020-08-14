/* 
Copyright (c) 2018 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
struct ProfileData : Codable {
    
    var id : String?
    var fullname : String?
    var email : String?
    var password : String?
    var mobileNo : String?
    var image : String?
    var qRCode : String?
    var companyName : String?
    var aBN : String?
    var bankName : String?
    var bSB : String?
    var bankAccountNo : String?
    var description : String?
    var licenceImage : String?
    var passportImage : String?
    var gender : String?
    var dOB : String?
    var referralCode : String?
    var address : String?
    var deviceType : String?
    var token : String?
    var lat : String?
    var lng : String?
    var status : String?
    var verify : String?
    var trash : String?
    var createdDate : String?
    var referralAmount : String?
    var walletBalance : String?

	enum CodingKeys: String, CodingKey {

        case id = "Id"
        case fullname = "Fullname"
        case email = "Email"
        case password = "Password"
        case mobileNo = "MobileNo"
        case image = "Image"
        case qRCode = "QRCode"
        case companyName = "CompanyName"
        case aBN = "ABN"
        case bankName = "BankName"
        case bSB = "BSB"
        case bankAccountNo = "BankAccountNo"
        case description = "Description"
        case licenceImage = "LicenceImage"
        case passportImage = "PassportImage"
        case gender = "Gender"
        case dOB = "DOB"
        case referralCode = "ReferralCode"
        case address = "Address"
        case deviceType = "DeviceType"
        case token = "Token"
        case lat = "Lat"
        case lng = "Lng"
        case status = "Status"
        case verify = "Verify"
        case trash = "Trash"
        case createdDate = "CreatedDate"
        case referralAmount = "ReferralAmount"
        case walletBalance = "walletBalance"
	}

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
    
        fullname = try values.decodeIfPresent(String.self, forKey: .fullname)
        email = try values.decodeIfPresent(String.self, forKey: .email)
        password = try values.decodeIfPresent(String.self, forKey: .password)
        mobileNo = try values.decodeIfPresent(String.self, forKey: .mobileNo)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        qRCode = try values.decodeIfPresent(String.self, forKey: .qRCode)
        companyName = try values.decodeIfPresent(String.self, forKey: .companyName)
        aBN = try values.decodeIfPresent(String.self, forKey: .aBN)
        bankName = try values.decodeIfPresent(String.self, forKey: .bankName)
        bSB = try values.decodeIfPresent(String.self, forKey: .bSB)
        bankAccountNo = try values.decodeIfPresent(String.self, forKey: .bankAccountNo)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        licenceImage = try values.decodeIfPresent(String.self, forKey: .licenceImage)
        passportImage = try values.decodeIfPresent(String.self, forKey: .passportImage)
        gender = try values.decodeIfPresent(String.self, forKey: .gender)
        dOB = try values.decodeIfPresent(String.self, forKey: .dOB)
        referralCode = try values.decodeIfPresent(String.self, forKey: .referralCode)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        deviceType = try values.decodeIfPresent(String.self, forKey: .deviceType)
        token = try values.decodeIfPresent(String.self, forKey: .token)
        lat = try values.decodeIfPresent(String.self, forKey: .lat)
        lng = try values.decodeIfPresent(String.self, forKey: .lng)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        verify = try values.decodeIfPresent(String.self, forKey: .verify)
        trash = try values.decodeIfPresent(String.self, forKey: .trash)
        createdDate = try values.decodeIfPresent(String.self, forKey: .createdDate)
//            referralAmount = try values.decodeIfPresent(String.self, forKey: .referralAmount)
//            walletBalance = try values.decodeIfPresent(String.self, forKey: .walletBalance)
        
        do {
            id = try values.decodeIfPresent(String.self, forKey: .id)
        }
        catch {
            let intId = try values.decodeIfPresent(Int.self, forKey: .id)
            id = "\(intId ?? 0)"
        }
        
        do {
            referralAmount = try values.decodeIfPresent(String.self, forKey: .referralAmount)
        }
        catch {
            do {
                let intReferralAmount = try values.decodeIfPresent(Int.self, forKey: .referralAmount)
                referralAmount = "\(intReferralAmount!)"
            }
            catch {
                do {
                    let floatReferralAmount = try values.decodeIfPresent(Float.self, forKey: .referralAmount)
                    referralAmount = "\(floatReferralAmount!)"
                }
                catch {
                    let doubleReferralAmount = try values.decodeIfPresent(Double.self, forKey: .referralAmount)
                    referralAmount = "\(doubleReferralAmount!)"
                }
            }
        }
        
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

}

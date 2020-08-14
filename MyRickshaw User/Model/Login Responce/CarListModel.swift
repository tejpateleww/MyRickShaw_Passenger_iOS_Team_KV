

import Foundation


struct CarListModel : Codable {
    
	var id : String?
	var categoryId : String?
	var name : String?
	var sort : String?
	var baseFare : String?
	var minKm : String?
	var belowAndAboveKmLimit : String?
	var belowPerKmCharge : String?
	var abovePerKmCharge : String?
	var cancellationFee : String?
	var nightChargeApplicable : String?
	var nightCharge : String?
	var nightTimeFrom : String?
	var nightTimeTo : String?
	var specialEventSurcharge : String?
	var specialEventTimeFrom : String?
	var specialEventTimeTo : String?
	var waitingTimePerMinuteCharge : String?
	var minuteFare : String?
	var bookingFee : String?
	var capacity : String?
	var image : String?
	var imageDeselect : String?
	var description : String?
	var commission : String?
	var status : String?
	var specialExtraCharge : String?

	enum CodingKeys: String, CodingKey {

		case id = "Id"
		case categoryId = "CategoryId"
		case name = "Name"
		case sort = "Sort"
		case baseFare = "BaseFare"
		case minKm = "MinKm"
		case belowAndAboveKmLimit = "BelowAndAboveKmLimit"
		case belowPerKmCharge = "BelowPerKmCharge"
		case abovePerKmCharge = "AbovePerKmCharge"
		case cancellationFee = "CancellationFee"
		case nightChargeApplicable = "NightChargeApplicable"
		case nightCharge = "NightCharge"
		case nightTimeFrom = "NightTimeFrom"
		case nightTimeTo = "NightTimeTo"
		case specialEventSurcharge = "SpecialEventSurcharge"
		case specialEventTimeFrom = "SpecialEventTimeFrom"
		case specialEventTimeTo = "SpecialEventTimeTo"
		case waitingTimePerMinuteCharge = "WaitingTimePerMinuteCharge"
		case minuteFare = "MinuteFare"
		case bookingFee = "BookingFee"
		case capacity = "Capacity"
		case image = "Image"
		case imageDeselect = "ImageDeselect"
		case description = "Description"
		case commission = "Commission"
		case status = "Status"
		case specialExtraCharge = "SpecialExtraCharge"
	}

	init(from decoder: Decoder) throws {
        
		let values = try decoder.container(keyedBy: CodingKeys.self)
      
        
        categoryId = try values.decodeIfPresent(String.self, forKey: .categoryId)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        sort = try values.decodeIfPresent(String.self, forKey: .sort)
        baseFare = try values.decodeIfPresent(String.self, forKey: .baseFare)
        minKm = try values.decodeIfPresent(String.self, forKey: .minKm)
        belowAndAboveKmLimit = try values.decodeIfPresent(String.self, forKey: .belowAndAboveKmLimit)
        belowPerKmCharge = try values.decodeIfPresent(String.self, forKey: .belowPerKmCharge)
        abovePerKmCharge = try values.decodeIfPresent(String.self, forKey: .abovePerKmCharge)
        cancellationFee = try values.decodeIfPresent(String.self, forKey: .cancellationFee)
        nightChargeApplicable = try values.decodeIfPresent(String.self, forKey: .nightChargeApplicable)
        nightCharge = try values.decodeIfPresent(String.self, forKey: .nightCharge)
        nightTimeFrom = try values.decodeIfPresent(String.self, forKey: .nightTimeFrom)
        nightTimeTo = try values.decodeIfPresent(String.self, forKey: .nightTimeTo)
        specialEventSurcharge = try values.decodeIfPresent(String.self, forKey: .specialEventSurcharge)
        specialEventTimeFrom = try values.decodeIfPresent(String.self, forKey: .specialEventTimeFrom)
        specialEventTimeTo = try values.decodeIfPresent(String.self, forKey: .specialEventTimeTo)
        waitingTimePerMinuteCharge = try values.decodeIfPresent(String.self, forKey: .waitingTimePerMinuteCharge)
        minuteFare = try values.decodeIfPresent(String.self, forKey: .minuteFare)
        bookingFee = try values.decodeIfPresent(String.self, forKey: .bookingFee)
        capacity = try values.decodeIfPresent(String.self, forKey: .capacity)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        imageDeselect = try values.decodeIfPresent(String.self, forKey: .imageDeselect)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        commission = try values.decodeIfPresent(String.self, forKey: .commission)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        specialExtraCharge = try values.decodeIfPresent(String.self, forKey: .specialExtraCharge)
        
        
        do {
            id = try values.decodeIfPresent(String.self, forKey: .id)
        }
        catch {
            let intId = try values.decodeIfPresent(Int.self, forKey: .id)
            id = "\(intId ?? 0)"
        }
	}

}

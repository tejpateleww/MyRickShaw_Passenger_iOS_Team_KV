//
//  TripDetailsViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 06/11/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit

class TripDetailsViewController: ParentViewController {

    var arrData = NSMutableArray()
    let dictData = NSMutableDictionary()
    @IBOutlet weak var tblObject : UITableView!
    
    var delegate: CompleterTripInfoDelegate!
    
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.heightWithLabel = (self.heightWithLabel - 20)
        self.createHeaderView()
        
        setData()
        
//        self.tblObject.estimatedRowHeight = 100.0;
//        self.tblObject.rowHeight = UITableViewAutomaticDimension;
//        self.tblObject.tableFooterView = UIView()

        let dict = NSMutableDictionary(dictionary: arrData.object(at: 0) as! NSDictionary) as NSMutableDictionary
        dictData.setObject(dict.object(forKey: "PickupLocation")!, forKey: "Pickup Location" as NSCopying)
        dictData.setObject(dict.object(forKey: "DropoffLocation")!, forKey: "Dropoff Location" as NSCopying)
        dictData.setObject(dict.object(forKey: "NightFare")!, forKey: "Night Fee" as NSCopying)
        dictData.setObject(dict.object(forKey: "TripFare")!, forKey: "Trip Fee" as NSCopying)
        dictData.setObject(dict.object(forKey: "WaitingTimeCost")!, forKey: "Waiting Cost" as NSCopying)
        dictData.setObject(dict.object(forKey: "BookingCharge")!, forKey: "Booking Charge" as NSCopying)
        dictData.setObject(dict.object(forKey: "Discount")!, forKey: "Discount" as NSCopying)
        dictData.setObject(dict.object(forKey: "SubTotal")!, forKey: "Sub Total" as NSCopying)
        dictData.setObject(dict.object(forKey: "Status")!, forKey: "Status" as NSCopying)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //-------------------------------------------------------------
    // MARK: - Outlets
    //-------------------------------------------------------------
    
    
    @IBOutlet weak var lblPickupLocation: UILabel!
    @IBOutlet weak var lblDropoffLocation: UILabel!
    
    @IBOutlet weak var lblBaseFare: UILabel!
    @IBOutlet weak var lblDistanceFare: UILabel!
    @IBOutlet weak var lblNightFare: UILabel!
    @IBOutlet weak var lblTripDuration: UILabel!
    @IBOutlet weak var lblWaitingCost: UILabel!
    @IBOutlet weak var lblTollFee: UILabel!
    @IBOutlet weak var lblSubTotal: UILabel!
    
    @IBOutlet weak var lblBookingCharge: UILabel!
    @IBOutlet weak var lblTax: UILabel!
    @IBOutlet weak var lblDiscount: UILabel!
    
    @IBOutlet weak var lblGrandTotal: UILabel!
    @IBOutlet weak var lblLoadingCharge: UILabel!
    @IBOutlet weak var lblSoilageCharge: UILabel!
    @IBOutlet weak var lblSoilageChargeReason: UILabel!
    @IBOutlet weak var stackViewSoilageChargeReason : UIStackView!
    @IBOutlet weak var lblWaitingTime: UILabel!
    @IBOutlet weak var lblFlagFallFare: UILabel!

    //-------------------------------------------------------------
    // MARK: - Custom Methods
    //-------------------------------------------------------------
    
    func setData() {
        
        if let data = arrData.object(at: 0) as? NSDictionary {
            
            let distanceFare = "\(data.object(forKey: "DistanceFare")!) (\(data.object(forKey: "TripDistance")!) km)"
        
            lblPickupLocation.text = data.object(forKey: "PickupLocation") as? String
            lblDropoffLocation.text = data.object(forKey: "DropoffLocation") as? String
            
            lblBaseFare.text = currencySign + (data.object(forKey: "TripFare") as? String ?? "0.00")
            lblDistanceFare.text = distanceFare
            let tripDuration =  Int(data.object(forKey: "TripDuration") as? String ?? "0.00") ?? 0

            
            hmsFrom(seconds: tripDuration) { hours, minutes, seconds in

                let hours = self.getStringFrom(seconds: hours)
                let minutes = self.getStringFrom(seconds: minutes)
                let seconds = self.getStringFrom(seconds: seconds)

                print("\(hours):\(minutes):\(seconds)")
                
                self.lblTripDuration.text = ("\(hours):\(minutes):\(seconds)")

            }

            lblWaitingCost.text = currencySign + (data.object(forKey: "WaitingTimeCost") as? String ?? "0.00")
            let waitingTime = Int(data.object(forKey: "WaitingTime") as? String ?? "0.00") ?? 0
            
            hmsFrom(seconds: waitingTime) { hours, minutes, seconds in

                let hours = self.getStringFrom(seconds: hours)
                let minutes = self.getStringFrom(seconds: minutes)
                let seconds = self.getStringFrom(seconds: seconds)

                print("\(hours):\(minutes):\(seconds)")
                
                self.lblWaitingTime.text = ("\(hours):\(minutes):\(seconds)")

            }

            lblTollFee.text = currencySign + (data.object(forKey: "TollFee") as? String ?? "0.00")
            lblFlagFallFare.text = currencySign + (data.object(forKey: "FlagFallAmount") as? String ?? "0.00")

            lblSubTotal.text = currencySign + (data.object(forKey: "SubTotal") as? String ?? "0.00")
            
            lblBookingCharge.text = currencySign + (data.object(forKey: "BookingCharge") as? String ?? "0.00")
            lblTax.text = currencySign + (data.object(forKey: "Tax") as? String ?? "0.00")
            lblDiscount.text = currencySign + (data.object(forKey: "Discount") as? String ?? "0.00")
            
            lblGrandTotal.text = currencySign + (data.object(forKey: "GrandTotal") as? String ?? "0.00")
            
            lblLoadingCharge.text = currencySign + (data.object(forKey: "LoadingUnloadingCharge") as? String ?? "0.00")
        
            var strSoilageCharge = String()
            if let soilageCharge = data.object(forKey: "SoilageCharge") as? String {
                strSoilageCharge = soilageCharge
            } else if let soilageCharge = data.object(forKey: "SoilageCharge") as? Int {
                strSoilageCharge = "\(soilageCharge)"
            } else if let soilageCharge = data.object(forKey: "SoilageCharge") as? Double {
                strSoilageCharge = "\(soilageCharge)"
            }
            lblSoilageCharge.text = "\(currencySign)\(strSoilageCharge)"
            stackViewSoilageChargeReason.isHidden = true
            if(strSoilageCharge != "0")
            {
                stackViewSoilageChargeReason.isHidden = false
                lblSoilageChargeReason.text =  data.object(forKey: "SoilageChargeInfo") as? String
            }
        }
    }
    
    func hmsFrom(seconds: Int, completion: @escaping (_ hours: Int, _ minutes: Int, _ seconds: Int)->()) {

            completion(seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)

    }

    func getStringFrom(seconds: Int) -> String {

        return seconds < 10 ? "0\(seconds)" : "\(seconds)"
    }
    
    @IBAction func btnBackAction(sender: UIButton) {
        
//       NotificationCenter.default.addObserver(self, selector: #selector(YourClassName.methodOfReceivedNotification(notification:)), name: Notification.Name("CallToRating"), object: nil)
        
//        NotificationCenter.default.post(name: Notification.Name("CallToRating"), object: nil)
        
//        self.delegate.didRatingCompleted()
        self.dismiss(animated: true, completion: nil)
    }
    

    
    @IBOutlet weak var btnCall: UIButton!
    @IBAction func btCallClicked(_ sender: UIButton)
    {
        
        let contactNumber = helpLineNumber
        
        if contactNumber == "" {
            
            UtilityClass.setCustomAlert(title: "\(appName)", message: "Contact number is not available") { (index, title) in
            }
        }
        else
        {
            callNumber(phoneNumber: contactNumber)
        }
    }
    
    private func callNumber(phoneNumber:String) {
        
        if let phoneCallURL = URL(string: "tel://\(phoneNumber)") {
            
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - Actions
    //-------------------------------------------------------------
    
 /*
    {
    "Info": [
    {
    "Id": 263,
    "PassengerId": 29,
    "ModelId": 5,
    "DriverId": 42,
    "CreatedDate": "2017-11-25T11:31:59.000Z",
    "TransactionId": "",
    "PaymentStatus": "",
    "PickupTime": "1511589728",
    "DropTime": "",
    "TripDuration": "",
    "TripDistance": "0.001",
    "PickupLocation": "119, Science City Rd, Sola, Ahmedabad, Gujarat 380060, India",
    "DropoffLocation": "Iscon Mega Mall, Ahmedabad, Gujarat, India",
    "NightFareApplicable": 0,
    "NightFare": "0",
    "TripFare": "30",
    "DistanceFare": "0",
    "WaitingTime": "",
    "WaitingTimeCost": "0",
    "TollFee": "0",
    "BookingCharge": "2",
    "Tax": "3.20",
    "PromoCode": "",
    "Discount": "0",
    "SubTotal": "30.00",
    "GrandTotal": "32.00",
    "Status": "completed",
    "Reason": "",
    "PaymentType": "cash",
    "ByDriverAmount": "",
    "AdminAmount": "5.00",
    "CompanyAmount": "27.00",
    "PickupLat": "23.07272",
    "PickupLng": "72.516387",
    "DropOffLat": "23.030513",
    "DropOffLon": "72.5075401",
    "BookingType": "",
    "ByDriverId": 0,
    "PassengerName": "",
    "PassengerContact": "",
    "PassengerEmail": ""
    }
    ]
    }
    
    */
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
    
    /*
    //MARK:- Tableview delegate and dataSource Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dictData.allKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:TripDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TripDetailsTableViewCell") as! TripDetailsTableViewCell
        cell.lblTitle.text = dictData.allKeys[indexPath.row] as? String
        cell.lblDescription.text = dictData.allValues[indexPath.row] as? String
        return cell
    }
//
//
//    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 100
//    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
*/


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

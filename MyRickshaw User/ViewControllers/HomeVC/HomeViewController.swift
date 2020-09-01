//
//  HomeViewController.swift
//  TickTok User
//
//  Created by Excellent Webworld on 26/10/17.
//  Copyright © 2017 Excellent Webworld. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
//import SideMenu
import SocketIO
import SDWebImage
import NVActivityIndicatorView
import M13Checkbox

//let BaseURL = "http://54.206.55.185:8080"

protocol FavouriteLocationDelegate {
    func didEnterFavouriteDestination(Source: [String: AnyObject])
}

protocol CompleterTripInfoDelegate {
    func didRatingCompleted()
}

protocol addCardFromHomeVCDelegate {
    func didAddCardFromHomeVC()
}

@objc protocol delegateChooseCarOptions {
    @objc optional func didChangedCar(index: Int)
    @objc optional func didSelectOptions(indexes: [[String:Any]])
    
}

@objc protocol delegateForFlateRate {
    @objc optional func didAcceptFlateRate(dict: [String:Any])
}

enum ServiceType: String {
    case PointToPoint = "PointToPoint"
    case FlatRate = "FlatRate"
}


class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, GMSAutocompleteViewControllerDelegate, FavouriteLocationDelegate, UIPickerViewDelegate, UIPickerViewDataSource, NVActivityIndicatorViewable, UIGestureRecognizerDelegate, FloatRatingViewDelegate, CompleterTripInfoDelegate, ARCarMovementDelegate, GMSMapViewDelegate, addCardFromHomeVCDelegate, MapMarkerDelegate, delegateChooseCarOptions, delegateForFlateRate,UITextFieldDelegate {
    
    // ----------------------------------------------------
    // MARK: - Flate Rate Delegate and Actions
    // ----------------------------------------------------
    
    func didAcceptFlateRate(dict: [String : Any]) {
        
        if dict.count != 0 {
            
            clearMap()
            
            dictFlatRate = dict
            
            strFlatRateID = checkDictionaryHaveValue(dictData: dict, didHaveValue: "Id", isNotHave: "")
            
            txtCurrentLocation.text = dict["PickupLocation"] as? String
            txtDestinationLocation.text = dict["DropoffLocation"] as? String
            doublePickupLat =  Double(checkDictionaryHaveValue(dictData: dict, didHaveValue: "PickupLat", isNotHave: "0")) ?? 0
            doublePickupLng =  Double(checkDictionaryHaveValue(dictData: dict, didHaveValue: "PickupLng", isNotHave: "0")) ?? 0
            doubleDropOffLat = Double(checkDictionaryHaveValue(dictData: dict, didHaveValue: "DropoffLat", isNotHave: "0")) ?? 0
            doubleDropOffLng = Double(checkDictionaryHaveValue(dictData: dict, didHaveValue: "DropoffLng", isNotHave: "0")) ?? 0
            
            strPickupLocation  = checkDictionaryHaveValue(dictData: dict, didHaveValue: "PickupLocation", isNotHave: "")
            strDropoffLocation = checkDictionaryHaveValue(dictData: dict, didHaveValue: "DropoffLocation", isNotHave: "")
            
            lblApproxCost.text = "\(currencySign)\(dict["Price"] as? String ?? "00.00")"
            
            setupBothCurrentAndDestinationMarkerAndPolylineOnMap()
            
            lblFairAndTimeForMaxVan.text = "No Taxi"
            lblFairAndTimeForBudgetTaxi.text = "No Taxi"
            lblFairAndTimeForWaihekeExpress.text = "No Taxi"
            
            self.collectionViewCars.reloadData()
            
        }
    }
    
    var valueTMCardHolde:Int = 0
    var valueBabySeater:Int = 0
    var valueHoistVan:Int = 0
    var arySelectedCarOptions = [[String:Any]]()
    
    func didSelectOptions(indexes: [[String : Any]]) {
        //        [["Type":"TM Card Holder", "value":0, "key": "TMCardHolder"], ["Type":"Baby Seater", "value":0, "key": "BabySeater"], ["Type":"Hoist Van", "value":0, "key": "HoistVan"]]
        arySelectedCarOptions = indexes
        valueTMCardHolde = 0
        valueBabySeater = 0
        valueHoistVan = 0
        
        if indexes.count != 0 {
            
            for (_,item) in indexes.enumerated() {
                if item["key"] as! String == "TMCardHolder" {
                    valueTMCardHolde = 1
                }
                if item["key"] as! String == "BabySeater" {
                    valueBabySeater = 1
                }
                if item["key"] as! String == "HoistVan" {
                    valueHoistVan = 1
                }
            }
        }        
        updateCounting()
        print("indexes: \(arySelectedCarOptions)")
    }
    
    var strFlatRateID = String()
    @IBOutlet weak var btnPointToPoint: UIButton!
    @IBOutlet weak var btnFlatRate: UIButton!
    var arrDemoCarList:[[String:Any]] = []
    @IBAction func btnPointToPoint(_ sender: UIButton) {
        
        btnFlatRate.setTitleColor(UIColor.black, for: .normal)
        btnPointToPoint.setTitleColor(UIColor.white, for: .normal)
        strServiceType = ServiceType.PointToPoint.rawValue
        dictFlatRate = nil
        
        lblApproxCost.text = "\(currencySign)00.00"
        //        currentLocationAction()
        //
        //        MarkerCurrntLocation.isHidden = false
        //        txtDestinationLocation.text = ""
        //        strDropoffLocation = ""
        //        doubleDropOffLat = 0
        //        doubleDropOffLng = 0
        //        self.destinationLocationMarker.map = nil
        //        self.currentLocationMarker.map = nil
        //        self.strLocationType = self.currentLocationMarkerText
        //        self.routePolyline.map = nil
        //
        //        stackViewNumberOfPassenger.isHidden = true
        //        viewNotesOnBooking.isHidden = true
        //
        //        imgTopViewOfTripPickupAndDropoffLocation.image = UIImage(named: "iconHomeScreenTopView2")
        //
        //        self.btnDoneForLocationSelected.isHidden = false
        //        self.ConstantViewCarListsHeight.constant = 0
        //        self.viewCarLists.isHidden = true
        
        DispatchQueue.main.async {
            self.btnCorrentLocationClickedAction()
            self.clearDestinationLocation()
        }
    }
    
    @IBAction func btnFlatRate(_ sender: UIButton) {
        
        btnFlatRate.setTitleColor(UIColor.white, for: .normal)
        btnPointToPoint.setTitleColor(UIColor.black, for: .normal)
        strServiceType = ServiceType.FlatRate.rawValue
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "FlatRateViewController") as! FlatRateViewController
        next.delegate = self
        self.navigationController?.pushViewController(next, animated: true)
    }
    
    
    
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    let baseUrlForGetAddress = "https://maps.googleapis.com/maps/api/geocode/json?"
    let apikey = googleMapAddress //"AIzaSyCKEP5WGD7n5QWtCopu0QXOzM9Qec4vAfE"
    
    let socket = SocketIOClient(socketURL: URL(string: SocketData.kBaseURL)!, config: [.log(false), .compress])
    
    //    let socket = (UIApplication.shared.delegate as! AppDelegate).SocketManager
    
    var moveMent: ARCarMovement!
    var driverMarker: GMSMarker!
    
    var timer = Timer()
    var timerToUpdatePassengerLocation : Timer?
    var timerToGetDriverLocation : Timer!
    var aryCards = [[String:AnyObject]]()
    var aryCompleterTripData = [Any]()
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView = GMSMapView()
    var placesClient = GMSPlacesClient()
    var zoomLevel: Float = 17.0
    var likelyPlaces: [GMSPlace] = []
    var selectedPlace: GMSPlace?
    var defaultLocation = CLLocation() // CLLocation(latitude: 23.0733308, longitude: 72.5145669)
    var arrNumberOfAvailableCars = NSMutableArray()
    var arrTotalNumberOfCars = NSMutableArray()
    var arrNumberOfOnlineCars = NSMutableArray()
    //    var dictCars = NSMutableDictionary()
    var strCarModelClass = String()
    
    var aryRequestAcceptedData = NSArray()
    
    var strCarModelID = String()
    var strCarModelIDIfZero = String()
    var strNavigateCarModel = String()
    
    var aryEstimateFareData = NSArray()
    
    var strSelectedCarMarkerIcon = String()
    var ratingToDriver = Float()
    var commentToDriver = String()
    
    var currentLocationMarkerText = String()
    var destinationLocationMarkerText = String()
    
    var aryBookingAcceptedData = [[String:AnyObject]]()
    
    var carListModelDataList = SingletonClass.sharedInstance.carList
    
    var dictFlatRate: [String:Any]?
    
    var strServiceType: String = ServiceType.PointToPoint.rawValue {
        
        didSet {
            if strServiceType == ServiceType.FlatRate.rawValue {
                lblFairAndTimeForMaxVan.text = lblApproxCost.text
                lblFairAndTimeForWaihekeExpress.text = lblApproxCost.text
                lblFairAndTimeForBudgetTaxi.text = lblApproxCost.text
            }
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - Final Rating View
    //-------------------------------------------------------------
    
    
    @IBOutlet weak var MarkerCurrntLocation: UIButton!
    
    @IBOutlet weak var viewMainFinalRating: UIView!
    @IBOutlet weak var viewSubFinalRating: UIView!
    @IBOutlet weak var txtFeedbackFinal: UITextField!
    
    @IBOutlet weak var giveRating: FloatRatingView!
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        
        giveRating.rating = rating
        ratingToDriver = giveRating.rating
        
    }
    
    @IBAction func btnSubmitFinalRating(_ sender: UIButton) {
        //        BookingId,Rating,Comment,BookingType(BookNow,BookLater)
        
        CancellationFee = ""
        
        var param = [String:AnyObject]()
        param["BookingId"] = SingletonClass.sharedInstance.bookingId as AnyObject
        param["Rating"] = ratingToDriver as AnyObject
        param["Comment"] = txtFeedbackFinal.text as AnyObject
        param["BookingType"] = strBookingType as AnyObject
        
        webserviceForRatingAndComment(param as AnyObject) { (result, status) in
            
            if (status) {
                //       print(result)
                
                self.txtFeedbackFinal.text = ""
                self.ratingToDriver = 0
                
                self.completeTripInfo()
                
                
            }
            else {
                //      print(result)
                
                if let res = result as? String {
                    UtilityClass.setCustomAlert(title: appName, message: res) { (index, title) in
                    }
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.setCustomAlert(title: appName, message: resDict.object(forKey: "message") as! String) { (index, title) in
                    }
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.setCustomAlert(title: appName, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    }
                }
            }
        }
    }
    
    func didRatingCompleted() {
        
        openRatingView()
        
        //        self.completeTripInfo()
    }
    
    //-------------------------------------------------------------
    // MARK: - Load Xib For Marker Info
    //-------------------------------------------------------------
    
    weak var delegate: MapMarkerDelegate?
    var infoWindow = GoogleMapMarkerInfoView()
    
    func loadNiB() -> GoogleMapMarkerInfoView {
        let infoWindow = GoogleMapMarkerInfoView.instanceFromNib() as! GoogleMapMarkerInfoView
        return infoWindow
    }
    
    func didTapInfoButton(data: NSDictionary) {
        print(data)
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        let address = getLocationOfTappedMarker(latitude: marker.position.latitude, longitude: marker.position.longitude)
        
        var markerData : NSDictionary?
        if let data = marker.userData as? NSDictionary {
            markerData = data
        }
        
        currentLocationMarker = marker
        infoWindow.removeFromSuperview()
        infoWindow = loadNiB()
        let location = currentLocationMarker.position
        
        // Pass the spot data to the info window, and set its delegate to self
        infoWindow.spotData = markerData
        infoWindow.delegate = self
        // Configure UI properties of info window
        infoWindow.alpha = 0.9
        infoWindow.viewMain.layer.cornerRadius = 10
        infoWindow.viewMain.layer.borderWidth = 2
        //        infoWindow.layer.borderColor = UIColor(hexString: "19E698")?.cgColor
        //        infoWindow.infoButton.layer.cornerRadius = infoWindow.infoButton.frame.height / 2
        
        //        let address = markerData!["address"]!
        //        let rate = markerData!["rate"]!
        //        let fromTime = markerData!["fromTime"]!
        //        let toTime = markerData!["toTime"]!
        
        infoWindow.lblCurrentAddress.text = address // address as? String
        //        infoWindow.priceLabel.text = "$\(String(format:"%.02f", (rate as? Float)!))/hr"
        //        infoWindow.availibilityLabel.text = "\(convertMinutesToTime(minutes: (fromTime as? Int)!)) - \(convertMinutesToTime(minutes: (toTime as? Int)!))"
        // Offset the info window to be directly above the tapped marker
        infoWindow.center = mapView.projection.point(for: location)
        infoWindow.center.y = infoWindow.center.y - 72
        self.view.addSubview(infoWindow)
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        infoWindow.removeFromSuperview()
    }
    
    func getLocationOfTappedMarker(latitude: Double,longitude: Double ) -> String {
        let url = NSURL(string: "\(baseUrlForGetAddress)latlng=\(latitude),\(longitude)&key=\(googleMapAddress)")
        do {
            let data = NSData(contentsOf: url! as URL)
            let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            if let result = json["results"] as? [[String:AnyObject]] {
                if result.count > 0 {
                    if let address = result[0]["address_components"] as? [[String:AnyObject]] {
                        
                        if address.count > 1 {
                            
                            var streetNumber = String()
                            var streetStreet = String()
                            var streetCity = String()
                            var streetState = String()
                            
                            for i in 0..<address.count {
                                
                                if i == 0 {
                                    if let number = address[i]["short_name"] as? String {
                                        streetNumber = number
                                    }
                                }
                                else if i == 1 {
                                    if let street = address[i]["short_name"] as? String {
                                        streetStreet = street
                                    }
                                }
                                else if i == 2 {
                                    if let city = address[i]["short_name"] as? String {
                                        streetCity = city
                                    }
                                }
                                else if i == 3 {
                                    if let state = address[i]["short_name"] as? String {
                                        streetState = state
                                    }
                                }
                                else if i == 4 {
                                    if let city = address[i]["short_name"] as? String {
                                        streetCity = city
                                    }
                                }
                            }
                            
                            
                            //                    let zip = address[6]["short_name"] as? String
                            print("\n\(streetNumber) \(streetStreet), \(streetCity), \(streetState)")
                            
                            
                            return "\(streetNumber) \(streetStreet), \(streetCity), \(streetState)"
                            
                            //                                UtilityClass.hideHUD()
                        }
                    }
                }
            }
        }
        catch {
            print("Not Geting Address")
            return "Not Geting Address"
        }
        return "Not Geting Address"
    }
    
    
    
    // ----------------------------------------------------------------------
    // MARK:- Driver Details
    // ----------------------------------------------------------------------
    
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverEmail: UILabel!
    @IBOutlet weak var lblDriverPhoneNumber: UILabel!
    @IBOutlet weak var imgDriverImage: UIImageView!
    @IBOutlet weak var viewDriverInformation: UIView!
    @IBOutlet weak var viewTripActions: UIView!
    
    @IBOutlet weak var btnCancelStartedTrip: UIButton!
    
    
    //MARK:-
    @IBOutlet weak var viewCarLists: UIView!
    @IBOutlet weak var viewForHalfCircle: UIView!
    
    /// Top is For 5S = 0 and 8Plus = -10
    @IBOutlet weak var constraintTopOfHalfCircleImage: NSLayoutConstraint!
    /// Bottom is For 5S = -20 and 8Plus = -5
    @IBOutlet weak var constraintBottomOfHalfCircleImage: NSLayoutConstraint!
    
    //PassengerId,ModelId,PickupLocation,DropoffLocation,PickupLat,PickupLng,DropOffLat,DropOffLon
    
    var strModelId = String()
    var strPickupLocation = String()
    var strDropoffLocation = String()
    var doublePickupLat = Double()
    var doublePickupLng = Double()
    var doubleUpdateNewLat = Double()
    var doubleUpdateNewLng = Double()
    var doubleDropOffLat = Double()
    var doubleDropOffLng = Double()
    var arrDataAfterCompletetionOfTrip = NSMutableArray()
    var selectedIndexPath: IndexPath?
    var strSpecialRequest = String()
    var strSpecialRequestFareCharge = String()
    
    var strFareId = String()
    
    @IBOutlet weak var ConstantViewCarListsHeight: NSLayoutConstraint! // 200 // 170
    @IBOutlet weak var constraintTopSpaceViewDriverInfo: NSLayoutConstraint!
    
    @IBOutlet weak var viewForMainFavourite: UIView!
    @IBOutlet weak var viewForFavourite: UIView!
    
    var loadingView: NVActivityIndicatorView!
    //---------------
    
    var sumOfFinalDistance = Double()
    
    var selectedRoute: Dictionary<String, AnyObject>!
    var overviewPolyline: Dictionary<String, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    var destinationCoordinate: CLLocationCoordinate2D!
    
    
    
    //---------------
    @IBOutlet var HomeViewGrandParentView: UIView!
    
    @IBOutlet weak var viewDestinationLocation: UIView!
    @IBOutlet weak var viewCurrentLocation: UIView!
    @IBOutlet weak var txtDestinationLocation: UITextField!
    @IBOutlet weak var txtCurrentLocation: UITextField!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var collectionViewCars: UICollectionView!
    
    @IBOutlet weak var viewTopViewOfTripPickupAndDropoffLocationSet: UIView!
    
    @IBOutlet weak var stackViewNumberOfPassenger: UIStackView!
    @IBOutlet weak var viewNotesOnBooking: UIView!
    @IBOutlet weak var imgTopViewOfTripPickupAndDropoffLocation: UIImageView!
    
    @IBOutlet weak var lblNumberOfPassengers: UILabel!
    @IBOutlet weak var lblNoOfBags: UILabel!
    @IBOutlet weak var lblApproxCost: UILabel!
    @IBOutlet weak var lblNotes: UITextField!
    
    
    
    
    var intNumberOfPassenger: Int = 1
    var intNoOfBages: Int = 0
    var intNoOfPassengersLimites = 4
    
    @IBAction func btnNumberOfPassenger(_ sender: UIButton) {
        if sender.titleLabel?.text == "-" {
            if intNumberOfPassenger != 1 {
                intNumberOfPassenger = intNumberOfPassenger - 1
            }
        }
        else if sender.titleLabel?.text == "+" {
            
            if intNumberOfPassenger < intNoOfPassengersLimites {
                intNumberOfPassenger = intNumberOfPassenger + 1
            }
        }
        
        lblNumberOfPassengers.text = "0\(intNumberOfPassenger)"
        
        if intNumberOfPassenger > 9 {
            lblNumberOfPassengers.text = "\(intNumberOfPassenger)"
        }
    }
    
    @IBAction func btnNoOfBags(_ sender: UIButton) {
        if sender.titleLabel?.text == "-" {
            if intNoOfBages != 0 {
                intNoOfBages = intNoOfBages - 1
            }
        }
        else if sender.titleLabel?.text == "+" {
            if intNoOfBages <= 5 {
                intNoOfBages = intNoOfBages + 1
            }
        }
        lblNoOfBags.text = "0\(intNoOfBages)"
    }
    
    
    
    var dropoffLat = Double()
    var dropoffLng = Double()
    
    
    //-------------------------------------------------------------
    // MARK: - Base Methods
    //-------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set Dummy Car
        setCarDummy()
        
        btnCarSelection(btnCarSelection.first!)
        
        txtSelectPaymentOption.delegate = self
        lblFairAndTimeForMaxVan.isHidden = false
        lblFairAndTimeForWaihekeExpress.isHidden = false
        lblFairAndTimeForBudgetTaxi.isHidden = false
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.black], for: UIControl.State.normal)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.setLocationFromBarAndClub(_:)), name: NotificationBookNow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.setBookLaterDestinationAddress(_:)), name: NotificationBookLater, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.webserviceOfRunningTripTrack), name: NotificationTrackRunningTrip, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.newBooking(_:)), name: NotificationForBookingNewTrip, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.callChatingMessage(notification:)), name: NotificationgetResponseOfChattingOfSpecificDriver, object: nil)
        
        
        self.btnDoneForLocationSelected.isHidden = true
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        
        stackViewNumberOfPassenger.isHidden = true
        viewNotesOnBooking.isHidden = true
        imgTopViewOfTripPickupAndDropoffLocation.image = UIImage(named: "iconHomeScreenTopView2")
        
        currentLocationMarkerText = "Current Location"
        destinationLocationMarkerText = "Destination Location"
        
        currentLocationMarker.isDraggable = true
        destinationLocationMarker.isDraggable = true
        
        moveMent = ARCarMovement()
        moveMent.delegate = self
        
        mapView.delegate = self
        
        self.setupGoogleMap()
        
        //        viewTopViewOfTripPickupAndDropoffLocationSet.layer.zPosition = 1
        btnFlatRate.setTitleColor(UIColor.black, for: .normal)
        btnPointToPoint.setTitleColor(UIColor.white, for: .normal)
        
        sortCarListFirstTime()
        webserviceOfCurrentBooking()
        setPaymentType()
        
        viewMainFinalRating.isHidden = true
        btnDriverInfo.layer.cornerRadius = 5
        btnDriverInfo.layer.masksToBounds = true
        btnRequest.layer.cornerRadius = 5
        btnRequest.layer.masksToBounds = true
        btnCurrentLocation.layer.cornerRadius = 5
        btnCurrentLocation.layer.masksToBounds = true
        
        self.btnCancelStartedTrip.isHidden = true
        
        giveRating.delegate = self
        
        ratingToDriver = 0.0
        
        paymentType = "cash"
        
        self.viewBookNow.isHidden = true
        stackViewOfPromocode.isHidden = true
        
        viewMainActivityIndicator.isHidden = true
        
        viewActivity.type = .ballPulse
        viewActivity.color = themeYellowColor
        
        viewHavePromocode.tintColor = themeYellowColor
        viewHavePromocode.stateChangeAnimation = .fill
        viewHavePromocode.boxType = .square
        
        viewTripActions.isHidden = true
        
        webserviceOfCardList()
        
        viewForMainFavourite.isHidden = true
        
        viewForFavourite.layer.cornerRadius = 5
        viewForFavourite.layer.masksToBounds = true
        
        SingletonClass.sharedInstance.isFirstTimeDidupdateLocation = true
        self.view.bringSubviewToFront(btnFavourite)
        
        callToWebserviceOfCardListViewDidLoad()
        
        currentLocationAction()
        
        //
        //        // Do any additional setup after loading the view.
        //         
        //
        //        viewCurrentLocation.layer.shadowOpacity = 0.3
        //        viewCurrentLocation.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        //
        //        viewDestinationLocation.layer.shadowOpacity = 0.3
        //        viewDestinationLocation.layer.shadowOffset = CGSize(width: 3.0, height: 2.0)
        //
        //        self.setupSideMenu()
        ////        webserviceCallForGettingCarLists()
        //
    }
    
    
    func setViewDidLoad() {
        
        lblFairAndTimeForMaxVan.isHidden = false
        lblFairAndTimeForWaihekeExpress.isHidden = false
        lblFairAndTimeForBudgetTaxi.isHidden = false
        
        self.btnDoneForLocationSelected.isHidden = true
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        
        stackViewNumberOfPassenger.isHidden = true
        viewNotesOnBooking.isHidden = true
        imgTopViewOfTripPickupAndDropoffLocation.image = UIImage(named: "iconHomeScreenTopView2")
        
        currentLocationMarkerText = "Current Location"
        destinationLocationMarkerText = "Destination Location"
        
        currentLocationMarker.isDraggable = true
        destinationLocationMarker.isDraggable = true
        
        moveMent = ARCarMovement()
        moveMent.delegate = self
        
        mapView.delegate = self
        
        btnFlatRate.setTitleColor(UIColor.black, for: .normal)
        btnPointToPoint.setTitleColor(UIColor.white, for: .normal)
        
        viewMainFinalRating.isHidden = true
        btnDriverInfo.layer.cornerRadius = 5
        btnDriverInfo.layer.masksToBounds = true
        btnRequest.layer.cornerRadius = 5
        btnRequest.layer.masksToBounds = true
        btnCurrentLocation.layer.cornerRadius = 5
        btnCurrentLocation.layer.masksToBounds = true
        
        self.btnCancelStartedTrip.isHidden = true
        
        giveRating.delegate = self
        
        ratingToDriver = 0.0
        
        paymentType = "cash"
        
        self.viewBookNow.isHidden = true
        stackViewOfPromocode.isHidden = true
        
        viewMainActivityIndicator.isHidden = true
        
        viewActivity.type = .ballPulse
        viewActivity.color = themeYellowColor
        
        viewHavePromocode.tintColor = themeYellowColor
        viewHavePromocode.stateChangeAnimation = .fill
        viewHavePromocode.boxType = .square
        
        viewForMainFavourite.isHidden = true
        
        viewForFavourite.layer.cornerRadius = 5
        viewForFavourite.layer.masksToBounds = true
        
        SingletonClass.sharedInstance.isFirstTimeDidupdateLocation = true
        self.view.bringSubviewToFront(btnFavourite)
    }
    
    @IBOutlet weak var viewHeaderHeightConstant: NSLayoutConstraint!
    
    func setHeaderForIphoneX() {
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436,1792:
                
                viewHeaderHeightConstant.constant = 80
            default:
                print("Height of device is \(UIScreen.main.nativeBounds.height)")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.btnDoneForLocationSelected.isHidden = true
        //        setupGoogleMap()
        
        //        viewTripActions.isHidden = true
        
        // This is For Book Later Address
        if (SingletonClass.sharedInstance.isFromNotificationBookLater) {
            
            if strCarModelID == "" {
                
                UtilityClass.setCustomAlert(title: appName, message: "Select Car") { (index, title) in
                }
            }
            else if strDestinationLocationForBookLater != "" {
                let profileData = SingletonClass.sharedInstance.dictProfile
                
                let next = self.storyboard?.instantiateViewController(withIdentifier: "BookLaterViewController") as! BookLaterViewController
                
                SingletonClass.sharedInstance.isFromNotificationBookLater = false
                
                next.strModelId = strCarModelID
                next.strCarModelURL = strNavigateCarModel
                next.strCarName = strCarModelClass
                
                next.strFullname = profileData.object(forKey: "Fullname") as! String
                next.strMobileNumber = profileData.object(forKey: "MobileNo") as! String
                next.strDropoffLocation = strDestinationLocationForBookLater
                next.doubleDropOffLat = dropOffLatForBookLater
                next.doubleDropOffLng = dropOffLngForBookLater
                
                self.navigationController?.pushViewController(next, animated: true)
            }
            else {
                
                UtilityClass.setCustomAlert(title: appName, message: "We did not get proper address") { (index, title) in
                }
            }
            
        }
        
        viewSubFinalRating.layer.cornerRadius = 5
        viewSubFinalRating.layer.masksToBounds = true
        
        viewSelectPaymentOption.layer.borderWidth = 1.0
        viewSelectPaymentOption.layer.borderColor = UIColor.gray.cgColor
        viewSelectPaymentOption.layer.cornerRadius = 5
        viewSelectPaymentOption.layer.masksToBounds = true
        
        viewSelectPaymentOptionParent.layer.cornerRadius = 5
        viewSelectPaymentOptionParent.layer.masksToBounds = true
        
        
        if(locationManager != nil)
        {
            locationManager.startUpdatingLocation()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        //
        //
        
        //        if (self.mapView != nil)
        //        {
        //
        //        self.mapView.clear()
        ////        self.mapView.stopRendering()
        ////        self.mapView.removeFromSuperview()
        ////        self.mapView = nil
        //        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setHeaderForIphoneX()
        
        self.arrTotalNumberOfCars = NSMutableArray(array: SingletonClass.sharedInstance.arrCarLists)
        
        self.arrDemoCarList = self.arrTotalNumberOfCars as! [[String : Any]]
        
        //        self.setupGoogleMap()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (DeviceType.IS_IPHONE_5) {
            constraintTopOfHalfCircleImage.constant = 0
            constraintBottomOfHalfCircleImage.constant = -20
        }
        else {
            constraintTopOfHalfCircleImage.constant = -10
            constraintBottomOfHalfCircleImage.constant = -5
        }
        
        let pieChart = PieChart(frame: CGRect(x: viewForHalfCircle.frame.origin.x, y: viewForHalfCircle.frame.origin.y, width: viewForHalfCircle.frame.size.width, height: viewForHalfCircle.frame.size.height))
        pieChart.backgroundColor = UIColor.clear
    }
    
    //-------------------------------------------------------------
    // MARK: - Notification Center Methods
    //-------------------------------------------------------------
    
    
    @objc func setLocationFromBarAndClub(_ notification: NSNotification) {
        
        print("Notification Data : \(notification)")
        
        if let Address = notification.userInfo?["Address"] as? String {
            // do something with your image
            txtDestinationLocation.text = Address
            strDropoffLocation = Address
            
            if let lat = notification.userInfo?["lat"] as? Double {
                
                if lat != 0 {
                    doubleDropOffLat = Double(lat)
                }
            }
            
            if let lng = notification.userInfo?["lng"] as? Double {
                
                if lng != 0 {
                    doubleDropOffLng = Double(lng)
                }
            }
        }
        
    }
    
    var strDestinationLocationForBookLater = String()
    var dropOffLatForBookLater = Double()
    var dropOffLngForBookLater = Double()
    
    @objc func setBookLaterDestinationAddress(_ notification: NSNotification) {
        
        print("Notification Data : \(notification)")
        
        if let Address = notification.userInfo?["Address"] as? String {
            // do something with your image
            strDestinationLocationForBookLater = Address
            
            if let lat = notification.userInfo?["lat"] as? Double {
                
                if lat != 0 {
                    dropOffLatForBookLater = Double(lat)
                }
            }
            
            if let lng = notification.userInfo?["lng"] as? Double {
                
                if lng != 0 {
                    dropOffLngForBookLater = Double(lng)
                }
            }
            
        }
    }
    @IBOutlet weak var constraintTopOfLocationDetails: NSLayoutConstraint! // 0
    
    
    @IBOutlet weak var btnLocationDetailsToggle: UIButton!
    
    @IBAction func btnLocationDetailsToggle(_ sender: UIButton) {
        
        if sender.currentImage == UIImage(named: "iconArrowUpBlack") {
            
            sender.setImage(UIImage(named: "iconArrowDownBlack"), for: .normal)
            
            if (stackViewNumberOfPassenger.isHidden) {
                constraintTopOfLocationDetails.constant = -150 // -130
                imgTopViewOfTripPickupAndDropoffLocation.image = UIImage(named: "iconHomeScreenTopView2")
            }
            else {
                constraintTopOfLocationDetails.constant = -260
                imgTopViewOfTripPickupAndDropoffLocation.image = UIImage(named: "iconHomeScreenTopView")
            }
            
            UIView.animate(withDuration: 0.5) {
                self.HomeViewGrandParentView.layoutIfNeeded()
            }
            
        }
        else if sender.currentImage == UIImage(named: "iconArrowDownBlack") {
            
            sender.setImage(UIImage(named: "iconArrowUpBlack"), for: .normal)
            constraintTopOfLocationDetails.constant = 0
            UIView.animate(withDuration: 0.5) {
                self.HomeViewGrandParentView.layoutIfNeeded()
            }
        }
        else {
            sender.setImage(UIImage(named: "iconArrowDownBlack"), for: .normal)
            
            if (stackViewNumberOfPassenger.isHidden) {
                constraintTopOfLocationDetails.constant = -150 // -130
                imgTopViewOfTripPickupAndDropoffLocation.image = UIImage(named: "iconHomeScreenTopView2")
            }
            else {
                constraintTopOfLocationDetails.constant = -260
                imgTopViewOfTripPickupAndDropoffLocation.image = UIImage(named: "iconHomeScreenTopView")
            }
            
            UIView.animate(withDuration: 0.5) {
                self.HomeViewGrandParentView.layoutIfNeeded()
            }
        }
    }
    
    func showBtnLocationDetailsToggle() {
        
        btnLocationDetailsToggle.setImage(UIImage(named: "iconArrowUpBlack"), for: .normal)
        constraintTopOfLocationDetails.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.HomeViewGrandParentView.layoutIfNeeded()
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - setMap and Location Methods
    //-------------------------------------------------------------
    
    
    @IBOutlet weak var btnDoneForLocationSelected: UIButton!
    @IBAction func btnDoneForLocationSelected(_ sender: UIButton) {
        
        clearMap()
        self.routePolyline.map = nil
        if strLocationType == currentLocationMarkerText {
            
            btnDoneForLocationSelected.isHidden = true
            if txtDestinationLocation.text?.count != 0 {
                txtDestinationLocation.isFirstResponder
            }
        }
        else if strLocationType == destinationLocationMarkerText {
            
            btnDoneForLocationSelected.isHidden = true
        }
        
        if txtCurrentLocation.text != "" && txtDestinationLocation.text != "" {
            
            setupBothCurrentAndDestinationMarkerAndPolylineOnMap()
            
            self.collectionViewCars.reloadData()
            btnDoneForLocationSelected.isHidden = true
            self.viewCarLists.isHidden = false
            self.ConstantViewCarListsHeight.constant = 200 // 150
        }
        else {
            self.ConstantViewCarListsHeight.constant = 0
            self.viewCarLists.isHidden = true
        }
        
    }
    
    
    @IBOutlet weak var btnCurrentLocation: UIButton!
    var currentLocationMarker = GMSMarker()
    var destinationLocationMarker = GMSMarker()
    
    var routePolyline = GMSPolyline()
    var demoPolylineOLD = GMSPolyline()
    
    @IBAction func btnCurrentLocation(_ sender: UIButton) {
        //        DispatchQueue.global(qos: .background).sync {
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        
        DispatchQueue.main.async {
            self.btnCorrentLocationClickedAction()
            self.clearDestinationLocation()
            
            self.setClearTextFieldsOfExtra()
        }
        
        //        }
        
    }
    
    func btnCorrentLocationClickedAction() {
        
        currentLocationAction()
        constraintTopOfLocationDetails.constant = 0
        UIView.animate(withDuration: 0.5) {
            self.HomeViewGrandParentView.layoutIfNeeded()
        }
        btnLocationDetailsToggle.setImage(UIImage.init(named: "iconArrowDownBlack"), for: .normal)
        MarkerCurrntLocation.isHidden = false
        txtDestinationLocation.text = ""
        strDropoffLocation = ""
        doubleDropOffLat = 0
        doubleDropOffLng = 0
        self.destinationLocationMarker.map = nil
        self.currentLocationMarker.map = nil
        self.strLocationType = self.currentLocationMarkerText
        self.routePolyline.map = nil
        
        stackViewNumberOfPassenger.isHidden = true
        viewNotesOnBooking.isHidden = true
        
        //        imgTopViewOfTripPickupAndDropoffLocation.image = UIImage(named: "iconHomeScreenTopView2")
        viewTopViewOfTripPickupAndDropoffLocationSet.isHidden = false
        
        //        self.btnDoneForLocationSelected.isHidden = false
        //        self.ConstantViewCarListsHeight.constant = 0
        //        self.viewCarLists.isHidden = true
        
        
    }
    
    
    func currentLocationAction() {
        
        clearMap()
        
        txtDestinationLocation.text = ""
        strDropoffLocation = ""
        doubleDropOffLat = 0
        doubleDropOffLng = 0
        self.destinationLocationMarker.map = nil
        self.currentLocationMarker.map = nil
        self.strLocationType = self.currentLocationMarkerText
        self.btnDoneForLocationSelected.isHidden = false
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        
        mapView.delegate = self
        
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: 17.5)
        
        mapView.camera = camera
        
        MarkerCurrntLocation.isHidden = false
        
        self.doublePickupLat = (defaultLocation.coordinate.latitude)
        self.doublePickupLng = (defaultLocation.coordinate.longitude)
        
        let strLati: String = "\(self.doublePickupLat)"
        let strlongi: String = "\(self.doublePickupLng)"
        //
        getAddressForLatLng(latitude: strLati, longitude: strlongi, markerType: currentLocationMarkerText)
        
        //        let position = CLLocationCoordinate2D(latitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude)
        //        currentLocationMarker = GMSMarker(position: position)
        //        currentLocationMarker.map = self.mapView
        //        currentLocationMarker.snippet = currentLocationMarkerText // "Current Location"
        //        currentLocationMarker.icon = UIImage(named: "iconCurrentLocation")
        //        currentLocationMarker.isDraggable = true
    }
    
    
    func getAddressForLatLng(latitude: String, longitude: String, markerType: String) {
        
        if markerType == currentLocationMarkerText {
            let url = URL(string: "\(baseUrlForGetAddress)latlng=\(latitude),\(longitude)&key=\(googleMapAddress)")
            print("Link is : \(url)")
            do {
                let data = NSData(contentsOf: url! as URL)
                let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                if let result = json["results"] as? [[String:AnyObject]] {
                    if result.count > 0 {
                        
                        if let resString = result[0]["formatted_address"] as? String {
                            
                            self.txtCurrentLocation.text = resString
                            self.strPickupLocation = resString
                            btnDoneForLocationSelected.isHidden = false
                            
                        }
                        else if let address = result[0]["address_components"] as? [[String:AnyObject]] {
                            
                            if address.count > 1 {
                                
                                var streetNumber = String()
                                var streetStreet = String()
                                var streetCity = String()
                                var streetState = String()
                                
                                for i in 0..<address.count {
                                    
                                    if i == 0 {
                                        if let number = address[i]["short_name"] as? String {
                                            streetNumber = number
                                        }
                                    }
                                    else if i == 1 {
                                        if let street = address[i]["short_name"] as? String {
                                            streetStreet = street
                                        }
                                    }
                                    else if i == 2 {
                                        if let city = address[i]["short_name"] as? String {
                                            streetCity = city
                                        }
                                    }
                                    else if i == 3 {
                                        if let state = address[i]["short_name"] as? String {
                                            streetState = state
                                        }
                                    }
                                    else if i == 4 {
                                        if let city = address[i]["short_name"] as? String {
                                            streetCity = city
                                        }
                                    }
                                }
                                
                                
                                //                    let zip = address[6]["short_name"] as? String
                                print("\n\(streetNumber) \(streetStreet), \(streetCity), \(streetState)")
                                
                                
                                self.txtCurrentLocation.text = "\(streetNumber) \(streetStreet), \(streetCity), \(streetState)"
                                self.strPickupLocation = "\(streetNumber) \(streetStreet), \(streetCity), \(streetState)"
                                
                                //                                UtilityClass.hideHUD()
                            }
                        }
                    }
                }
            }
            catch {
                print("Not Geting Address")
            }
        }
        else if markerType == destinationLocationMarkerText {
            let url = NSURL(string: "\(baseUrlForGetAddress)latlng=\(latitude),\(longitude)&key=\(googleMapAddress)")
            print("Link is : \(url)")
            do {
                let data = NSData(contentsOf: url! as URL)
                let json = try! JSONSerialization.jsonObject(with: data! as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                if let result = json["results"] as? [[String:AnyObject]] {
                    if result.count > 0 {
                        
                        if let resString = result[0]["formatted_address"] as? String {
                            
                            self.txtDestinationLocation.text = resString
                            self.strDropoffLocation = resString
                            
                        }
                        else if let address = result[0]["address_components"] as? [[String:AnyObject]] {
                            
                            if address.count > 1 {
                                
                                var streetNumber = String()
                                var streetStreet = String()
                                var streetCity = String()
                                var streetState = String()
                                
                                
                                for i in 0..<address.count {
                                    
                                    if i == 0 {
                                        if let number = address[i]["short_name"] as? String {
                                            streetNumber = number
                                        }
                                    }
                                    else if i == 1 {
                                        if let street = address[i]["short_name"] as? String {
                                            streetStreet = street
                                        }
                                    }
                                    else if i == 2 {
                                        if let city = address[i]["short_name"] as? String {
                                            streetCity = city
                                        }
                                    }
                                    else if i == 3 {
                                        if let state = address[i]["short_name"] as? String {
                                            streetState = state
                                        }
                                    }
                                    else if i == 4 {
                                        if let city = address[i]["short_name"] as? String {
                                            streetCity = city
                                        }
                                    }
                                }
                                /*
                                 if address.count == 4 {
                                 if let number = address[0]["short_name"] as? String {
                                 streetNumber = number
                                 }
                                 if let street = address[1]["short_name"] as? String {
                                 streetStreet = street
                                 }
                                 if let city = address[2]["short_name"] as? String {
                                 streetCity = city
                                 }
                                 if let state = address[3]["short_name"] as? String {
                                 streetState = state
                                 }
                                 }
                                 else {
                                 
                                 if let number = address[0]["short_name"] as? String {
                                 streetNumber = number
                                 }
                                 if let street = address[1]["short_name"] as? String {
                                 streetStreet = street
                                 }
                                 if let city = address[2]["short_name"] as? String {
                                 streetCity = city
                                 }
                                 if let state = address[4]["short_name"] as? String {
                                 streetState = state
                                 }
                                 }
                                 */
                                //                    let zip = address[6]["short_name"] as? String
                                print("\n\(streetNumber) \(streetStreet), \(streetCity), \(streetState)")
                                
                                
                                
                                self.txtDestinationLocation.text = "\(streetNumber) \(streetStreet), \(streetCity), \(streetState)"
                                self.strDropoffLocation = "\(streetNumber) \(streetStreet), \(streetCity), \(streetState)"
                                //                                UtilityClass.hideHUD()
                            }
                        }
                    }
                }
            }
            catch {
                print("Not Geting Address")
            }
        }
        
    }
    
    
    
    @IBOutlet weak var btnFavourite: UIButton!
    @IBAction func btnFavourite(_ sender: UIButton) {
        
        if txtDestinationLocation.text!.count == 0 {
            
            UtilityClass.setCustomAlert(title: appName, message: "Enter Destination Address") { (index, title) in
            }
        }
        else {
            UIView.transition(with: viewForMainFavourite, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
                self.viewForMainFavourite.isHidden = false
            }) { _ in }
            
        }
        
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
    func setPaymentType() {
        
        pickerView.selectRow(0, inComponent: 0, animated: true)
        
        imgPaymentType.image = UIImage(named: "iconCashBlack")
        txtSelectPaymentOption.text = "cash"
        
    }
    
    func setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: Bool) {
        
        viewCurrentLocation.isHidden = status
        viewDestinationLocation.isHidden = status
        btnCurrentLocation.isHidden = status
        viewTopViewOfTripPickupAndDropoffLocationSet.isHidden = status
    }
    
    
    //Mark - Webservice Call For Miss Booking Request
    func webserviceCallForMissBookingRequest()
    {
        
        var dictParam = [String:AnyObject]()
        dictParam["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        dictParam["ModelId"] = strCarModelIDIfZero as AnyObject
        dictParam["PickupLocation"] = self.strPickupLocation as AnyObject
        dictParam["DropoffLocation"] = self.strDropoffLocation as AnyObject
        dictParam["PickupLat"] = doublePickupLat as AnyObject
        dictParam["PickupLng"] = doublePickupLng as AnyObject
        dictParam["DropOffLat"] = doubleDropOffLat as AnyObject
        dictParam["DropOffLon"] = doubleDropOffLng as AnyObject
        dictParam["Notes"] = "" as AnyObject
        
        webserviceForMissBookingRequest(dictParam as AnyObject) { (result, status) in
            
        }
    }
    
    
    //MARK:- Webservice Call for Booking Requests
    func webserviceCallForBookingCar()
    {
        
        //PassengerId,ModelId,PickupLocation,DropoffLocation,PickupLat,PickupLng,DropOffLat,DropOffLon
        //,PromoCode,Notes,PaymentType,CardId(If paymentType is card)
        
        let dictParams = NSMutableDictionary()
        dictParams.setObject(SingletonClass.sharedInstance.strPassengerID, forKey: "PassengerId" as NSCopying)
        dictParams.setObject(strModelId, forKey: SubmitBookingRequest.kModelId as NSCopying)
        if(strModelId == "")
        {
            dictParams.setObject(strCarModelIDIfZero, forKey: SubmitBookingRequest.kModelId as NSCopying)
            
        }
        dictParams.setObject(strPickupLocation, forKey: SubmitBookingRequest.kPickupLocation as NSCopying)
        dictParams.setObject(strDropoffLocation, forKey: SubmitBookingRequest.kDropoffLocation as NSCopying)
        
        dictParams.setObject(doublePickupLat, forKey: SubmitBookingRequest.kPickupLat as NSCopying)
        dictParams.setObject(doublePickupLng, forKey: SubmitBookingRequest.kPickupLng as NSCopying)
        
        dictParams.setObject(doubleDropOffLat, forKey: SubmitBookingRequest.kDropOffLat as NSCopying)
        dictParams.setObject(doubleDropOffLng, forKey: SubmitBookingRequest.kDropOffLon as NSCopying)
        
        dictParams.setObject(txtNote.text!, forKey: SubmitBookingRequest.kNotes as NSCopying)
        dictParams.setObject(strSpecialRequest, forKey: SubmitBookingRequest.kSpecial as NSCopying)
        
        if paymentType == "" {
        }
        else {
            dictParams.setObject(paymentType, forKey: SubmitBookingRequest.kPaymentType as NSCopying)
        }
        
        if txtHavePromocode.text == "" {
            
        }
        else {
            dictParams.setObject(txtHavePromocode.text!, forKey: SubmitBookingRequest.kPromoCode as NSCopying)
        }
        
        if CardID == "" {
            
        }
        else {
            dictParams.setObject(CardID, forKey: SubmitBookingRequest.kCardId as NSCopying)
        }
        
        dictParams.setObject(lblNoOfBags.text!, forKey: SubmitBookingRequest.kNoOfLuggage as NSCopying)
        dictParams.setObject(lblNumberOfPassengers.text!, forKey: SubmitBookingRequest.kNoOfPassenger as NSCopying)
        
        
        if strServiceType == ServiceType.FlatRate.rawValue {
            if dictFlatRate != nil {
                dictParams.setObject(dictFlatRate!["Id"] as! String, forKey: "FlatRateId" as NSCopying)
            }
        }
        else {
            strServiceType = ServiceType.PointToPoint.rawValue
        }
        
        dictParams.setObject(strServiceType, forKey: "ServiceType" as NSCopying)
        
        dictParams.setObject(valueTMCardHolde, forKey: "TMCardHolder" as NSCopying)
        dictParams.setObject(valueBabySeater, forKey: "BabySeater" as NSCopying)
        dictParams.setObject(valueHoistVan, forKey: "HoistVan" as NSCopying)
        
        dictParams.setObject(strFareId, forKey: "FareId" as NSCopying)
        //,NoOfLuggage,NoOfPassenger,
        
        self.view.bringSubviewToFront(self.viewMainActivityIndicator)
        self.viewMainActivityIndicator.isHidden = false
        webserviceForTaxiRequest(dictParams) { (result, status) in
            
            if (status) {
                //      print(result)
                
                SingletonClass.sharedInstance.bookedDetails = (result as! NSDictionary)
                
                if let bookingId = ((result as! NSDictionary).object(forKey: "details") as! NSDictionary).object(forKey: "BookingId") as? Int {
                    SingletonClass.sharedInstance.bookingId = "\(bookingId)"
                }
                
                self.strBookingType = "BookNow"
                self.viewBookNow.isHidden = true
                self.viewActivity.startAnimating()
                
            }
            else {
                //    print(result)
                
                self.viewBookNow.isHidden = true
                self.viewMainActivityIndicator.isHidden = true
                
                if let res = result as? String {
                    UtilityClass.setCustomAlert(title: appName, message: res) { (index, title) in
                    }
                }
                else if let resDict = result as? NSDictionary {
                    if((resDict.object(forKey: "message") as? NSArray) != nil)
                    {
                        UtilityClass.setCustomAlert(title: appName, message: (resDict.object(forKey: "message") as! NSArray).object(at: 0) as! String) { (index, title) in
                        }
                    }
                    else
                    {
                        UtilityClass.setCustomAlert(title: appName, message: resDict.object(forKey: "message") as! String) { (index, title) in
                        }
                    }
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.setCustomAlert(title: appName, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    }
                }
            }
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - View Book Now
    //-------------------------------------------------------------
    
    @IBAction func tapToDismissActivityIndicator(_ sender: UITapGestureRecognizer) {
        viewMainActivityIndicator.isHidden = true
        
        //        socketMethodForCancelRequestTrip()
        
    }
    @IBOutlet weak var viewMainActivityIndicator: UIView!
    @IBOutlet weak var viewActivity: NVActivityIndicatorView!
    
    @IBOutlet weak var viewBookNow: UIView!
    
    @IBOutlet weak var viewSelectPaymentOptionParent: UIView!
    @IBOutlet weak var viewSelectPaymentOption: UIView!
    @IBOutlet weak var txtSelectPaymentOption: UITextField!
    
    @IBOutlet weak var viewHavePromocode: M13Checkbox!
    @IBOutlet weak var stackViewOfPromocode: UIStackView!
    
    @IBOutlet weak var imgPaymentType: UIImageView!
    @IBOutlet weak var txtHavePromocode: UITextField!
    @IBOutlet weak var txtNote: UITextField!
    
    
    
    
    
    
    var boolIsSelected = Bool()
    
    var pickerView = UIPickerView()
    
    var CardID = String()
    var paymentType = String()
    
    @IBAction func btnPromocode(_ sender: UIButton) {
        
        boolIsSelected = !boolIsSelected
        
        if (boolIsSelected) {
            stackViewOfPromocode.isHidden = false
            viewHavePromocode.checkState = .checked
            viewHavePromocode.stateChangeAnimation = .fill
        }
        else {
            stackViewOfPromocode.isHidden = true
            viewHavePromocode.checkState = .unchecked
            viewHavePromocode.stateChangeAnimation = .fill
        }
        
    }
    
    @IBAction func viewHavePromocode(_ sender: M13Checkbox) {
        
        //        boolIsSelected = !boolIsSelected
        //
        //        if (boolIsSelected) {
        //            stackViewOfPromocode.isHidden = false
        //        }
        //        else {
        //            stackViewOfPromocode.isHidden = true
        //
        //        }
    }
    @IBAction func tapToDismissBookNowView(_ sender: UITapGestureRecognizer) {
        viewBookNow.isHidden = true
        
    }
    
    @IBAction func txtPaymentOption(_ sender: UITextField) {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        txtSelectPaymentOption.inputView = pickerView
    }
    
    
    @IBAction func btnRequestNow(_ sender: UIButton) {
        
        self.webserviceCallForBookingCar()
    }
    
    
    
    // ----------------------------------------------------------------------
    
    
    //-------------------------------------------------------------
    // MARK: - PickerView Methods
    //-------------------------------------------------------------
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cardData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    //    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    //
    //    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let data = cardData[row]
        
        let myView = UIView(frame: CGRect(x:0, y:0, width: pickerView.bounds.width - 30, height: 60))
        
        let myImageView = UIImageView(frame: CGRect(x:0, y:0, width:50, height:50))
        
        var rowString = String()
        
        
        switch row {
            
        case 0:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 1:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 2:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 3:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 4:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 5:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 6:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 7:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 8:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 9:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        case 10:
            rowString = data["CardNum2"] as! String
            myImageView.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        default:
            rowString = "Error: too many rows"
            myImageView.image = nil
        }
        let myLabel = UILabel(frame: CGRect(x:60, y:0, width:pickerView.bounds.width - 90, height:60 ))
        //        myLabel.font = UIFont(name:some, font, size: 18)
        myLabel.text = rowString
        
        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        
        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let data = cardData[row]
        
        imgPaymentType.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        txtSelectPaymentOption.text = data["CardNum2"] as? String
        
        let type = data["CardNum"] as! String
        
        if type  == "wallet" {
            paymentType = "wallet"
        }
        else if type == "cash" {
            paymentType = "cash"
        }
        else if type == "credit" {
            paymentType = "credit"
        }
        else {
            paymentType = "card"
        }
        
        if paymentType == "card" {
            CardID = data["Id"] as! String
        }
        
        
        
        // do something with selected row
    }
    
    func setCardIcon(str: String) -> String {
        //        visa , mastercard , amex , diners , discover , jcb , other
        var CardIcon = String()
        
        switch str {
        case "visa":
            CardIcon = "Visa"
            return CardIcon
        case "mastercard":
            CardIcon = "MasterCard"
            return CardIcon
        case "amex":
            CardIcon = "Amex"
            return CardIcon
        case "diners":
            CardIcon = "Diners Club"
            return CardIcon
        case "discover":
            CardIcon = "Discover"
            return CardIcon
        case "jcb":
            CardIcon = "JCB"
            return CardIcon
        case "iconCashBlack":
            CardIcon = "iconCashBlack"
            return CardIcon
        case "iconWalletBlack":
            CardIcon = "iconWalletBlack"
            return CardIcon
        case "other":
            CardIcon = "iconDummyCard"
            return CardIcon
        default:
            return ""
        }
        
    }
    
    
    // ----------------------------------------------------------------------
    //-------------------------------------------------------------
    // MARK: - Webservice For Find Cards List Available
    //-------------------------------------------------------------
    
    func callToWebserviceOfCardListViewDidLoad() {
        
        // Register to receive notification
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.reloadWebserviceOfCardList), name: NSNotification.Name(rawValue: "CardListReload"), object: nil)
        
    }
    
    var isReloadWebserviceOfCardList = Bool()
    
    @objc func reloadWebserviceOfCardList() {
        
        
        self.webserviceOfCardList()
        isReloadWebserviceOfCardList = true
        
        self.paymentOptions()
        
    }
    
    var aryCardsListForBookNow = [[String:AnyObject]]()
    
    func webserviceOfCardList() {
        
        webserviceForCardList(SingletonClass.sharedInstance.strPassengerID as AnyObject) { (result, status) in
            
            if (status) {
                //        print(result)
                
                if let res = result as? [String:AnyObject] {
                    if let cards = res["cards"] as? [[String:AnyObject]] {
                        self.aryCardsListForBookNow = cards
                    }
                }
                
                var dict = [String:AnyObject]()
                dict["CardNum"] = "cash" as AnyObject
                dict["CardNum2"] = "cash" as AnyObject
                dict["Type"] = "iconCashBlack" as AnyObject
                
                var dict2 = [String:AnyObject]()
                dict2["CardNum"] = "wallet" as AnyObject
                dict2["CardNum2"] = "wallet" as AnyObject
                dict2["Type"] = "iconWalletBlack" as AnyObject
                
                
                self.aryCardsListForBookNow.append(dict)
                self.aryCardsListForBookNow.append(dict2)
                
                
                var dict3 = [String:AnyObject]()
                dict3["CardNum"] = "credit" as AnyObject
                dict3["CardNum2"] = "credit" as AnyObject
                dict3["Type"] = "iconWalletBlack" as AnyObject
                
                
                if(UtilityClass.returnValueForCredit(key: "IsRequestCreditAccount") == "2")
                {
                    self.aryCardsListForBookNow.append(dict3)
                    
                }
                
                SingletonClass.sharedInstance.CardsVCHaveAryData = (result as! NSDictionary).object(forKey: "cards") as! [[String:AnyObject]]
                
                self.pickerView.reloadAllComponents()
                
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "CardListReload"), object: nil)
                
                
                
                
                
                /*
                 {
                 cards =     (
                 {
                 Alias = visa;
                 CardNum = 4639251002213023;
                 CardNum2 = "xxxx xxxx xxxx 3023";
                 Id = 59;
                 Type = visa;
                 }
                 );
                 status = 1;
                 }
                 */
                
                
            }
            else {
                //    print(result)
                if let res = result as? String {
                    UtilityClass.setCustomAlert(title: appName, message: res) { (index, title) in
                    }
                }
                else if let resDict = result as? NSDictionary {
                    UtilityClass.setCustomAlert(title: appName, message: resDict.object(forKey: "message") as! String) { (index, title) in
                    }
                }
                else if let resAry = result as? NSArray {
                    UtilityClass.setCustomAlert(title: appName, message: (resAry.object(at: 0) as! NSDictionary).object(forKey: "message") as! String) { (index, title) in
                    }
                }
            }
        }
    }
    
    
    //MARK:- SideMenu Methods
    
    @IBOutlet weak var openSideMenu: UIButton!
    @IBAction func openSideMenu(_ sender: Any) {
        
        sideMenuController?.toggle()
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods for Add Address to Favourite
    //-------------------------------------------------------------
    
    func webserviceOfAddAddressToFavourite(type: String) {
        //        PassengerId,Type,Address,Lat,Lng
        
        var param = [String:AnyObject]()
        param["PassengerId"] = SingletonClass.sharedInstance.strPassengerID as AnyObject
        param["Type"] = type as AnyObject
        param["Address"] = txtDestinationLocation.text as AnyObject
        param["Lat"] = doubleDropOffLat as AnyObject  // SingletonClass.sharedInstance.currentLatitude as AnyObject
        param["Lng"] = doubleDropOffLng as AnyObject  // SingletonClass.sharedInstance.currentLongitude as AnyObject
        
        webserviceForAddAddress(param as AnyObject) { (result, status) in
            
            if (status) {
                //  print(result)
                
                if let res = result as? String {
                    
                    UtilityClass.setCustomAlert(title: appName, message: res) { (index, title) in
                    }
                }
                else if let res = result as? NSDictionary {
                    
                    let alert = UIAlertController(title: nil, message: res.object(forKey: "message") as? String, preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default, handler: { ACTION in
                        
                        UIView.transition(with: self.viewForMainFavourite, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
                            self.viewForMainFavourite.isHidden = true
                        }) { _ in }
                    })
                    alert.addAction(OK)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            }
            else {
                //     print(result)
            }
        }
    }
    
    //MARK: - Setup Google Maps
    func setupGoogleMap()
    {
        // Initialize the location manager.
        //        locationManager = CLLocationManager()
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.requestAlwaysAuthorization()
        //        locationManager.distanceFilter = 0.1
        //        locationManager.delegate = self
        //        locationManager.startUpdatingLocation()
        //        locationManager.startUpdatingHeading()
        
        locationManager.delegate = self
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            
            if (locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization)) || locationManager.responds(to: #selector(CLLocationManager.requestAlwaysAuthorization)))
            {
                if locationManager.location != nil
                {
                    locationManager.startUpdatingLocation()
                    
                }
                
            }
        }
        
        
        placesClient = GMSPlacesClient.shared()
        
        mapView.delegate = self
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: 17)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        
        mapView.camera = camera
        
        //        let position = CLLocationCoordinate2D(latitude: defaultLocation.coordinate.latitude, longitude: defaultLocation.coordinate.longitude)
        //        let marker = GMSMarker(position: position)
        //        marker.map = self.mapView
        //        marker.isDraggable = true
        //        marker.icon = UIImage(named: "iconCurrentLocation")
        
        
        //        mapView.settings.myLocationButton = false
        //        mapView.isMyLocationEnabled = true
        
        
        
        //        self.mapView.padding = UIEdgeInsets(top:txtDestinationLocation.frame.size.height + txtDestinationLocation.frame.origin.y, left: 0, bottom: 0, right: 0)
        
        viewMap.addSubview(mapView)
        mapView.isHidden = true
        
    }
    
    func getPlaceFromLatLong()
    {
        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            //            self.txtCurrentLocation.text = "No current place"
            self.txtCurrentLocation.text = ""
            
            if let placeLikelihoodList = placeLikelihoodList {
                let place = placeLikelihoodList.likelihoods.first?.place
                if let place = place {
                    self.strPickupLocation = place.formattedAddress!
                    self.doublePickupLat = place.coordinate.latitude
                    self.doublePickupLng = place.coordinate.longitude
                    self.txtCurrentLocation.text = place.formattedAddress?.components(separatedBy: ", ")
                        .joined(separator: "\n")
                    self.strLocationType = self.currentLocationMarkerText
                    
                }
            }
        })
    }
    
    //MARK:- IBActions
    var cardData = [[String:AnyObject]]()
    
    @objc func newBooking(_ sender: UIButton) {
        
        let alert = UIAlertController(title: "New Booking", message: "This will clear old trip details on map for temporary now.", preferredStyle: .alert)
        let OK = UIAlertAction(title: "OK", style: .default, handler: { ACTION in
            self.clearSetupMapForNewBooking()
        })
        alert.addAction(OK)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func btnBookNow(_ sender: Any) {
        
        
        if Connectivity.isConnectedToInternet()
        {
            
            self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
            
            self.MarkerCurrntLocation.isHidden = true
            
            //            self.viewTripActions.isHidden = false
            //            self.ConstantViewCarListsHeight.constant = 0
            //            self.viewCarLists.isHidden = true
            //
            //            self.viewActivity.stopAnimating()
            //            self.viewMainActivityIndicator.isHidden = true
            //            self.btnRequest.isHidden = false
            //            self.btnCancelStartedTrip.isHidden = true
            
            
            if SingletonClass.sharedInstance.strPassengerID == "" || strModelId == "" || strPickupLocation == "" || strDropoffLocation == "" || doublePickupLat == 0 || doublePickupLng == 0 || doubleDropOffLat == 0 || doubleDropOffLng == 0 || strCarModelID == "0"
            {
                if txtCurrentLocation.text!.count == 0 {
                    
                    UtilityClass.setCustomAlert(title: appName, message: "Please enter your pickup location again") { (index, title) in
                    }
                }
                else if txtDestinationLocation.text!.count == 0 {
                    
                    UtilityClass.setCustomAlert(title: appName, message: "Please enter your destination again") { (index, title) in
                    }
                }
                else if strModelId == "" {
                    
                    //                    UtilityClass.setCustomAlert(title: appName, message: "There are no cars available. Do you want to pay extra chareges?") { (index, title) in
                    //                    }
                    
                    // "There are no vehicles available within 2 kms and do u want to pay additional \(currencySign) \(strSpecialRequestFareCharge) and make a booking?"
                    
                    let alert = UIAlertController(title: appName, message: "Vehicle is not available", preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default, handler: { ACTION in
                        //                        self.strSpecialRequest = "1"
                        //                        self.bookingRequest()
                        //                        self.webserviceCallForMissBookingRequest()
                    })
                    //                    let Cancel = UIAlertAction(title: "No", style: .destructive, handler: { ACTION in
                    //                        self.webserviceCallForMissBookingRequest()
                    //                    })
                    
                    
                    alert.addAction(OK)
                    //                    alert.addAction(Cancel)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else {
                    
                    UtilityClass.setCustomAlert(title: appName, message: "Vehicle is not available") { (index, title) in
                    }
                }
                
            }
            else {
                strSpecialRequest = "0"
                //                bookingRequest()
                
                if (SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0) && self.aryCardsListForBookNow.count == 2 {
                    //                UtilityClass.showAlert("", message: "There is no card, If you want to add card than choose payment options to add card.", vc: self)
                    
                    let alert = UIAlertController(title: nil, message: "Do you want to add card.", preferredStyle: .alert)
                    let OK = UIAlertAction(title: "OK", style: .default, handler: { ACTION in
                        
                        let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
                        
                        next.delegateAddCardFromHomeVC = self
                        next.modalPresentationStyle = .fullScreen
                        self.navigationController?.present(next, animated: true, completion: nil)
                        
                    })
                    let Cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { ACTION in
                        self.paymentOptions()
                    })
                    alert.addAction(OK)
                    alert.addAction(Cancel)
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else {
                    self.paymentOptions()
                }
            }
            
        }
        else {
            UtilityClass.showAlert("", message: "Internet connection not available", vc: self)
        }
    }
    
    
    func bookingRequest()
    {
        
        if (SingletonClass.sharedInstance.CardsVCHaveAryData.count == 0) && self.aryCardsListForBookNow.count == 2 {
            //                UtilityClass.showAlert("", message: "There is no card, If you want to add card than choose payment options to add card.", vc: self)
            
            let alert = UIAlertController(title: nil, message: "Do you want to add card.", preferredStyle: .alert)
            let OK = UIAlertAction(title: "OK", style: .default, handler: { ACTION in
                
                let next = self.storyboard?.instantiateViewController(withIdentifier: "WalletAddCardsViewController") as! WalletAddCardsViewController
                
                next.delegateAddCardFromHomeVC = self
                next.modalPresentationStyle = .fullScreen
                
                self.navigationController?.present(next, animated: true, completion: nil)
                
            })
            let Cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: { ACTION in
                self.paymentOptions()
            })
            alert.addAction(OK)
            alert.addAction(Cancel)
            self.present(alert, animated: true, completion: nil)
            
        }
        else {
            self.paymentOptions()
        }
        
    }
    
    func paymentOptions() {
        
        cardData.removeAll()
        
        if SingletonClass.sharedInstance.CardsVCHaveAryData.count != 0 {
            
            cardData = SingletonClass.sharedInstance.CardsVCHaveAryData
            
            for i in 0..<aryCardsListForBookNow.count {
                cardData.append(aryCardsListForBookNow[i])
            }
            
            if self.aryCardsListForBookNow.count != 0 {
                cardData = self.aryCardsListForBookNow
            }
        }
        else {
            cardData.removeAll()
            
            for i in 0..<aryCardsListForBookNow.count {
                cardData.append(aryCardsListForBookNow[i])
            }
        }
        
        
        print(cardData)
        
        self.pickerView.reloadAllComponents()
        
        let data = cardData[0]
        
        imgPaymentType.image = UIImage(named: setCardIcon(str: data["Type"] as! String))
        txtSelectPaymentOption.text = data["CardNum2"] as? String
        
        let type = data["CardNum"] as! String
        
        if type  == "wallet" {
            paymentType = "wallet"
        }
        else if type == "cash" {
            paymentType = "cash"
        }
            
        else if type == "credit" {
            paymentType = "credit"
        }
        else {
            paymentType = "card"
        }
        if paymentType == "card" {
            CardID = data["Id"] as! String
        }
        
        viewBookNow.isHidden = false
    }
    
    func didAddCardFromHomeVC() {
        
        paymentOptions()
    }
    
    @IBAction func btnBookLater(_ sender: Any) {
        
        if Connectivity.isConnectedToInternet() {
            
            let profileData = SingletonClass.sharedInstance.dictProfile
            
            // This is For Book Later Address
            if (SingletonClass.sharedInstance.isFromNotificationBookLater) {
                
                if strCarModelID == "" {
                    
                    UtilityClass.setCustomAlert(title: appName, message: "Select Car") { (index, title) in
                    }
                }
                else {
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "BookLaterViewController") as! BookLaterViewController
                    
                    SingletonClass.sharedInstance.isFromNotificationBookLater = false
                    
                    next.strModelId = strCarModelID
                    next.strCarModelURL = strNavigateCarModel
                    next.strCarName = strCarModelClass
                    
                    next.strFullname = profileData.object(forKey: "Fullname") as! String
                    next.strMobileNumber = profileData.object(forKey: "MobileNo") as! String
                    
                    next.strPickupLocation = strPickupLocation
                    next.doublePickupLat = doublePickupLat
                    next.doublePickupLng = doublePickupLng
                    
                    next.strDropoffLocation = strDropoffLocation
                    next.doubleDropOffLat = doubleDropOffLat
                    next.doubleDropOffLng = doubleDropOffLng
                    
                    // For Flat Rate
                    next.strServiceType = strServiceType
                    if dictFlatRate != nil {
                        next.dictFlatRate = dictFlatRate
                    }
                    
                    next.arySelectedCarOptions = arySelectedCarOptions
                    next.intNoOfPassengersLimites = intNoOfPassengersLimites
                    next.valueTMCardHolde = valueTMCardHolde
                    next.valueBabySeater = valueBabySeater
                    next.valueHoistVan = valueHoistVan
                    next.intNumberOfPassenger = Int(lblNumberOfPassengers.text!)!
                    next.intNoOfBages = Int(lblNoOfBags.text!)!
                    
                    self.navigationController?.pushViewController(next, animated: true)
                }
            }
            else {
                
                if strCarModelID == "" {
                    
                    UtilityClass.setCustomAlert(title: appName, message: "Select Car") { (index, title) in
                    }
                }
                else {
                    let next = self.storyboard?.instantiateViewController(withIdentifier: "BookLaterViewController") as! BookLaterViewController
                    
                    next.strModelId = strCarModelID
                    next.strCarModelURL = strNavigateCarModel
                    next.strCarName = strCarModelClass
                    
                    next.strPickupLocation = strPickupLocation
                    next.doublePickupLat = doublePickupLat
                    next.doublePickupLng = doublePickupLng
                    
                    next.strDropoffLocation = strDropoffLocation
                    next.doubleDropOffLat = doubleDropOffLat
                    next.doubleDropOffLng = doubleDropOffLng
                    
                    next.strFullname = profileData.object(forKey: "Fullname") as! String
                    next.strMobileNumber = profileData.object(forKey: "MobileNo") as! String
                    
                    // For Flat Rate
                    next.strServiceType = strServiceType
                    if dictFlatRate != nil {
                        next.dictFlatRate = dictFlatRate
                    }
                    
                    next.arySelectedCarOptions = arySelectedCarOptions
                    next.intNoOfPassengersLimites = intNoOfPassengersLimites
                    next.valueTMCardHolde = valueTMCardHolde
                    next.valueBabySeater = valueBabySeater
                    next.valueHoistVan = valueHoistVan
                    next.intNumberOfPassenger = Int(lblNumberOfPassengers.text!)!
                    next.intNoOfBages = Int(lblNoOfBags.text!)!
                    
                    self.navigationController?.pushViewController(next, animated: true)
                    
                }
            }
        }
        else {
            UtilityClass.showAlert("", message: "Internet connection not available", vc: self)
        }
        
    }
    
    @IBAction func btnGetFareEstimate(_ sender: Any) {
        
        if txtCurrentLocation.text == "" || txtDestinationLocation.text == "" {
            
            
            UtilityClass.setCustomAlert(title: appName, message: "Please enter both address.") { (index, title) in
            }
        }
            
        else {
            
            self.postPickupAndDropLocationForEstimateFare()
        }
    }
    
    @IBOutlet weak var btnRequest: UIButton!
    @IBAction func btnRequest(_ sender: UIButton)
    {
        
        
        let alert = UIAlertController(title: appName, message: "Are you sure you want to cancel this trip?", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Yes", style: .default) { (ACTION) in
            
            if self.CancellationFee != "" {
                
                let alertCancellationFee = UIAlertController(title: appName, message: "If you cancel the trip you will be partially charged.", preferredStyle: .alert)
                
                let OkCancellationFee = UIAlertAction(title: "Yes", style: .default) { (ACTION) in
                    if self.strBookingType == "BookLater" {
                        self.CancelBookLaterTripAfterDriverAcceptRequest()
                    }
                    else {
                        self.socketMethodForCancelRequestTrip()
                    }
                    
                    self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                    self.clearMap()
                    
                    self.txtCurrentLocation.text = ""
                    self.txtDestinationLocation.text = ""
                    
                    self.clearDataAfteCompleteTrip()
                    
                    self.getPlaceFromLatLong()
                    self.timerToGetDriverLocation?.invalidate()
                    
                    //        UtilityClass.setCustomAlert(title: "\(appName)", message: "Request Canceled") { (index, title) in
                    //        }
                    
                    self.viewTripActions.isHidden = true
                    self.viewCarLists.isHidden = true
                    self.ConstantViewCarListsHeight.constant = 200 // 150
                    //        self.constraintTopSpaceViewDriverInfo.constant = 170
                    self.ConstantViewCarListsHeight.constant = 0
                }
                
                let CancelCancellationFee = UIAlertAction(title: "No", style: .default, handler: nil)
                
                alertCancellationFee.addAction(OkCancellationFee)
                alertCancellationFee.addAction(CancelCancellationFee)
                
                //                self.present(alertCancellationFee, animated: true, completion: nil)
                
                UtilityClass.presentAlertVC(selfVC: alertCancellationFee)
            }
            else {
                if self.strBookingType == "BookLater" {
                    self.CancelBookLaterTripAfterDriverAcceptRequest()
                }
                else {
                    self.socketMethodForCancelRequestTrip()
                }
                
                self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                self.clearMap()
                
                self.txtCurrentLocation.text = ""
                self.txtDestinationLocation.text = ""
                
                self.clearDataAfteCompleteTrip()
                
                self.getPlaceFromLatLong()
                self.timerToGetDriverLocation?.invalidate()
                
                //        UtilityClass.setCustomAlert(title: "\(appName)", message: "Request Canceled") { (index, title) in
                //        }
                
                self.viewTripActions.isHidden = true
                self.viewCarLists.isHidden = true
                self.ConstantViewCarListsHeight.constant = 200 // 150
                //        self.constraintTopSpaceViewDriverInfo.constant = 170
                self.ConstantViewCarListsHeight.constant = 0
            }
            
            
        }
        
        let cancel = UIAlertAction(title: "No", style: .default, handler: nil)
        
        alert.addAction(ok)
        alert.addAction(cancel)
        
        //        self.present(alert, animated: true, completion: nil)
        UtilityClass.presentAlertVC(selfVC: alert)
        
        
    }
    
    @IBOutlet weak var btnDriverInfo: UIButton!
    @IBAction func btnDriverInfo(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "segueBookingConfirmed", sender: self)
        
        
        //        let DriverInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSArray).object(at: 0) as! NSDictionary
        //        let carInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSArray).object(at: 0) as! NSDictionary
        //        let bookingInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
        //
        //        showDriverInfo(bookingInfo: bookingInfo, DriverInfo: DriverInfo, carInfo: carInfo)
        
        
    }
    
    @objc func callChatingMessage(notification: NSNotification) {
        
        if let dict = notification.object as? [String:Any] {
            
            let myJSON = ["BookingId": dict["BookingId"] ?? "", "Type": dict["Type"] ?? "", "Sender": "passenger", "Message": dict["Message"] ?? ""]
            socket.emit(SocketData.kSendMessage, with: [myJSON])
        }
    }
    
    @IBAction func swipDownDriverInfo(_ sender: UISwipeGestureRecognizer) {
        
        //        constraintTopSpaceViewDriverInfo.constant = 170
        
    }
    
    @IBAction func TapToDismissGesture(_ sender: UITapGestureRecognizer) {
        
        
        UIView.transition(with: viewForMainFavourite, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
            self.viewForMainFavourite.isHidden = true
        }) { _ in }
        
        
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        
        
        //        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnDismissFavouritesView(_ sender: UIButton) {
        
        UIView.transition(with: viewForMainFavourite, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
            self.viewForMainFavourite.isHidden = true
        }) { _ in }
        
        
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    // function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        print("Hello World")
        
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
    @IBAction func btnCancelStartedTrip(_ sender: UIButton) {
        
        
        UtilityClass.showAlert("", message: "Currently this feature is not available.", vc: self)
    }
    
    
    
    //-------------------------------------------------------------
    // MARK: - Favourite Delegate Methods
    //-------------------------------------------------------------
    
    func didEnterFavouriteDestination(Source: [String:AnyObject]) {
        
        txtDestinationLocation.text = Source["Address"] as? String
        strDropoffLocation = Source["Address"] as! String
        doubleDropOffLat = Double(Source["Lat"] as! String)!
        doubleDropOffLng = Double(Source["Lng"] as! String)!
    }
    
    //-------------------------------------------------------------
    // MARK: - Favourites Actions
    //-------------------------------------------------------------
    
    @IBAction func btnHome(_ sender: UIButton) {
        
        
        webserviceOfAddAddressToFavourite(type: "Home")
    }
    
    @IBAction func btnOffice(_ sender: UIButton) {
        
        webserviceOfAddAddressToFavourite(type: "Office")
    }
    
    @IBAction func btnAirport(_ sender: UIButton) {
        
        webserviceOfAddAddressToFavourite(type: "Airport")
    }
    
    @IBAction func btnOthers(_ sender: UIButton) {
        
        webserviceOfAddAddressToFavourite(type: "Others")
    }
    
    //-------------------------------------------------------------
    // MARK: - Car List 3 Items
    //-------------------------------------------------------------
    
    
    @IBOutlet weak var lblFairAndTimeForMaxVan: UILabel!
    @IBOutlet weak var lblFairAndTimeForWaihekeExpress: UILabel!
    @IBOutlet weak var lblFairAndTimeForBudgetTaxi: UILabel!
    
    @IBOutlet weak var lblMaxVanName: UILabel!
    @IBOutlet weak var lblWaihekeExpressName: UILabel!
    @IBOutlet weak var lblBudgetTaxiName: UILabel!
    
    @IBOutlet weak var imgMaxVan: UIImageView!
    @IBOutlet weak var imgWaihekeExpress: UIImageView!
    @IBOutlet weak var imgBudgetTaxi: UIImageView!
    
    
    
    func setCarDummy(index: Int = 1) {
        
        if carListModelDataList != nil {
            
            self.imgMaxVan.sd_setShowActivityIndicatorView(true)
            self.imgWaihekeExpress.sd_setShowActivityIndicatorView(true)
            self.imgBudgetTaxi.sd_setShowActivityIndicatorView(true)
            self.imgMaxVan.sd_setIndicatorStyle(.gray)
            self.imgWaihekeExpress.sd_setIndicatorStyle(.gray)
            self.imgBudgetTaxi.sd_setIndicatorStyle(.gray)
            
            
            DispatchQueue.main.async {
                
                self.lblMaxVanName.text = SingletonClass.sharedInstance.carList![0].name
                self.lblWaihekeExpressName.text = SingletonClass.sharedInstance.carList![1].name
                self.lblBudgetTaxiName.text = SingletonClass.sharedInstance.carList![index].name
                
                self.imgMaxVan.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![0].imageDeselect!), completed: nil)
                //.image = UIImage(named: carListModelDataList![0].imageDeselect!)
                self.imgWaihekeExpress.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![1].imageDeselect!), completed: nil)
                //.image = UIImage(named: carListModelDataList![1].imageDeselect!)
                self.imgBudgetTaxi.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![index].image!), completed: nil)
                //.image = UIImage(named: carListModelDataList![index].image!)
            }
            
        }
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Delegate Change Last Car Methods
    //-------------------------------------------------------------
    
    var selectedCarIndex = Int(1)
    
    func didChangedCar(index: Int) {
        selectedCarIndex = index
        setCarDummy(index: index)
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Car Selection Methods
    //-------------------------------------------------------------
    
    @IBOutlet var btnCarSelection: [UIButton]!
    
    @IBAction func btnCarSelection(_ sender: UIButton) {
        
        let currentRow = sender.tag
        arySelectedCarOptions.removeAll()
        valueTMCardHolde = 0
        valueBabySeater = 0
        valueHoistVan = 0
        intNumberOfPassenger = 01
        if sender.tag == 0 {
            intNoOfPassengersLimites = 4
        }
        else if sender.tag == 1 {
            intNoOfPassengersLimites = 12
        }
        
        lblNumberOfPassengers.text = "0\(intNumberOfPassenger)"
        
        updateCounting()
        
        selectedCarIndex = currentRow
        
        setCarSelection(carIndex: currentRow, collectionViewReload: true)
        
    }
    
    func setCarSelection(carIndex: Int, collectionViewReload: Bool) {
        
        
        MarkerCurrntLocation.isHidden = true
        
        if (arrNumberOfOnlineCars.count != 0 && carIndex < self.arrNumberOfOnlineCars.count)
        {
            var dictOnlineCarData = NSDictionary()
            
            if carIndex == 2 {
                dictOnlineCarData = (arrNumberOfOnlineCars as! [[String:Any]]).filter({$0["Name"] as! String == lblBudgetTaxiName.text}).first! as NSDictionary //(arrNumberOfOnlineCars.object(at: currentRow) as! NSDictionary)
            }
            else {
                dictOnlineCarData = (arrNumberOfOnlineCars.object(at: carIndex) as! NSDictionary)
            }
            
            strSpecialRequestFareCharge = dictOnlineCarData.object(forKey: "SpecialExtraCharge") as? String ?? ""
            if dictOnlineCarData.object(forKey: "carCount") as! Int != 0 {
                //                self.clearMap()
                //       print("dictOnlineCarData: \(dictOnlineCarData)")
                
                if dictFlatRate == nil {
                    
                    if self.aryEstimateFareData.count != 0 {
                        
                        if carIndex == 2 {
                            
                            let dictAprrox = (self.aryEstimateFareData as! [[String:Any]]).filter({$0["name"] as? String == lblBudgetTaxiName.text}).first!
                            
                            if let minute = dictAprrox["total"] as? Double {
                                lblApproxCost.text = "\(currencySign)\(minute)"
                                lblFairAndTimeForBudgetTaxi.text = "\(currencySign)\(minute)"
                            }
                            else {
                                lblApproxCost.text = "\(currencySign)00.00"
                            }
                        }
                        else {
                            
                            if ((self.aryEstimateFareData.object(at: carIndex) as! NSDictionary).object(forKey: "duration") as? NSNull) != nil {
                                
                                //                            if currentRow == 0 {
                                //                                lblFairAndTimeForMaxVan.text = "\(0.00)min"
                                //                            }
                                //                            else if currentRow == 1 {
                                //                                lblFairAndTimeForWaihekeExpress.text = "\(0.00)min"
                                //                            }
                                //                            else {
                                //                                lblFairAndTimeForBudgetTaxi.text = "\(0.00)min"
                                //                            }
                            }
                            else if let minute = (self.aryEstimateFareData.object(at: carIndex) as! NSDictionary).object(forKey: "duration") as? Double {
                                //                            cell.lblMinutes.text = "\(minute)min"
                                //                            if currentRow == 0 {
                                //                                lblFairAndTimeForMaxVan.text = "\(minute)min"
                                //                            }
                                //                            else if currentRow == 1 {
                                //                                lblFairAndTimeForWaihekeExpress.text = "\(minute)min"
                                //                            }
                                //                            else {
                                //                                lblFairAndTimeForBudgetTaxi.text = "\(minute)min"
                                //                            }
                            }
                            
                            if ((self.aryEstimateFareData.object(at: carIndex) as! NSDictionary).object(forKey: "total") as? NSNull) != nil {
                                
                                lblApproxCost.text = "\(currencySign)\(0)"
                            }
                            else if let price = (self.aryEstimateFareData.object(at: carIndex) as! NSDictionary).object(forKey: "total") as? Double {
                                
                                lblApproxCost.text = "\(currencySign)\(price)"
                                
                                if strServiceType == ServiceType.FlatRate.rawValue {
                                    
                                    strFareId = (self.aryEstimateFareData.object(at: carIndex) as! NSDictionary).object(forKey: "fare_id") as! String
                                    
                                    lblFairAndTimeForMaxVan.text = lblApproxCost.text
                                    
                                    lblFairAndTimeForWaihekeExpress.text = lblApproxCost.text
                                    
                                    lblFairAndTimeForBudgetTaxi.text = lblApproxCost.text
                                    
                                }
                                else {
                                    if carIndex == 0 {
                                        lblFairAndTimeForMaxVan.text = "\(currencySign)\(price)"
                                    }
                                    else if carIndex == 1 {
                                        lblFairAndTimeForWaihekeExpress.text = "\(currencySign)\(price)"
                                    }
                                    else {
                                        lblFairAndTimeForBudgetTaxi.text = "\(currencySign)\(price)"
                                    }
                                }
                            }
                        }
                    }
                }
                
                if selectedCarIndex == carIndex {
                    
                    self.markerOnlineCars.map = nil
                    
                    for i in 0..<self.aryMarkerOnlineCars.count {
                        
                        self.aryMarkerOnlineCars[i].map = nil
                    }
                    
                    self.aryMarkerOnlineCars.removeAll()
                    
                    let available = dictOnlineCarData.object(forKey: "carCount") as! Int
                    let checkAvailabla = String(available)
                    
                    
                    var lati = dictOnlineCarData.object(forKey: "Lat") as! Double
                    var longi = dictOnlineCarData.object(forKey: "Lng") as! Double
                    
                    let camera = GMSCameraPosition.camera(withLatitude: lati, longitude: longi, zoom: 17.5)
                    
                    self.mapView.camera = camera
                    
                    let locationsArray = (dictOnlineCarData.object(forKey: "locations") as! [[String:AnyObject]])
                    
                    for i in 0..<locationsArray.count
                    {
                        if( (locationsArray[i]["CarType"] as! String) == (dictOnlineCarData.object(forKey: "Id") as! String))
                        {
                            lati = (locationsArray[i]["Location"] as! [AnyObject])[0] as! Double
                            longi = (locationsArray[i]["Location"] as! [AnyObject])[1] as! Double
                            let position = CLLocationCoordinate2D(latitude: lati, longitude: longi)
                            self.markerOnlineCars = GMSMarker(position: position)
                            //                        self.markerOnlineCars.tracksViewChanges = false
                            //                        self.strSelectedCarMarkerIcon = self.markertIcon(index: indexPath.row)
                            self.strSelectedCarMarkerIcon = self.setCarImage(modelId: dictOnlineCarData.object(forKey: "Id") as! String)
                            //                        self.markerOnlineCars.icon = UIImage(named: self.markertIcon(index: indexPath.row)) // iconCurrentLocation
                            
                            self.aryMarkerOnlineCars.append(self.markerOnlineCars)
                            
                            //                        self.markerOnlineCars.map = nil
                            
                            //                    self.markerOnlineCars.map = self.mapView
                        }
                    }
                    
                    for i in 0..<self.aryMarkerOnlineCars.count {
                        
                        self.aryMarkerOnlineCars[i].position = self.aryMarkerOnlineCars[i].position
                        self.aryMarkerOnlineCars[i].icon = UIImage(named: self.setCarImage(modelId: dictOnlineCarData.object(forKey: "Id") as! String))
                        self.aryMarkerOnlineCars[i].map = self.mapView
                    }
                    
                    let carModelID = dictOnlineCarData.object(forKey: "Id") as? String
                    let carModelIDConverString: String = carModelID!
                    
                    let strCarName: String = dictOnlineCarData.object(forKey: "Name") as! String
                    
                    strCarModelClass = strCarName
                    strCarModelID = carModelIDConverString
                    
                    //                selectedIndexPath = indexPath
                    //
                    //                let cell = collectionView.cellForItem(at: indexPath) as! CarsCollectionViewCell
                    //                cell.viewOfImage.layer.borderColor = themeYellowColor.cgColor
                    
                    let imageURL = dictOnlineCarData.object(forKey: "Image") as! String
                    strNavigateCarModel = imageURL
                    strCarModelIDIfZero = ""
                    if checkAvailabla != "0" {
                        strModelId = dictOnlineCarData.object(forKey: "Id") as! String
                        
                        if aryEstimateFareData.count != 0 {
                            
                            strFareId = "\((self.aryEstimateFareData.object(at: carIndex) as! NSDictionary).object(forKey: "fare_id")!)"
                        }
                        
                    }
                    else {
                        strModelId = ""
                        strFareId = ""
                    }
                    
                    // check Flat Rate is Available or not
                    if dictFlatRate != nil {
                        self.lblApproxCost.text = "\(currencySign)\(dictFlatRate?["Price"] as? String ?? "00.00")"
                    }
                    
                }
                
            }
            else {
                
                lblApproxCost.text = "\(currencySign)00.00"
                
                
                for i in 0..<self.aryMarkerOnlineCars.count {
                    
                    self.aryMarkerOnlineCars[i].map = nil
                }
                
                self.aryMarkerOnlineCars.removeAll()
                
                let available = dictOnlineCarData.object(forKey: "carCount") as! Int
                let checkAvailabla = String(available)
                
                let carModelID = dictOnlineCarData.object(forKey: "Id") as? String
                let carModelIDConverString: String = carModelID!
                
                let strCarName: String = dictOnlineCarData.object(forKey: "Name") as! String
                
                strCarModelClass = strCarName
                
                //                let cell = collectionView.cellForItem(at: indexPath) as! CarsCollectionViewCell
                //                cell.viewOfImage.layer.borderColor = themeGrayColor.cgColor
                //
                //                selectedIndexPath = indexPath
                
                let imageURL = dictOnlineCarData.object(forKey: "Image") as! String
                
                strNavigateCarModel = imageURL
                //                strCarModelID = ""
                strCarModelIDIfZero = carModelIDConverString
                
                if checkAvailabla != "0" {
                    strModelId = dictOnlineCarData.object(forKey: "Id") as! String
                    strFareId = (self.aryEstimateFareData.object(at: carIndex) as! NSDictionary).object(forKey: "fare_id") as! String
                }
                else {
                    strModelId = ""
                    strCarModelIDIfZero = dictOnlineCarData.object(forKey: "Id") as! String
                    strCarModelID = dictOnlineCarData.object(forKey: "Id") as! String
                }
                
                // check Flat Rate is Available or not
                if dictFlatRate != nil {
                    self.lblApproxCost.text = "\(currencySign)\(dictFlatRate?["Price"] as? String ?? "00.00")"
                }
                
            }
            
            if collectionViewReload {
                
                collectionViewCars.reloadData()
            }
            
        }
        else {
            
            if SingletonClass.sharedInstance.carList != nil {
                if SingletonClass.sharedInstance.carList?.count != 0 {
                    if carIndex == 2 {
                        strCarModelID = SingletonClass.sharedInstance.carList!.filter({$0.name == lblBudgetTaxiName.text}).first!.id ?? ""
                    }
                    else {
                        strCarModelID = SingletonClass.sharedInstance.carList![carIndex].id ?? ""
                    }
                }
            }
            
            //            let PackageVC = self.storyboard?.instantiateViewController(withIdentifier: "PackageViewController")as! PackageViewController
            //            let navController = UINavigationController(rootViewController: PackageVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
            //
            //            PackageVC.strPickupLocation = strPickupLocation
            //            PackageVC.doublePickupLat = doublePickupLat
            //            PackageVC.doublePickupLng = doublePickupLng
            //
            //            self.present(navController, animated:true, completion: nil)
            
        }
        
        
        if collectionViewReload {
            if carListModelDataList != nil {
                
                self.imgMaxVan.sd_setShowActivityIndicatorView(true)
                self.imgWaihekeExpress.sd_setShowActivityIndicatorView(true)
                self.imgBudgetTaxi.sd_setShowActivityIndicatorView(true)
                self.imgMaxVan.sd_setIndicatorStyle(.gray)
                self.imgWaihekeExpress.sd_setIndicatorStyle(.gray)
                self.imgBudgetTaxi.sd_setIndicatorStyle(.gray)
                
                DispatchQueue.main.async {
                    
                    
                    if SingletonClass.sharedInstance.carList != nil {
                        if SingletonClass.sharedInstance.carList?.count != 0 {
                            if carIndex == 0 {
                                self.imgMaxVan.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![0].image!), completed: nil)
                                self.imgWaihekeExpress.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![1].imageDeselect!), completed: nil)
                                self.imgBudgetTaxi.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![self.selectedCarIndex].imageDeselect!), completed: nil)
                            } else if carIndex == 1 {
                                self.imgMaxVan.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![0].imageDeselect!), completed: nil)
                                self.imgWaihekeExpress.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![carIndex].image!), completed: nil)
                                self.imgBudgetTaxi.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![self.selectedCarIndex].imageDeselect!), completed: nil)
                            } else if carIndex == 2 {
                                self.imgMaxVan.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![0].imageDeselect!), completed: nil)
                                self.imgWaihekeExpress.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![1].imageDeselect!), completed: nil)
                                self.imgBudgetTaxi.sd_setImage(with: URL(string: SingletonClass.sharedInstance.carList![self.selectedCarIndex].image!), completed: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    //-------------------------------------------------------------
    // MARK: - Sound Implement Methods
    //-------------------------------------------------------------
    
    var audioPlayer:AVAudioPlayer!
    
    //    RequestConfirm.m4a
    //    ringTone.mp3
    
    
    func playSound(fileName: String, extensionType: String) {
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: extensionType) else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            audioPlayer.numberOfLoops = 1
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    func stopSound(fileName: String, extensionType: String) {
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: extensionType) else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category(rawValue: convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)))
            try AVAudioSession.sharedInstance().setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            audioPlayer.stop()
            audioPlayer = nil
        }
        catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    //MARK:- Collectionview Delegate and Datasource methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        //        return self.arrNumberOfOnlineCars.count + 1
        //
        //        {
        if self.arrNumberOfOnlineCars.count == 0 {
            return arrDemoCarList.count
        }
        //
        return self.arrNumberOfOnlineCars.count
        //        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CarsCollectionViewCell", for: indexPath as IndexPath) as! CarsCollectionViewCell
        
        cell.viewOfImage.layer.cornerRadius = cell.viewOfImage.frame.width / 2
        cell.viewOfImage.layer.borderWidth = 3.0
        if selectedIndexPath == indexPath {
            cell.viewOfImage.layer.borderColor = themeYellowColor.cgColor
            cell.viewOfImage.layer.masksToBounds = true
        }
        else {
            cell.viewOfImage.layer.borderColor = themeGrayColor.cgColor
            cell.viewOfImage.layer.masksToBounds = true
        }
        
        if (self.arrNumberOfOnlineCars.count != 0 && indexPath.row < self.arrNumberOfOnlineCars.count)
        {
            //            let dictOnlineCarData = (arrNumberOfOnlineCars.object(at: indexPath.row) as! [String : AnyObject])
            
            var dictOnlineCarData:[String:AnyObject] = [:]
            if (self.arrNumberOfOnlineCars.count > 0)
            {
                dictOnlineCarData = (arrNumberOfOnlineCars.object(at: indexPath.row) as! [String : AnyObject])
            }
            else {
                dictOnlineCarData = (arrDemoCarList[indexPath.row]  as [String : AnyObject])
            }
            
            
            let imageURL = dictOnlineCarData["Image"] as! String
            
            cell.imgCars.sd_setIndicatorStyle(.gray)
            cell.imgCars.sd_setShowActivityIndicatorView(true)
            
            
            if imageURL != "" {
                
                cell.imgCars.sd_setImage(with: URL(string: imageURL), completed: nil)
                
                //                cell.imgCars.sd_setImage(with: URL(string: imageURL), completed: { (image, error, cacheType, url) in
                //                    cell.imgCars.sd_setShowActivityIndicatorView(false)
                //                })
            }
            
            
            cell.lblMinutes.text = "00min"
            cell.lblPrices.text = "\(currencySign)0.00"
            
            if indexPath.row == 2 {
                lblFairAndTimeForBudgetTaxi.text = "No Taxi"
            } else if indexPath.row == 1 {
                lblFairAndTimeForWaihekeExpress.text = "No Taxi"
            } else if indexPath.row == 0 {
                lblFairAndTimeForMaxVan.text = "No Taxi"
            }
            
            
            
            if dictOnlineCarData["carCount"] as! Int != 0 {
                
                if self.aryEstimateFareData.count != 0 {
                    
                    if ((self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "duration") as? NSNull) != nil {
                        
                        cell.lblMinutes.text = "\(0.00)min"
                    }
                    else if let minute = (self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "duration") as? Double {
                        cell.lblMinutes.text = "\(minute)min"
                    }
                    
                    if ((self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "total") as? NSNull) != nil {
                        
                        cell.lblPrices.text = "\(currencySign)\(0)"
                    }
                    else if let price = (self.aryEstimateFareData.object(at: indexPath.row) as! NSDictionary).object(forKey: "total") as? Double {
                        
                        cell.lblPrices.text = "\(currencySign)\(price)"
                        
                    }
                }
                
                // TODO: Bhavesh uncomment this if neede
                if strServiceType == ServiceType.FlatRate.rawValue {
                    
                    if indexPath.row == 2 {
                        //                        lblFairAndTimeForBudgetTaxi.text = "\(cell.lblPrices.text ?? "\(currencySign)00")-\(cell.lblMinutes.text ?? "00min")"
                        lblFairAndTimeForBudgetTaxi.text = lblApproxCost.text
                    } else if indexPath.row == 1 {
                        //                        lblFairAndTimeForWaihekeExpress.text = "\(cell.lblPrices.text ?? "\(currencySign)00")-\(cell.lblMinutes.text ?? "00min")"
                        lblFairAndTimeForWaihekeExpress.text = lblApproxCost.text
                    } else if indexPath.row == 0 {
                        //                        lblFairAndTimeForMaxVan.text = "\(cell.lblPrices.text ?? "\(currencySign)00")-\(cell.lblMinutes.text ?? "00min")"
                        lblFairAndTimeForMaxVan.text = lblApproxCost.text
                    }
                    
                    //                    lblFairAndTimeForMaxVan.text = lblApproxCost.text
                    //                    lblFairAndTimeForWaihekeExpress.text = lblApproxCost.text
                    //                    lblFairAndTimeForBudgetTaxi.text = lblApproxCost.text
                    
                }
                else {
                    
                    if indexPath.row == 2 {
                        lblFairAndTimeForBudgetTaxi.text = "\(cell.lblPrices.text ?? "\(currencySign)00")-\(cell.lblMinutes.text ?? "00min")"
                    } else if indexPath.row == 1 {
                        lblFairAndTimeForWaihekeExpress.text = "\(cell.lblPrices.text ?? "\(currencySign)00")-\(cell.lblMinutes.text ?? "00min")"
                    } else if indexPath.row == 0 {
                        lblFairAndTimeForMaxVan.text = "\(cell.lblPrices.text ?? "\(currencySign)00")-\(cell.lblMinutes.text ?? "00min")"
                    }
                }
                setCarSelection(carIndex: indexPath.row, collectionViewReload: false)
            }
            else {
                if indexPath.row == 2 {
                    lblFairAndTimeForBudgetTaxi.text = "No Taxi"
                } else if indexPath.row == 1 {
                    lblFairAndTimeForWaihekeExpress.text = "No Taxi"
                } else if indexPath.row == 0 {
                    lblFairAndTimeForMaxVan.text = "No Taxi"
                }
            }
            
        }
        else
        {
            cell.imgCars.image = UIImage(named: "iconPackage")
            cell.lblMinutes.text = "Packages"
            cell.lblPrices.text = ""
            
        }
        
        //        setCarSelection(carIndex: indexPath.row, collectionViewReload: false)
        
        return cell
        
        // Maybe for future testing ///////
        
        
    }
    
    var markerOnlineCars = GMSMarker()
    var aryMarkerOnlineCars = [GMSMarker]()
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        MarkerCurrntLocation.isHidden = true
        
        
        
        if self.arrNumberOfOnlineCars.count > 0  {
            
            
            if (arrNumberOfOnlineCars.count != 0 && indexPath.row < self.arrNumberOfOnlineCars.count)
            {
                
                let dictOnlineCarData = (arrNumberOfOnlineCars.object(at: indexPath.row) as! NSDictionary)
                strSpecialRequestFareCharge = dictOnlineCarData.object(forKey: "SpecialExtraCharge") as? String ?? ""
                if dictOnlineCarData.object(forKey: "carCount") as! Int != 0 {
                    //                self.clearMap()
                    //       print("dictOnlineCarData: \(dictOnlineCarData)")
                    
                    self.markerOnlineCars.map = nil
                    
                    for i in 0..<self.aryMarkerOnlineCars.count {
                        
                        self.aryMarkerOnlineCars[i].map = nil
                    }
                    
                    self.aryMarkerOnlineCars.removeAll()
                    
                    let available = dictOnlineCarData.object(forKey: "carCount") as! Int
                    let checkAvailabla = String(available)
                    
                    
                    var lati = dictOnlineCarData.object(forKey: "Lat") as! Double
                    var longi = dictOnlineCarData.object(forKey: "Lng") as! Double
                    
                    let camera = GMSCameraPosition.camera(withLatitude: lati,
                                                          longitude: longi,
                                                          zoom: 17.5)
                    
                    self.mapView.camera = camera
                    
                    let locationsArray = (dictOnlineCarData.object(forKey: "locations") as! [[String:AnyObject]])
                    
                    for i in 0..<locationsArray.count
                    {
                        if( (locationsArray[i]["CarType"] as! String) == (dictOnlineCarData.object(forKey: "Id") as! String))
                        {
                            lati = (locationsArray[i]["Location"] as! [AnyObject])[0] as! Double
                            longi = (locationsArray[i]["Location"] as! [AnyObject])[1] as! Double
                            let position = CLLocationCoordinate2D(latitude: lati, longitude: longi)
                            self.markerOnlineCars = GMSMarker(position: position)
                            //                        self.markerOnlineCars.tracksViewChanges = false
                            //                        self.strSelectedCarMarkerIcon = self.markertIcon(index: indexPath.row)
                            self.strSelectedCarMarkerIcon = self.setCarImage(modelId: dictOnlineCarData.object(forKey: "Id") as! String)
                            //                        self.markerOnlineCars.icon = UIImage(named: self.markertIcon(index: indexPath.row)) // iconCurrentLocation
                            
                            self.aryMarkerOnlineCars.append(self.markerOnlineCars)
                            
                            //                        self.markerOnlineCars.map = nil
                            
                            //                    self.markerOnlineCars.map = self.mapView
                        }
                    }
                    
                    for i in 0..<self.aryMarkerOnlineCars.count {
                        
                        self.aryMarkerOnlineCars[i].position = self.aryMarkerOnlineCars[i].position
                        self.aryMarkerOnlineCars[i].icon = UIImage(named: self.setCarImage(modelId: dictOnlineCarData.object(forKey: "Id") as! String))
                        self.aryMarkerOnlineCars[i].map = self.mapView
                    }
                    
                    let carModelID = dictOnlineCarData.object(forKey: "Id") as? String
                    let carModelIDConverString: String = carModelID!
                    
                    let strCarName: String = dictOnlineCarData.object(forKey: "Name") as! String
                    
                    strCarModelClass = strCarName
                    strCarModelID = carModelIDConverString
                    
                    selectedIndexPath = indexPath
                    
                    let cell = collectionView.cellForItem(at: indexPath) as! CarsCollectionViewCell
                    cell.viewOfImage.layer.borderColor = themeYellowColor.cgColor
                    
                    let imageURL = dictOnlineCarData.object(forKey: "Image") as! String
                    strNavigateCarModel = imageURL
                    strCarModelIDIfZero = ""
                    if checkAvailabla != "0" {
                        strModelId = dictOnlineCarData.object(forKey: "Id") as! String
                    }
                    else {
                        strModelId = ""
                    }
                }
                else {
                    
                    for i in 0..<self.aryMarkerOnlineCars.count {
                        
                        self.aryMarkerOnlineCars[i].map = nil
                    }
                    
                    self.aryMarkerOnlineCars.removeAll()
                    
                    
                    let carModelID = dictOnlineCarData.object(forKey: "Id") as? String
                    let carModelIDConverString: String = carModelID!
                    
                    let strCarName: String = dictOnlineCarData.object(forKey: "Name") as! String
                    
                    strCarModelClass = strCarName
                    
                    let cell = collectionView.cellForItem(at: indexPath) as! CarsCollectionViewCell
                    cell.viewOfImage.layer.borderColor = themeGrayColor.cgColor
                    
                    
                    
                    selectedIndexPath = indexPath
                    
                    let imageURL = dictOnlineCarData.object(forKey: "Image") as! String
                    
                    strNavigateCarModel = imageURL
                    strCarModelID = ""
                    strCarModelIDIfZero = carModelIDConverString
                    
                }
                collectionViewCars.reloadData()
            }
            else
            {
                
                //            let PackageVC = self.storyboard?.instantiateViewController(withIdentifier: "PackageViewController")as! PackageViewController
                //            let navController = UINavigationController(rootViewController: PackageVC) // Creating a navigation controller with VC1 at the root of the navigation stack.
                //
                //            PackageVC.strPickupLocation = strPickupLocation
                //            PackageVC.doublePickupLat = doublePickupLat
                //            PackageVC.doublePickupLng = doublePickupLng
                //
                //            self.present(navController, animated:true, completion: nil)
                
            }
            
        }
        else {
            let dictOnlineCarData = self.arrDemoCarList[indexPath.row]
            let carModelID = dictOnlineCarData["Id"] as? String
            let carModelIDConverString: String = carModelID!
            let strCarName: String = dictOnlineCarData["Name"] as! String
            
            strCarModelClass = strCarName
            strCarModelID = carModelIDConverString
            
            let cell = collectionView.cellForItem(at: indexPath) as! CarsCollectionViewCell
            cell.viewOfImage.layer.borderColor = themeGrayColor.cgColor
            
            selectedIndexPath = indexPath
            
            let imageURL = dictOnlineCarData["Image"] as! String
            strNavigateCarModel = imageURL
            strCarModelIDIfZero = carModelIDConverString
            
            selectedIndexPath = indexPath
            collectionViewCars.reloadData()
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! CarsCollectionViewCell
        cell.viewOfImage.layer.borderColor = themeGrayColor.cgColor
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: self.view.frame.size.width/6, height: self.collectionViewCars.frame.size.height)
    }
    
    var carLocationsLat = Double()
    var carLocationsLng = Double()
    //MARK - Set car icons
    func setData()
    {
        var k = 0 as Int
        self.arrNumberOfOnlineCars.removeAllObjects()
        
        aryTempOnlineCars = NSMutableArray()
        
        for j in 0..<self.arrTotalNumberOfCars.count
        {
            //            if (j <= 5)
            //            {
            
            if ((self.arrTotalNumberOfCars[j] as! [String:AnyObject])["Status"] as! String) == "1" {
                
                k = 0
                let tempAryLocationOfDriver = NSMutableArray()
                
                let totalCarsAvailableCarTypeID = (self.arrTotalNumberOfCars.object(at: j) as! NSDictionary).object(forKey: "Id") as! String
                for i in 0..<self.arrNumberOfAvailableCars.count
                {
                    let dictLocation = NSMutableDictionary()
                    
                    let carType = (self.arrNumberOfAvailableCars.object(at: i) as! NSDictionary).object(forKey: "CarType") as! String
                    
                    if (totalCarsAvailableCarTypeID == carType)
                    {
                        k = k+1
                    }
                    
                    carLocationsLat = ((self.arrNumberOfAvailableCars.object(at: i) as! NSDictionary).object(forKey: "Location") as! NSArray).object(at: 0) as! Double
                    carLocationsLng = ((self.arrNumberOfAvailableCars.object(at: i) as! NSDictionary).object(forKey: "Location") as! NSArray).object(at: 1) as! Double
                    dictLocation.setDictionary(((self.arrNumberOfAvailableCars.object(at: i) as! NSDictionary) as! [AnyHashable : Any]))
                    tempAryLocationOfDriver.add(dictLocation)
                    //                    carLocations = (self.arrNumberOfAvailableCars.object(at: j) as! NSDictionary)
                    
                }
                //                print("The number of cars available is \(String(describing: (self.arrTotalNumberOfCars.object(at: j) as! NSDictionary).object(forKey: "Name")!)) and the count is \(k)")
                
                
                //            dictCars.setObject((self.arrTotalNumberOfCars.object(at: j) as! NSDictionary).object(forKey: "Sort")!, forKey: "SordId" as NSCopying)
                //            dictCars.setObject((self.arrTotalNumberOfCars.object(at: j) as! NSDictionary).object(forKey: "Name")!, forKey: "carName" as NSCopying)
                //            dictCars.setObject(k, forKey: "carCount" as NSCopying)
                //            dictCars.setObject((self.arrTotalNumberOfCars.object(at: j) as! NSDictionary).object(forKey: "Id")!, forKey: "Id" as NSCopying)
                //            dictCars.setObject(tempAryLocationOfDriver, forKey: "locations" as NSCopying)
                
                let tempDict =  NSMutableDictionary(dictionary: (self.arrTotalNumberOfCars.object(at: j) as! NSDictionary))
                tempDict.setObject(k, forKey: "carCount" as NSCopying)
                tempDict.setObject(carLocationsLat, forKey: "Lat" as NSCopying)
                tempDict.setObject(carLocationsLng, forKey: "Lng" as NSCopying)
                tempDict.setObject(tempAryLocationOfDriver, forKey: "locations" as NSCopying)
                
                
                aryTempOnlineCars.add(tempDict)
            }
            
            //            }
        }
        
        SortIdOfCarsType()
        
    }
    
    var aryTempOnlineCars = NSMutableArray()
    var checkTempData = NSArray()
    
    var aryOfOnlineCarsIds = [String]()
    var aryOfTempOnlineCarsIds = [String]()
    
    func SortIdOfCarsType() {
        
        
        //        DispatchQueue.main.async {
        
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            
            let sortedArray = (self.aryTempOnlineCars as NSArray).sortedArray(using: [NSSortDescriptor(key: "Sort", ascending: true)]) as! [[String:AnyObject]]
            
            self.arrNumberOfOnlineCars = NSMutableArray(array: sortedArray)
            
            //        print(arrNumberOfOnlineCars)
            
            
            if self.checkTempData.count == 0 {
                
                SingletonClass.sharedInstance.isFirstTimeReloadCarList = true
                self.checkTempData = self.aryTempOnlineCars as NSArray
                
                self.collectionViewCars.reloadData()
            }
            else {
                
                for i in 0..<self.aryTempOnlineCars.count {
                    
                    let arySwif = self.aryTempOnlineCars.object(at: i) as! NSDictionary
                    
                    if (self.checkTempData.object(at: i) as! NSDictionary) == arySwif {
                        
                        //                    self.aryOfOnlineCarsIds.append(String((checkTempData.object(at: i) as! NSDictionary).object(forKey: "carCount") as! Int))
                        if SingletonClass.sharedInstance.isFirstTimeReloadCarList == true {
                            SingletonClass.sharedInstance.isFirstTimeReloadCarList = false
                            
                            if self.txtCurrentLocation.text!.count != 0 && self.txtDestinationLocation.text!.count != 0 && self.aryOfOnlineCarsIds.count != 0 {
                                self.postPickupAndDropLocationForEstimateFare()
                            }
                            self.collectionViewCars.reloadData()
                            
                        }
                    }
                    else {
                        
                        if (self.checkTempData.object(at: i) as! NSDictionary).object(forKey: "carCount") as? Int != arySwif.object(forKey: "carCount") as? Int {
                            self.checkTempData = self.aryTempOnlineCars as NSArray
                            
                            if self.txtCurrentLocation.text!.count != 0 && self.txtDestinationLocation.text!.count != 0 && self.aryOfOnlineCarsIds.count != 0 {
                                
                                self.postPickupAndDropLocationForEstimateFare()
                            }
                            self.collectionViewCars.reloadData()
                        }
                    }
                }
            }
        })
        
    }
    
    //    func markertIcon(index: Int) -> String {
    //
    //        switch index {
    //        case 0: // "1":
    //            return "imgTaxi"
    //        case 1: // "2":
    //            return "imgTaxi"
    //        case 2: // "3":
    //            return "imgTaxi"
    //        case 3: // "4":
    //            return "imgTaxi"
    //        case 4: // "5":
    //            return "imgTaxi"
    //        case 5: // "6":
    //            return "imgTaxi"
    //        case 6: // "7":
    //            return "imgTaxi"
    //            //        case "8":
    //            //            return "imgTaxi"
    //            //        case "9":
    //            //            return "imgTaxi"
    //            //        case "10":
    //            //            return "imgTaxi"
    //            //        case "11":
    //        //            return "imgTaxi"
    //        default:
    //            return "imgTaxi"
    //        }
    
    func setCarImage(modelId : String) -> String {
        
        var CarModel = String()
        
        switch modelId {
        case "1":
            CarModel = "imgBusinessClass"
            return CarModel
        case "2":
            CarModel = "imgMIni"
            return CarModel
        case "3":
            CarModel = "imgVan"
            return CarModel
        case "4":
            CarModel = "imgNano"
            return CarModel
        case "5":
            CarModel = "imgTukTuk"
            return CarModel
        case "6":
            CarModel = "imgBreakdown"
            return CarModel
        default:
            CarModel = "imgBus"
            return CarModel
        }
    }
    
    /*/
     switch index {
     case 0: // "1":
     return "iconNano"
     case 1: // "2":
     return "iconPremium"
     case 2: // "3":
     return "iconBreakdownServices"
     case 3: // "4":
     return "iconVan"
     case 4: // "5":
     return "iconTukTuk"
     case 5: // "6":
     return "iconMiniCar"
     case 6: // "7":
     return "iconBusRed"
     //        case "8":
     //            return "Motorbike"
     //        case "9":
     //            return "Car Delivery"
     //        case "10":
     //            return "Van / Trays"
     //        case "11":
     //            return "3T truck"
     default:
     return "imgTaxi"
     }
     */
    
    //        switch index {
    //        case 0:
    //            return "imgFirstClass"
    //        case 1:
    //            return "imgBusinessClass"
    //        case 2:
    //            return "imgEconomy"
    //        case 3:
    //            return "imgTaxi"
    //        case 4:
    //            return "imgLUXVAN"
    //        case 5:
    //            return "imgDisability"
    //        default:
    //            return ""
    //        }
    
    
    //    func uniq<S : Sequence, T : Hashable>(source: S) -> [T] where S.Iterator.Element == T {
    //        var buffer = [T]()
    //        var added = Set<T>()
    //        for elem in source {
    //            if !added.contains(elem) {
    //                buffer.append(elem)
    //                added.insert(elem)
    //            }
    //        }
    //        return buffer
    //    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "seguePresentTripDetails") {
            
            let drinkViewController = segue.destination as! TripDetailsViewController
            drinkViewController.arrData = arrDataAfterCompletetionOfTrip as NSMutableArray
            drinkViewController.delegate = self
            
            //            setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
            //            self.btnCorrentLocationClickedAction()
            //            clearDestinationLocation()
            
            setViewDidLoad()
            
            btnDoneForLocationSelected.isHidden = false
            
            showBtnLocationDetailsToggle()
            
            self.setClearTextFieldsOfExtra()
            
        }
        
        if(segue.identifier == "segueDriverInfo") {
            
            //            let deiverInfo = segue.destination as! DriverInfoViewController
        }
        if(segue.identifier == "showRating") {
            
            let GiveRatingVC = segue.destination as! GiveRatingViewController
            GiveRatingVC.strBookingType = self.strBookingType
            //            GiveRatingVC.delegate = self
        }
        
        if (segue.identifier == "segueBookingConfirmed") {
            let bookingInfo = segue.destination as! CustomAlertsViewController
            bookingInfo.aryOfBookinDetails = self.aryRequestAcceptedData as! [[String : AnyObject]]//self.aryBookingAcceptedData
        }
        
        if (segue.identifier == "segueShowMoreOptions") {
            let bookingInfo = segue.destination as! MoreOptionsViewController
            bookingInfo.delegate = self
            bookingInfo.arySelectedCarModelData = arySelectedCarOptions
        }
        
    }
    
    
    func BookingConfirmed(dictData : NSDictionary)
    {
        
        //        let DriverInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSArray).object(at: 0) as! NSDictionary
        //        let carInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSArray).object(at: 0) as! NSDictionary
        //        let bookingInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
        //
        
        //        showDriverInfo(bookingInfo: bookingInfo, DriverInfo: DriverInfo, carInfo: carInfo)
        
    }
    
    //    //MARK: - Socket Methods
    
    var timesOfAccept = Int()
    @objc func bookingAcceptNotificationMethodCallInTimer() {
        timesOfAccept += 1
        print("ACCCEPT by Timer: \(timesOfAccept)")
        
        self.socketMethodForGettingBookingAcceptNotification()
    }
    
    //    func scheduledTimerWithTimeInterval(){
    //        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
    //        timer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    //
    //    }
    
    
    @objc func updateCounting(){
        let myJSON = ["PassengerId" : SingletonClass.sharedInstance.strPassengerID, "Lat": doublePickupLat, "Long": doublePickupLng, "Token" : SingletonClass.sharedInstance.deviceToken, "TMCardHolder": valueTMCardHolde, "BabySeater": valueBabySeater, "HoistVan": valueHoistVan, "NoOfPassenger": Int(lblNumberOfPassengers.text!) ?? 1] as [String : Any]
        socket.emit(SocketData.kUpdatePassengerLatLong , with: [myJSON])
        
    }
    
    
    func DriverInfoAndSetToMap(driverData: NSArray) {
        
        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: true)
        
        //        SingletonClass.sharedInstance.isTripContinue = true
        
        self.MarkerCurrntLocation.isHidden = true
        self.btnDoneForLocationSelected.isHidden = true
        
        self.viewTripActions.isHidden = false
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        
        self.viewActivity.stopAnimating()
        self.viewMainActivityIndicator.isHidden = true
        self.btnRequest.isHidden = false
        self.btnCancelStartedTrip.isHidden = true
        
        self.aryRequestAcceptedData = NSArray(array: driverData)
        
        //        let DriverInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSArray).object(at: 0) as! NSDictionary
        ////        let Details = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "Details") as! NSArray).object(at: 0) as! NSDictionary
        //        let carInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSArray).object(at: 0) as! NSDictionary
        //        let bookingInfo = ((self.aryRequestAcceptedData.object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
        
        let bookingInfo : NSDictionary!
        let DriverInfo: NSDictionary!
        let carInfo: NSDictionary!
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            DriverInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSArray).object(at: 0) as! NSDictionary
        }
        else {
            // print ("Yes its dictionary")
            DriverInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSDictionary)
        }
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            bookingInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
        }
        else
        {
            // print ("Yes its dictionary")
            bookingInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            carInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as? NSDictionary)?.object(forKey: "CarInfo") as? NSArray)?.object(at: 0) as? NSDictionary
        }
        else
        {
            // print ("Yes its dictionary")
            carInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        if let passengerType = bookingInfo.object(forKey: "PassengerType") as? String {
            
            if passengerType == "other" || passengerType == "others" {
                
                SingletonClass.sharedInstance.passengerTypeOther = true
            }
        }
        
        SingletonClass.sharedInstance.dictDriverProfile = DriverInfo
        SingletonClass.sharedInstance.dictCarInfo = (carInfo as? [String: AnyObject])!
        //        showDriverInfo(bookingInfo: bookingInfo, DriverInfo: DriverInfo, carInfo: carInfo)
        
        
        self.sendPassengerIDAndDriverIDToGetLocation(driverID: String(describing: DriverInfo.object(forKey: "Id")!) , passengerID: String(describing: bookingInfo.object(forKey: "PassengerId")!))
        
        
        self.BookingConfirmed(dictData: (driverData[0] as! NSDictionary) )
        
        let driverInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
        //        let details = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "Details") as! NSArray).object(at: 0) as! NSDictionary
        
        if let bookID =  bookingInfo.object(forKey: SocketDataKeys.kBookingIdNow) as? String {
            SingletonClass.sharedInstance.bookingId = bookID
        }
        else if let bookID = bookingInfo.object(forKey: "Id") as? String {
            SingletonClass.sharedInstance.bookingId = bookID
        }
        else if let bookID = bookingInfo.object(forKey: "Id") as? Int {
            SingletonClass.sharedInstance.bookingId = "\(bookID)"
        }
        
        txtCurrentLocation.text = bookingInfo.object(forKey: "PickupLocation") as? String
        txtDestinationLocation.text = bookingInfo.object(forKey: "DropoffLocation") as? String
        
        
        //        let PickupLat = defaultLocation.coordinate.latitude
        //        let PickupLng =  defaultLocation.coordinate.longitude
        
        let PickupLat = bookingInfo.object(forKey: "PickupLat") as! String
        let PickupLng =  bookingInfo.object(forKey: "PickupLng") as! String
        
        //        let DropOffLat = driverInfo.object(forKey: "PickupLat") as! String
        //        let DropOffLon = driverInfo.object(forKey: "PickupLng") as! String
        
        let DropOffLat = DriverInfo.object(forKey: "Lat") as! String
        let DropOffLon = DriverInfo.object(forKey: "Lng") as! String
        
        
        let dummyLatitude = Double(PickupLat)! - Double(DropOffLat)!
        let dummyLongitude = Double(PickupLng)! - Double(DropOffLon)!
        
        let waypointLatitude = Double(PickupLat)! - dummyLatitude
        let waypointSetLongitude = Double(PickupLng)! - dummyLongitude
        
        let originalLoc: String = "\(PickupLat),\(PickupLng)"
        let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
        
        
        let camera = GMSCameraPosition.camera(withLatitude: Double(DropOffLat)!,
                                              longitude: Double(DropOffLon)!,
                                              zoom: 18)
        
        mapView.camera = camera
        
        self.getDirectionsAcceptRequest(origin: originalLoc, destination: destiantionLoc) { (index, title) in
        }
        
        NotificationCenter.default.post(name: NotificationForAddNewBooingOnSideMenu, object: nil)
        
    }
    
    func methodAfterStartTrip(tripData: NSArray) {
        
        self.MarkerCurrntLocation.isHidden = true
        
        SingletonClass.sharedInstance.isTripContinue = true
        
        destinationCordinate = CLLocationCoordinate2D(latitude: dropoffLat, longitude: dropoffLng)
        
        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: true)
        
        self.viewTripActions.isHidden = false
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        
        self.viewActivity.stopAnimating()
        self.viewMainActivityIndicator.isHidden = true
        self.btnRequest.isHidden = true
        self.btnCancelStartedTrip.isHidden = true
        
        self.btnDoneForLocationSelected.isHidden = true
        self.MarkerCurrntLocation.isHidden = true
        
        let bookingInfo : NSDictionary!
        let DriverInfo: NSDictionary!
        let carInfo: NSDictionary!
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            DriverInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSArray).object(at: 0) as! NSDictionary
        }
        else {
            // print ("Yes its dictionary")
            DriverInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "DriverInfo") as! NSDictionary)
        }
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            bookingInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
        }
        else
        {
            // print ("Yes its dictionary")
            bookingInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "BookingInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        if((((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as? NSDictionary) == nil)
        {
            // print ("Yes its  array ")
            carInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSArray).object(at: 0) as! NSDictionary
        }
        else
        {
            // print ("Yes its dictionary")
            carInfo = (((self.aryRequestAcceptedData as NSArray).object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSDictionary) //.object(at: 0) as! NSDictionary
        }
        
        SingletonClass.sharedInstance.dictDriverProfile = DriverInfo
        SingletonClass.sharedInstance.dictCarInfo = carInfo as! [String: AnyObject]
        //        showDriverInfo(bookingInfo: bookingInfo, DriverInfo: DriverInfo, carInfo: carInfo)
        
        // ------------------------------------------------------------
        let DropOffLat = bookingInfo.object(forKey: "DropOffLat") as! String
        let DropOffLon = bookingInfo.object(forKey: "DropOffLon") as! String
        
        let picklat = bookingInfo.object(forKey: "PickupLat") as! String
        let picklng = bookingInfo.object(forKey: "PickupLng") as! String
        
        dropoffLat = Double(DropOffLat)!
        dropoffLng = Double(DropOffLon)!
        
        self.txtDestinationLocation.text = bookingInfo.object(forKey: "DropoffLocation") as? String
        self.txtCurrentLocation.text = bookingInfo.object(forKey: "PickupLocation") as? String
        
        let PickupLat = self.defaultLocation.coordinate.latitude
        let PickupLng = self.defaultLocation.coordinate.longitude
        
        //        let PickupLat = Double(picklat)
        //        let PickupLng = Double(picklng)
        
        
        let dummyLatitude = Double(PickupLat) - Double(DropOffLat)!
        let dummyLongitude = Double(PickupLng) - Double(DropOffLon)!
        
        let waypointLatitude = self.defaultLocation.coordinate.latitude - dummyLatitude
        let waypointSetLongitude = self.defaultLocation.coordinate.longitude - dummyLongitude
        
        
        let originalLoc: String = "\(PickupLat),\(PickupLng)"
        let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
        
        let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: Double(picklat)!, longitude: Double(picklng)!), coordinate: CLLocationCoordinate2D(latitude: Double(DropOffLat)!, longitude: Double(DropOffLon)!))
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(100))
        
        self.mapView.animate(with: update)
        
        self.mapView.moveCamera(update)
        
        //        self.getDirectionsAcceptRequest(origin: originalLoc, destination: destiantionLoc, waypoints: ["\(waypointLatitude),\(waypointSetLongitude)"], travelMode: nil, completionHandler: nil)
        
        self.getDirectionsSeconMethod(origin: originalLoc, destination: destiantionLoc, completionHandler: nil)
        
        NotificationCenter.default.post(name: NotificationForAddNewBooingOnSideMenu, object: nil)
        
    }
    
    //MARK:- Show Driver Information
    
    func showDriverInfo(bookingInfo : NSDictionary, DriverInfo: NSDictionary, carInfo : NSDictionary) {
        let next = self.storyboard?.instantiateViewController(withIdentifier: "DriverInfoViewController") as! DriverInfoViewController
        
        next.strDriverName = DriverInfo.object(forKey: "Fullname") as! String
        next.strPickupLocation = "Pickup Location : \(bookingInfo.object(forKey: "PickupLocation") as! String)"
        next.strDropoffLocation = "Dropoff Location : \(bookingInfo.object(forKey: "DropoffLocation") as! String)"
        if let carClass = carInfo.object(forKey: "Model") as? NSDictionary {
            next.strCarClass = carClass.object(forKey: "Name") as! String // String(describing: carInfo.object(forKey: "VehicleModel")!)
        }
        else {
            next.strCarClass = String(describing: carInfo.object(forKey: "VehicleModel")!)
        }
        
        
        next.strCareName = carInfo.object(forKey: "Company") as! String
        next.strDriverImage = WebserviceURLs.kImageBaseURL + (DriverInfo.object(forKey: "Image") as! String)
        next.strCarImage = WebserviceURLs.kImageBaseURL + (carInfo.object(forKey: "VehicleImage") as! String)
        
        //        if (SingletonClass.sharedInstance.passengerTypeOther) {
        //            next.strPassengerMobileNumber = bookingInfo.object(forKey: "PassengerContact") as! String
        //        }
        //        else {
        next.strPassengerMobileNumber = DriverInfo.object(forKey: "MobileNo") as! String
        //        }
        
        UtilityClass.presentAlertVC(selfVC: next)
        //        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController?.present(next, animated: true, completion: nil)
    }
    
    
    func completeTripInfo() {
        
        clearMap()
        self.stopTimer()
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
        self.timerForUpdatingPassengerLocation()
        UtilityClass.showAlertWithCompletion("Your trip has been completed", message: "", vc: self, completionHandler: { (status) in
            
            if (status == true)
            {
                
                self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
                
                //                self.dismiss(animated: true, completion: nil)
                //                    self.socket.off(SocketData.kBookingCompletedNotification)
                self.arrDataAfterCompletetionOfTrip = NSMutableArray(array: (self.aryCompleterTripData[0] as! NSDictionary).object(forKey: "Info") as! NSArray)
                
                self.viewTripActions.isHidden = true
                self.viewCarLists.isHidden = false
                self.ConstantViewCarListsHeight.constant = 200 // 150
                //                    self.constraintTopSpaceViewDriverInfo.constant = 170
                self.viewMainFinalRating.isHidden = true
                SingletonClass.sharedInstance.passengerTypeOther = false
                self.currentLocationAction()
                self.getPlaceFromLatLong()
                
                self.getRaringNotification()
                
                self.clearDataAfteCompleteTrip()
                
                self.performSegue(withIdentifier: "seguePresentTripDetails", sender: nil)
                
                self.btnPointToPoint(self.btnPointToPoint)
                //                if (SingletonClasas.sharedInstance.passengerTypeOther) {
                //                }
                //                else {
                //
                //                    self.openRatingView()
                //                }
                
                
            }
        })
        
    }
    
    func clearSetupMapForNewBooking() {
        
        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
        clearMap()
        self.currentLocationAction()
        self.viewTripActions.isHidden = true
        //        self.viewCarLists.isHidden = false
        //        self.ConstantViewCarListsHeight.constant = 150
        clearDataAfteCompleteTrip()
    }
    
    func clearDataAfteCompleteTrip() {
        
        self.MarkerCurrntLocation.isHidden = false
        selectedIndexPath = nil
        self.collectionViewCars.reloadData()
        self.txtCurrentLocation.text = ""
        self.txtDestinationLocation.text = ""
        self.dropoffLat = 0
        self.doublePickupLng = 0
        
        //        SingletonClass.sharedInstance.strPassengerID = ""
        
        self.strModelId = ""
        self.strPickupLocation = ""
        self.strDropoffLocation = ""
        self.doublePickupLat = 0
        self.doublePickupLng = 0
        self.doubleDropOffLat = 0
        self.doubleDropOffLng = 0
        self.strModelId = ""
        self.txtNote.text = ""
        self.txtFeedbackFinal.text = ""
        self.txtHavePromocode.text = ""
        self.txtSelectPaymentOption.text = ""
        SingletonClass.sharedInstance.isTripContinue = false
        
        
        setClearTextFieldsOfExtra()
    }
    
    func getRaringNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(HomeViewController.openRatingView), name: Notification.Name("CallToRating"), object: nil)
    }
    
    @objc func openRatingView() {
        
        let next = self.storyboard?.instantiateViewController(withIdentifier: "GiveRatingViewController") as! GiveRatingViewController
        next.strBookingType = self.strBookingType
        next.modalPresentationStyle = .fullScreen
        
        //        next.delegate = self
        //            self.presentingViewController?.modalPresentationStyle
        self.present(next, animated: true, completion: nil)
    }
    
    func socketMethodForCancelRequestTrip()
    {
        
        let myJSON = [SocketDataKeys.kBookingIdNow : SingletonClass.sharedInstance.bookingId] as [String : Any]
        socket.emit(SocketData.kCancelTripByPassenger , with: [myJSON])
        stopTimer()
        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
        self.viewCarLists.isHidden = true
        CancellationFee = ""
        setClearTextFieldsOfExtra()
        self.btnCurrentLocation(self.btnCurrentLocation)
    }
    // ------------------------------------------------------------
    
    
    var driverIDTimer : String!
    var passengerIDTimer : String!
    func sendPassengerIDAndDriverIDToGetLocation(driverID : String , passengerID: String) {
        
        
        driverIDTimer = driverID
        passengerIDTimer = passengerID
        if timerToGetDriverLocation == nil {
            
            DispatchQueue.global(qos: .background).sync {
                timerToGetDriverLocation = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(HomeViewController.getDriverLocation), userInfo: nil, repeats: true)
            }
        }
        
    }
    
    func stopTimer() {
        if timerToGetDriverLocation != nil {
            timerToGetDriverLocation.invalidate()
            timerToGetDriverLocation = nil
        }
    }
    
    @objc func getDriverLocation()
    {
        let myJSON = ["PassengerId" : passengerIDTimer,  "DriverId" : driverIDTimer] as [String : Any]
        socket.emit(SocketData.kSendDriverLocationRequestByPassenger , with: [myJSON])
    }
    
    
    func postPickupAndDropLocationForEstimateFare()
    {
        let driverID = aryOfOnlineCarsIds.compactMap{ $0 }.joined(separator: ",")
        
        var myJSON = ["PassengerId" : SingletonClass.sharedInstance.strPassengerID,  "PickupLocation" : strPickupLocation ,"PickupLat" :  self.doublePickupLat , "PickupLong" :  self.doublePickupLng, "DropoffLocation" : strDropoffLocation,"DropoffLat" : self.doubleDropOffLat, "DropoffLon" : self.doubleDropOffLng,"Ids" : driverID ] as [String : Any]
        
        if(strDropoffLocation.count == 0)
        {
            myJSON = ["PassengerId" : SingletonClass.sharedInstance.strPassengerID,  "PickupLocation" : strPickupLocation ,"PickupLat" :  self.doublePickupLat , "PickupLong" :  self.doublePickupLng, "DropoffLocation" : strPickupLocation,"DropoffLat" : self.doubleDropOffLng, "DropoffLon" : self.doubleDropOffLng,"Ids" : driverID ] as [String : Any]
        }
        socket.emit(SocketData.kSendRequestForGetEstimateFare , with: [myJSON])
    }
    
    func CancelBookLaterTripAfterDriverAcceptRequest() {
        
        let myJSON = [SocketDataKeys.kBookingIdNow : SingletonClass.sharedInstance.bookingId] as [String : Any]
        socket.emit(SocketData.kAdvancedBookingCancelTripByPassenger , with: [myJSON])
        
        self.setHideAndShowTopViewWhenRequestAcceptedAndTripStarted(status: false)
        
        clearDataAfteCompleteTrip()
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Auto Suggession on Google Map
    //-------------------------------------------------------------
    
    var BoolCurrentLocation = Bool()
    
    
    @IBAction func txtDestinationLocation(_ sender: UITextField) {
        
        
        
        let visibleRegion = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        acController.autocompleteBounds = bounds
        
        BoolCurrentLocation = false
        acController.tintColor = UIColor.black
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.black], for: UIControl.State.normal)
        
        UtilityClass.showNavigationTextColor(color: UIColor.black)
        
        present(acController, animated: true, completion: nil)
        
    }
    
    @IBAction func txtCurrentLocation(_ sender: UITextField) {
        
        
        let visibleRegion = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        let acController = GMSAutocompleteViewController()
        acController.delegate = self
        acController.autocompleteBounds = bounds
        
        BoolCurrentLocation = true
        
        acController.tintColor = UIColor.black
        
        
        //        let cancelBut_: AnyObject] = [NSAttributedStringKey.foregroundColor.rawValue: UIColor.black]
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.black], for: UIControl.State.normal)
        // .setTitleTextAttributes(cancelButtonAttributes, for: .normal)
        
        UtilityClass.showNavigationTextColor(color: UIColor.black)
        
        present(acController, animated: true, completion: nil)
    }
    
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        UtilityClass.hideNavigationTextColor()
        //        btnPointToPoint(btnPointToPoint)
        if BoolCurrentLocation {
            
            self.strLocationType = currentLocationMarkerText
            self.btnDoneForLocationSelected.isHidden = false
            self.ConstantViewCarListsHeight.constant = 0
            self.viewCarLists.isHidden = true
            
            txtCurrentLocation.text = place.name ?? "" + " " + place.formattedAddress! // place.formattedAddress
            strPickupLocation = place.name ?? "" + " " + place.formattedAddress! // place.formattedAddress!
            doublePickupLat = place.coordinate.latitude
            doublePickupLng = place.coordinate.longitude
            
            currentLocationMarker.map = nil
            
            _ = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
            let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,longitude: place.coordinate.longitude, zoom: 17.5)
            self.mapView.camera = camera
            mapView.animate(to: camera)
            
        }
        else {
            
            strLocationType = destinationLocationMarkerText
            self.strLocationType = destinationLocationMarkerText
            self.btnDoneForLocationSelected.isHidden = false
            self.ConstantViewCarListsHeight.constant = 0
            self.viewCarLists.isHidden = true
            
            txtDestinationLocation.text = place.name ?? "" + " " + place.formattedAddress! // place.formattedAddress
            strDropoffLocation = place.name ?? "" + " " + place.formattedAddress! // place.formattedAddress!
            doubleDropOffLat = place.coordinate.latitude
            doubleDropOffLng = place.coordinate.longitude
            
            destinationLocationMarker.map = nil
            
            _ = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
            
            let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,longitude: place.coordinate.longitude, zoom: 17.5)
            self.mapView.camera = camera
            mapView.animate(to: camera)
            
            if txtCurrentLocation.text!.count != 0 && txtDestinationLocation.text!.count != 0 && aryOfOnlineCarsIds.count != 0 {
                postPickupAndDropLocationForEstimateFare()
            }
            
        }
        self.btnDoneForLocationSelected.isHidden = false
        dismiss(animated: true, completion: nil)
    }
    
    func setupBothCurrentAndDestinationMarkerAndPolylineOnMap() {
        
        if  txtCurrentLocation.text != "" && txtDestinationLocation.text != "" {
            
            MarkerCurrntLocation.isHidden = true
            
            stackViewNumberOfPassenger.isHidden = false
            viewNotesOnBooking.isHidden = false
            
            imgTopViewOfTripPickupAndDropoffLocation.image = UIImage(named: "iconHomeScreenTopView")
            
            var PickupLat = doublePickupLat
            var PickupLng = doublePickupLng
            
            if(SingletonClass.sharedInstance.isTripContinue)
            {
                PickupLat = doubleUpdateNewLat
                PickupLng = doubleUpdateNewLng
            }
            
            
            let DropOffLat = doubleDropOffLat
            let DropOffLon = doubleDropOffLng
            
            let dummyLatitude = Double(PickupLat) - Double(DropOffLat)
            let dummyLongitude = Double(PickupLng) - Double(DropOffLon)
            
            let waypointLatitude = Double(PickupLat) - dummyLatitude
            let waypointSetLongitude = Double(PickupLng) - dummyLongitude
            
            let originalLoc: String = "\(PickupLat),\(PickupLng)"
            let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
            
            
            let bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: PickupLat, longitude: PickupLng), coordinate: CLLocationCoordinate2D(latitude: DropOffLat, longitude: DropOffLon))
            
            let update = GMSCameraUpdate.fit(bounds, withPadding: CGFloat(100))
            
            self.mapView.animate(with: update)
            
            self.mapView.moveCamera(update)
            
            setDirectionLineOnMapForSourceAndDestinationShow(origin: originalLoc, destination: destiantionLoc, completionHandler: nil)
            
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        //print("Error: \(error)")
        UtilityClass.hideNavigationTextColor()
        self.btnDoneForLocationSelected.isHidden = false
        dismiss(animated: true, completion: nil)
    }
    
    // User cancelled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        //print("Autocomplete was cancelled.")
        UtilityClass.hideNavigationTextColor()
        self.btnDoneForLocationSelected.isHidden = false
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnClearPickupLocation(_ sender: UIButton) {
        //        txtCurrentLocation.text = ""
        clearMap()
        clearCurrentLocation()
        
        setClearTextFieldsOfExtra()
    }
    
    @IBAction func btnClearDropOffLocation(_ sender: UIButton) {
        //        txtDestinationLocation.text = ""
        clearMap()
        clearDestinationLocation()
        
        setClearTextFieldsOfExtra()
    }
    
    func clearCurrentLocation() {
        
        MarkerCurrntLocation.isHidden = false
        txtCurrentLocation.text = ""
        strPickupLocation = ""
        doublePickupLat = 0
        doublePickupLng = 0
        self.currentLocationMarker.map = nil
        self.destinationLocationMarker.map = nil
        self.strLocationType = self.currentLocationMarkerText
        self.routePolyline.map = nil
        
        self.btnDoneForLocationSelected.isHidden = false
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
        
        stackViewNumberOfPassenger.isHidden = true
        viewNotesOnBooking.isHidden = true
        imgTopViewOfTripPickupAndDropoffLocation.image = UIImage(named: "iconHomeScreenTopView2")
    }
    
    func clearDestinationLocation() {
        
        MarkerCurrntLocation.isHidden = false
        txtDestinationLocation.text = ""
        strDropoffLocation = ""
        doubleDropOffLat = 0
        doubleDropOffLng = 0
        self.destinationLocationMarker.map = nil
        self.currentLocationMarker.map = nil
        self.strLocationType = self.destinationLocationMarkerText
        self.routePolyline.map = nil
        
        stackViewNumberOfPassenger.isHidden = true
        viewNotesOnBooking.isHidden = true
        
        imgTopViewOfTripPickupAndDropoffLocation.image = UIImage(named: "iconHomeScreenTopView2")
        
        self.btnDoneForLocationSelected.isHidden = false
        self.ConstantViewCarListsHeight.constant = 0
        self.viewCarLists.isHidden = true
    }
    
    
    func setClearTextFieldsOfExtra() {
        
        self.intNumberOfPassenger = 01
        self.intNoOfBages = 00
        self.lblNoOfBags.text = "0\(self.intNoOfBages)"
        self.lblNumberOfPassengers.text = "0\(self.intNumberOfPassenger)"
        self.lblApproxCost.text = "$00.00"
        self.lblNotes.text = ""
        self.txtNote.text = ""
        self.txtHavePromocode.text = ""
        
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if(textField == txtSelectPaymentOption)
        {
            txtSelectPaymentOption.text = cardData[pickerView.selectedRow(inComponent: 0)]["CardNum2"] as? String ?? ""
        }
    }
    
    //-------------------------------------------------------------
    // MARK: - Map Draw Line
    //-------------------------------------------------------------
    
    let geocoder = GMSGeocoder()
    var strLocationType = String()
    
    
    func setLineData() {
        
        let singletonData = SingletonClass.sharedInstance.dictIsFromPrevious
        
        txtCurrentLocation.text = singletonData.object(forKey: "PickupLocation") as? String
        txtDestinationLocation.text = singletonData.object(forKey: "DropoffLocation") as? String
        
        let DropOffLat = singletonData.object(forKey: "DropOffLat") as! Double
        let DropOffLon = singletonData.object(forKey: "DropOffLon") as! Double
        
        let PickupLat = singletonData.object(forKey: "PickupLat") as! Double
        let PickupLng = singletonData.object(forKey: "PickupLng")as! Double
        
        let dummyLatitude: Double = Double(PickupLat) - Double(DropOffLat)
        let dummyLongitude: Double = Double(PickupLng) - Double(DropOffLon)
        
        let waypointLatitude = PickupLat - dummyLatitude
        let waypointSetLongitude = PickupLng - dummyLongitude
        
        let originalLoc: String = "\(PickupLat),\(PickupLng)"
        let destiantionLoc: String = "\(DropOffLat),\(DropOffLon)"
        
        
        self.getDirectionsSeconMethod(origin: originalLoc, destination: destiantionLoc, completionHandler: nil)
        
    }
    
    func clearMap() {
        
        self.mapView.clear()
        self.driverMarker = nil
        self.mapView.delegate = self
        
        self.destinationLocationMarker.map = nil
        
        //        self.mapView.stopRendering()
        //        self.mapView = nil
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Current Booking Methods
    //-------------------------------------------------------------
    
    var dictCurrentBookingInfoData = NSDictionary()
    var dictCurrentDriverInfoData = NSDictionary()
    var aryCurrentBookingData = NSMutableArray()
    var checkBookingType = String()
    
    var bookingIDNow = String()
    var advanceBookingID = String()
    var passengerId = String()
    
    var strBookingType = String()
    var CancellationFee = String()
    
    func webserviceOfCurrentBooking() {
        
        if let Token = UserDefaults.standard.object(forKey: "Token") as? String {
            SingletonClass.sharedInstance.deviceToken = Token
            print("SingletonClass.sharedInstance.deviceToken : \(SingletonClass.sharedInstance.deviceToken)")
        }
        
        let param = SingletonClass.sharedInstance.strPassengerID + "/" + SingletonClass.sharedInstance.deviceToken
        
        webserviceForCurrentTrip(param as AnyObject) { (result, status) in
            
            if (status) {
                // print(result)
                
                self.clearMap()
                
                let resultData = (result as! NSDictionary)
                
                
                if let walletInfo = resultData.object(forKey: "credit_info") as? [String:Any]
                {
                    SingletonClass.sharedInstance.creditHistoryData = walletInfo
                }
                
                
                var dict3 = [String:AnyObject]()
                dict3["CardNum"] = "credit" as AnyObject
                dict3["CardNum2"] = "credit" as AnyObject
                dict3["Type"] = "iconWalletBlack" as AnyObject
                
           
                
                if(UtilityClass.returnValueForCredit(key: "IsRequestCreditAccount") == "2")
                {
                    self.aryCardsListForBookNow.append(dict3)
                    
                }
                
                SingletonClass.sharedInstance.passengerRating = resultData.object(forKey: "rating") as! String
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rating"), object: nil)
                
                self.aryCurrentBookingData.add(resultData)
                self.aryRequestAcceptedData = self.aryCurrentBookingData
                
                
                if self.aryCurrentBookingData.count != 0 {
                    if let dictCurrentData = self.aryCurrentBookingData.object(at: 0) as? [String:Any] {
                        if let CarInfo = dictCurrentData["CarInfo"] as? [[String:Any]] {
                            if CarInfo.count != 0 {
                                if let CarInfoFirst = CarInfo.first {
                                    if let model = CarInfoFirst["Model"] as? [String:Any] {
                                        
                                        if let IntCncelltionFeeIs = model["CancellationFee"] as? Int {
                                            self.CancellationFee = "\(IntCncelltionFeeIs)"
                                        }
                                        else if let strCancelltionFeeIs = model["CancellationFee"] as? String {
                                            self.CancellationFee = strCancelltionFeeIs
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                let bookingType = (self.aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "BookingType") as! String
                
                if bookingType != "" {
                    
                    
                    self.MarkerCurrntLocation.isHidden = true
                    self.btnDoneForLocationSelected.isHidden = true
                    
                    
                    if bookingType == "BookNow" {
                        
                        self.dictCurrentBookingInfoData = ((resultData).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
                        let statusOfRequest = self.dictCurrentBookingInfoData.object(forKey: "Status") as! String
                        
                        self.strBookingType = bookingType
                        
                        if statusOfRequest == "accepted" {
                            
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            self.bookingTypeIsBookNowAndAccepted()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            SingletonClass.sharedInstance.isTripContinue = true
                            
                            self.bookingTypeIsBookNowAndTraveling()
                        }
                        
                    }
                    else if bookingType == "BookLater" {
                        
                        self.dictCurrentBookingInfoData = ((resultData).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
                        let statusOfRequest = self.dictCurrentBookingInfoData.object(forKey: "Status") as! String
                        
                        self.strBookingType = bookingType
                        
                        if statusOfRequest == "accepted" {
                            
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            self.bookingTypeIsBookNowAndAccepted()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            SingletonClass.sharedInstance.isTripContinue = true
                            
                            self.bookingTypeIsBookNowAndTraveling()
                        }
                    }
                    
                    NotificationCenter.default.post(name: NotificationForAddNewBooingOnSideMenu, object: nil)
                    
                    
                }
            }
            else {
                
                //                let resultData = (result as! NSDictionary)
                
                let resultData = (result as! NSDictionary)
                
                
                if let walletInfo = resultData.object(forKey: "credit_info") as? [String:Any]
                {
                    SingletonClass.sharedInstance.creditHistoryData = walletInfo
                }
                
                
                var dict3 = [String:AnyObject]()
                dict3["CardNum"] = "credit" as AnyObject
                dict3["CardNum2"] = "credit" as AnyObject
                dict3["Type"] = "iconWalletBlack" as AnyObject
                

                
                if(UtilityClass.returnValueForCredit(key: "IsRequestCreditAccount") == "2")
                {
                    
                    self.aryCardsListForBookNow.append(dict3)
                    
                }
                
                //                SingletonClass.sharedInstance.passengerRating = resultData.object(forKey: "rating") as! String
                //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rating"), object: nil)
                
            }
        }
        
    }
    
    //-------------------------------------------------------------
    // MARK: - Webservice Methods
    //-------------------------------------------------------------
    
    @objc func webserviceOfRunningTripTrack() {
        
        
        webserviceForTrackRunningTrip(SingletonClass.sharedInstance.bookingId as AnyObject) { (result, status) in
            
            if (status) {
                // print(result)
                
                self.clearMap()
                
                let resultData = (result as! NSDictionary)
                
                //                SingletonClass.sharedInstance.passengerRating = resultData.object(forKey: "rating") as! String
                //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "rating"), object: nil)
                self.aryCurrentBookingData.removeAllObjects()
                self.aryCurrentBookingData.add(resultData)
                self.aryRequestAcceptedData = self.aryCurrentBookingData
                
                let bookingType = (self.aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "BookingType") as! String
                
                if bookingType != "" {
                    
                    self.MarkerCurrntLocation.isHidden = true
                    
                    if bookingType == "BookNow" {
                        
                        self.dictCurrentBookingInfoData = ((resultData).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
                        let statusOfRequest = self.dictCurrentBookingInfoData.object(forKey: "Status") as! String
                        
                        self.strBookingType = bookingType
                        
                        if statusOfRequest == "accepted" {
                            
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            self.bookingTypeIsBookNowAndAccepted()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            SingletonClass.sharedInstance.isTripContinue = true
                            
                            self.bookingTypeIsBookNowAndTraveling()
                        }
                        
                    }
                    else if bookingType == "BookLater" {
                        
                        self.dictCurrentBookingInfoData = ((resultData).object(forKey: "BookingInfo") as! NSArray).object(at: 0) as! NSDictionary
                        let statusOfRequest = self.dictCurrentBookingInfoData.object(forKey: "Status") as! String
                        
                        self.strBookingType = bookingType
                        
                        if statusOfRequest == "accepted" {
                            
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            self.bookingTypeIsBookNowAndAccepted()
                            
                        }
                        else if statusOfRequest == "traveling" {
                            self.bookingIDNow = self.dictCurrentBookingInfoData.object(forKey: "Id") as! String
                            self.passengerId = SingletonClass.sharedInstance.strPassengerID
                            SingletonClass.sharedInstance.bookingId = self.bookingIDNow
                            
                            SingletonClass.sharedInstance.isTripContinue = true
                            
                            self.bookingTypeIsBookNowAndTraveling()
                        }
                    }
                }
            }
            else {
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                let OK = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OK)
                self.present(alert, animated: true, completion: nil)
                
            }
        }
    }
    
    // ----------------------------------------------------------------------
    // Book Now Accept Request
    // ----------------------------------------------------------------------
    
    func bookingTypeIsBookNowAndAccepted() {
        
        if let vehicleModelId = (((aryCurrentBookingData.object(at: 0) as? NSDictionary)?.object(forKey: "CarInfo") as? NSArray)?.object(at: 0) as? NSDictionary)?.object(forKey: "VehicleModel") as? String {
            
            for i in 0..<self.arrTotalNumberOfCars.count {
                
                let indexOfCar = self.arrTotalNumberOfCars.object(at: i) as! NSDictionary
                if vehicleModelId == indexOfCar.object(forKey: "Id") as! String {
                    strSelectedCarMarkerIcon = markertIconName(carType: indexOfCar.object(forKey: "Name") as! String)
                }
            }
        }
        
        //        SingletonClass.sharedInstance.isTripContinue = true
        self.DriverInfoAndSetToMap(driverData: NSArray(array: aryCurrentBookingData))
        
    }
    
    func bookingTypeIsBookNowAndTraveling() {
        
        //        clearMap()
        
        if let vehicleModelId = (((aryCurrentBookingData.object(at: 0) as! NSDictionary).object(forKey: "CarInfo") as! NSArray).object(at: 0) as! NSDictionary).object(forKey: "VehicleModel") as? String {
            
            for i in 0..<self.arrTotalNumberOfCars.count {
                
                let indexOfCar = self.arrTotalNumberOfCars.object(at: i) as! NSDictionary
                if vehicleModelId == indexOfCar.object(forKey: "Id") as! String {
                    strSelectedCarMarkerIcon = markertIconName(carType: indexOfCar.object(forKey: "Name") as! String)
                }
            }
        }
        
        self.methodAfterStartTrip(tripData: NSArray(array: aryCurrentBookingData))
    }
    
    
    func markertIconName(carType: String) -> String {
        
        switch carType {
        case "First Class":
            return "iconFirstClass"
        case "Business Class":
            return "iconBusinessClass"
        case "Economy":
            return "iconEconomy"
        case "Taxi":
            return "iconTaxi"
        case "LUX-VAN":
            return "iconLuxVan"
        case "Disability":
            return "iconDisability"
        default:
            return "dummyCar"
        }
        
    }
    
    func markerCarIconName(modelId: Int) -> String {
        
        var CarModel = String()
        
        switch modelId {
        case 1:
            CarModel = "imgBusinessClass"
            return CarModel
        case 2:
            CarModel = "imgMIni"
            return CarModel
        case 3:
            CarModel = "imgVan"
            return CarModel
        case 4:
            CarModel = "imgNano"
            return CarModel
        case 5:
            CarModel = "imgTukTuk"
            return CarModel
        case 6:
            CarModel = "imgBreakdown"
            return CarModel
        default:
            CarModel = "dummyCar"
            return CarModel
        }
        
    }
    
    func sortCarListFirstTime() {
        
        let sortedArray = (aryTempOnlineCars as NSArray).sortedArray(using: [NSSortDescriptor(key: "Sort", ascending: true)]) as! [[String:AnyObject]]
        arrNumberOfOnlineCars = NSMutableArray(array: sortedArray)
        self.collectionViewCars.reloadData()
    }
    
    //-------------------------------------------------------------
    // MARK: - ARCar Movement Delegate Method
    //-------------------------------------------------------------
    func ARCarMovementMoved(_ Marker: GMSMarker) {
        driverMarker = Marker
        driverMarker.map = mapView
    }
    
    var destinationCordinate: CLLocationCoordinate2D!
    
    //-------------------------------------------------------------
    // MARK: - Car List Methods
    //-------------------------------------------------------------
    
    
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
    return input.rawValue
}

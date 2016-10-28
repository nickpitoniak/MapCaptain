
import UIKit
import CoreLocation

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    var threeSTimer: NSTimer!
    
    var intervalCounter: Int = 0
    
    @IBOutlet weak var nearbyShitUpdateLabel: UILabel!
    @IBOutlet weak var streetUpdateLabel: UILabel!
    @IBOutlet weak var latLonUpdateLabel: UILabel!
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidAppear(animated: Bool) {
        RoadMap.giveKey()
        TheDriver.locationSetup()
        TheDriver.locationManager.startUpdatingLocation()
        threeSTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(threeSecondInterval), userInfo: nil, repeats: true)
    }
    
    @objc func threeSecondInterval() {
        
        self.intervalCounter = self.intervalCounter + 1
        print("3 SEC UPDATED #\(self.intervalCounter) ********")
        print("T")
        RoadMap.updateStreetComplete()
        print("U")
        if TheDriver.locationDetails.currentStreetIds != nil {
            RoadMap.updateNearbyComplete()
        }
        print("V")
    }
    
    @IBAction func actionButtonTwo(sender: UIButton) {
        var totalString = "Current Nearby Shit:\n"
        if(!globalPrelimChecker.flightCheck()) {
            self.sendAlert("FVC: Network Connection Error", messageInfo: "Unable to fetch info. Please wait while this problem is solved", buttonTitle: "Dismiss")
            return
        }
        let nearbyShit = TheDriver.locationDetails.nearbyLocations
        for establishment in nearbyShit {
            totalString = totalString + "["
            totalString = totalString + "[" + establishment.name + "]"
            totalString = totalString + "[" + establishment.placeId + "]"
            totalString = totalString + "[" + String(establishment.latitude) + "]"
            totalString = totalString + "[" + String(establishment.longitude) + "]"
            totalString = totalString + "[" + String(establishment.distanceAway) + "]"
            totalString = totalString + "],"
        }
        totalString = totalString + "]\n"
        self.nearbyShitUpdateLabel.text = totalString
    }
    
    @IBAction func actionButton(sender: UIButton) {
        self.streetUpdateLabel.text = TheDriver.locationDetails.currentStreet
    }
    
    @IBAction func refreshButton(sender: UIButton) {
        var totalString = "Current Lat/Lon:\n"
        if(!globalPrelimChecker.flightCheck()) {
            self.sendAlert("FVC: Network Connection Error", messageInfo: "Unable to fetch info. Please wait while this problem is solved", buttonTitle: "Dismiss")
            return
        }
        let currentLat = TheDriver.locationDetails.currentLatitude
        let currentLon = TheDriver.locationDetails.currentLongitude
        totalString = totalString + "Latitude:\(currentLat)\nLongitude: \(currentLon)\n"
        self.latLonUpdateLabel.text = totalString
    }
    
    func sendAlert(messageTitle: String, messageInfo: String, buttonTitle: String) {
        let alertController = UIAlertController(title: messageTitle, message:
            messageInfo, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default,handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func connectionFuckUpReport() {
        self.sendAlert("Network Connection Error", messageInfo: "Unable to connect to a network. This issue is being solved, please be patient", buttonTitle: "Dismiss")
    }
    
    func internalMapFuckUpReport() {
        self.sendAlert("Location Reading Error", messageInfo: "An error occured with the GPS database. This issue is being solved now, please be patient", buttonTitle: "Dismiss")
    }
    
} // end firstViewController class & locatoinManager delegate


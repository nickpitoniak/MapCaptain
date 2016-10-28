
import Foundation
import CoreLocation

class Driver: NSObject, CLLocationManagerDelegate {
    
    var locationDetails = LocationDetails()
    var locationManager: CLLocationManager = CLLocationManager()
    var netSearchTimer: NSTimer!
    
    override init() {
        
    }
    
    func getCurrentLatitude() -> String {
        return self.locationDetails.currentLatitude
    }
    
    func getCurrentLongitude() -> String {
        return self.locationDetails.currentLongitude
    }
    
    func locationSetup() {
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
    }
    
    func endFetchingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        globalPrelimChecker.workingMap = false
        print("Unable to access location\nError: \(error)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location:CLLocation = locations[locations.count-1] as CLLocation {
            self.locationDetails.currentLatitude = String(format: "%.4f", location.coordinate.latitude)
            self.locationDetails.currentLongitude = String(format: "%.4f", location.coordinate.longitude)
            let currentSpeed = locationManager.location?.speed
            if currentSpeed != nil {
                self.locationDetails.currentSpeed = currentSpeed
            } else {
                self.locationDetails.currentSpeed = nil
            }
            globalPrelimChecker.workingMap = true
            return
        } else {
            globalPrelimChecker.workingMap = false
            return
        }
    }
    
} // end Driver class
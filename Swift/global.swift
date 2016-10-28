
import Foundation
import SystemConfiguration

struct LocationDetails {
    var latDuringCheck: String = "";
    var lngDuringCheck: String = "";
    var currentLatitude: String = ""
    var currentLongitude: String = ""
    var currentStreet: String?
    var currentStreetIds: String?
    var currentSpeed: Double?
    var nearbyLocations: Array<(name: String, placeId: String, latitude: Double, longitude: Double, distanceAway: Double)> = []
}

struct APIKeys {
    let GoogleAPIiOSKey = "AIzaSyA0ZJBsD9D-iYJOZ8a9oT9RAvKroMq9Nk0"
    let GoogleAPIServerKey = "AIzaSyAtJp4DCF_NwY26LL3tuMYz6YxbyRhf_wk"
    let GoogleAPIDistanceMatrixKey = "AIzaSyA_fSeEfBmlZZNqseSfEevNielRLzWM_VM"
    let GoogleAPIGeocodeKey = "AIzaSyDmvL__sQHARU8aUjkEr8AbZvajMDLadxQ"
}

class prelimVerifier: FirstViewController {
    
    var googleAPIErrorCode: String?
    var searchForNetHalt = false
    var APIHalt = false
    var didExceedQuota = false
    var workingMap = false
    
    func checkNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        if (isReachable && !needsConnection) {
            self.resumeTheShow()
            return true
        }
        return false
    }
    
    func checkForConnection() -> Bool {
        if(self.workingMap && self.checkNetwork() && self.searchForNetHalt == false) {
            return true
        }
        return false
    }
    
    func googleAPIStatusFucked() -> Bool {
        if self.APIHalt == true {
            return true
        }
        return false
    }
    
    func flightCheck() -> Bool {
        if self.checkForConnection() && self.googleAPIStatusFucked() == false {
            return true
        }
        return false
    }
    
    func lockItDownForSearch() {
        self.searchForNetHalt = true
    }
    
    func resumeTheShow() {
        self.searchForNetHalt = false
    }
    
    func setAPIHardHalt() {
        self.APIHalt = true
    }
    
    func unsetAPIHardHalt() {
        self.APIHalt = false
    }
    
    func setAPIErrorCode(theError: String) {
        self.googleAPIErrorCode = theError
    }
    
    func unsetAPIErrorCode() {
        self.googleAPIErrorCode = nil
    }

} // end GLOBAL prelimVerifier()

class errorDiagnostic: prelimVerifier {
    
    var currentFatalError = FatalErrors.NoError
    
    enum FatalErrors {
        case NoConnection
        case APIError
        case ExceededQuota
        case Unknown
        case UnknownAndFucked
        case NoError
    }
    
    func identifyError() {
        if self.didExceedQuota == true {
            self.attemptToFixError(FatalErrors.ExceededQuota)
            
        } else if self.checkForConnection() == false {
            self.attemptToFixError(FatalErrors.NoConnection)
            
        } else if self.APIHalt {
            self.attemptToFixError(FatalErrors.APIError)
            
        } else if self.isUnknownLocalError() {
            self.attemptToFixError(FatalErrors.Unknown)
            
        } else if self.isUnknownBugError() {
            self.currentFatalError = FatalErrors.UnknownAndFucked
        } else {
            self.errorsResolved()
        }
    }
    
    func attemptToFixError(theError: FatalErrors) -> Bool {
        switch(theError) {
        case .NoConnection:
            self.currentFatalError = FatalErrors.NoConnection
            return false
        case .APIError:
            self.currentFatalError = FatalErrors.APIError
            return false
        case .Unknown:
            self.currentFatalError = FatalErrors.Unknown
            return false
        case .ExceededQuota:
            self.currentFatalError = FatalErrors.ExceededQuota
            return false
        case .UnknownAndFucked:
            self.currentFatalError = FatalErrors.UnknownAndFucked
            return false
        case .NoError:
            self.currentFatalError = FatalErrors.NoError
            self.errorsResolved()
            return true
        }// end theError switch statement
    }// end fixError()
    
    func isUnknownLocalError() -> Bool {
        if self.checkNetwork() && !self.googleAPIStatusFucked() {
            return true
        }
        return false
    }
    
    func isUnknownBugError() -> Bool {
        if self.flightCheck() && self.checkServices() == false {
            return true
        }
        return false
    }
    
    func checkServices() -> Bool {
        return true
    }
    
    func errorsResolved() {
        
    }// end errorsResolved
}

var bugDoctor = errorDiagnostic()
var globalPrelimChecker = prelimVerifier()
var TheDriver = Driver()
var RoadMap = APIMachine()


import Foundation
import GooglePlaces

class APIMachine {
    
    let keychain = APIKeys()
    
    var oneSTimer: NSTimer!
    var placesClient: GMSPlacesClient?
    let bigRadius = 3200
    let smallRadius = 100
    var encounteredError = false
    
    func giveKey() {
        GMSPlacesClient.provideAPIKey(self.keychain.GoogleAPIiOSKey)
    }
    
    //*********************** COMPLETED API CALLS *************************
    
    func updateStreetComplete() {
        RoadMap.getStreetWithOSM(TheDriver.locationDetails.currentLatitude, currentLon: TheDriver.locationDetails.currentLongitude) { streetInfo in
            print(streetInfo)
            TheDriver.locationDetails.currentStreet = streetInfo
            //TheDriver.locationDetails.currentStreetIds.
            if streetInfo!.rangeOfString(" ") != nil {
                var idString = "";
                let streetSplit = streetInfo!.componentsSeparatedByString(" ")
                for i in streetSplit {
                    idString += i + "+";
                }
                TheDriver.locationDetails.currentStreetIds = idString;
            }
        }
    } // end updateThestreet
    
    func updateNearbyComplete() {
        RoadMap.getNearbyPlaces(TheDriver.locationDetails.currentLatitude, longitude: TheDriver.locationDetails.currentLongitude, radius: "500") { nearLocations, theStatus in
            TheDriver.locationDetails.nearbyLocations.removeAll()
            for location in nearLocations {
                TheDriver.locationDetails.nearbyLocations.append(location)
            }
        }
        self.filterForOncoming()
    }
    
    func filterForOncoming() {
        oneSTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(oneSecondInterval), userInfo: nil, repeats: true)
    }
    
    @objc func oneSecondInterval() {
        var oLat = TheDriver.locationDetails.latDuringCheck
        var oLng = TheDriver.locationDetails.lngDuringCheck
        var cLat = TheDriver.locationDetails.currentLatitude
        var cLng = TheDriver.locationDetails.currentLongitude
        var dist = self.getDistanceBetweenWithAppleLibComplete(oLat, originLon: oLng, destLat: cLat, destLon: cLng)
        if dist > 1 {
            var replaceArray: Array<(name: String, placeId: String, latitude: Double, longitude: Double, distanceAway: Double)> = []
            let closeLoc = TheDriver.locationDetails.nearbyLocations
            for index in closeLoc {
                if self.getDistanceBetweenWithAppleLibComplete(cLat, originLon: cLng, destLat: String(index[2]), destLon: String(index[3])) < index[4] {
                    
                }
            }
        }
    }
    
    func haversineForDistance(lat1:Double, lon1:Double, lat2:Double, lon2:Double) -> Double? {
        let lat1rad = lat1 * M_PI/180
        let lon1rad = lon1 * M_PI/180
        let lat2rad = lat2 * M_PI/180
        let lon2rad = lon2 * M_PI/180
        
        let dLat = lat2rad - lat1rad
        let dLon = lon2rad - lon1rad
        let a = sin(dLat/2) * sin(dLat/2) + sin(dLon/2) * sin(dLon/2) * cos(lat1rad) * cos(lat2rad)
        let c = 2 * asin(sqrt(a))
        let R = 6372.8
        print(R * c)
        return R * c
    }
    
    func getDistanceBetweenWithAppleLibComplete(originLat: String, originLon: String, destLat: String, destLon: String) -> Double? {
        let doubleOLat = (originLat as NSString).doubleValue
        let doubleOLon = (originLon as NSString).doubleValue
        let doubleDestLat = (destLat as NSString).doubleValue
        let doubleDestLon = (destLon as NSString).doubleValue

        let myLocation = CLLocation(latitude: doubleOLat, longitude: doubleOLon)
        let myBuddysLocation = CLLocation(latitude: doubleDestLat, longitude: doubleDestLon)
        let distance = myLocation.distanceFromLocation(myBuddysLocation)
        print(distance)
        return distance
    }
    
    // ********************** GOOGLE PLACES API CALLS *********************
    
    func getStreetWithOSM(currentLat: String, currentLon: String, completionHandler: (String?) -> Void) -> NSURLSessionTask {
        let path = "https://nominatim.openstreetmap.org/reverse?format=json&lat=\(String(currentLat))&lon=\(String(currentLon))&zoom=16"
        let myUrl = NSURL(string: path)
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "POST"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                if error != nil {
                }
                dispatch_async(dispatch_get_main_queue()) {
                    let streetInfo = self.parseJSONForStreet(responseString!)
                    completionHandler(streetInfo)
                    return
                }
            }
        }
        task.resume()
        return task
    }
    
    /*func getStreetWithGoogleRG() {
        let path = "https://maps.googleapis.com/maps/api/geocode/json?latlng=40.714224,-73.961452&key=YOUR_API_KEY"
        let myUrl = NSURL(string: path)
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "POST"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                if error != nil {
                }
                dispatch_async(dispatch_get_main_queue()) {
                    let streetInfo = self.parseJSONForStreet(responseString!)
                    completionHandler(streetInfo)
                    return
                }
            }
        }
        task.resume()
        return task
    }*/

    func getDistanceBetweenWithGoogle(originLat: String, originLon: String, destLat: String, destLon: String, completionHandler: Int? -> Void) -> NSURLSessionTask {
        let path = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=\(originLat),\(originLon)&destinations=\(destLat),\(destLon)&mode=driving&language=en-EN&sensor=false&key=\(self.keychain.GoogleAPIDistanceMatrixKey)"
        let myUrl = NSURL(string: path)
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "POST"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                if error != nil {
                    // call lockout
                }
                dispatch_async(dispatch_get_main_queue()) {
                    if responseString != nil {
                        let theStatus = self.getAPIRequestStatus(responseString!)
                        if theStatus != nil {
                            let distanceReading = self.parseJSONForDistanceReading(responseString!)
                            completionHandler(distanceReading)
                            return
                        } else {
                            //lock it down
                        }
                    }
                    completionHandler(nil)
                    return
                }
            }
        } // end tast instantiation
        task.resume()
        return task
    }


    func getNearbyPlaces(latitude: String, longitude: String, radius: String, completionHandler: (Array<(name: String, placeId: String, latitude: Double, longitude: Double, distanceAway: Double)>, String?) -> Void) -> NSURLSessionTask {
        let streetKeywords = TheDriver.locationDetails.currentStreetIds
        let path = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=\(self.keychain.GoogleAPIServerKey)&location=\(latitude),\(longitude)&radius=\(radius)&rankby=prominence&sensor=true&keyword=\(streetKeywords!)"
        print(path)
        let myUrl = NSURL(string: path)
        let request = NSMutableURLRequest(URL: myUrl!)
        request.HTTPMethod = "POST"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                if error != nil {
                    //call lockup function
                }
                dispatch_async(dispatch_get_main_queue()) {
                    let nearLocations = self.parseJSONForNearby(responseString!)
                    if responseString != nil {
                        let theStatus = self.getAPIRequestStatus(responseString!)
                        if theStatus != nil {
                            print("The Status: \(theStatus)")
                            completionHandler(nearLocations!, theStatus)
                            return
                        } else {
                            //call lockup function
                        }
                    } else {
                        //call lockup function
                    }
                    
                }
            }
        } // end tast instantiation
        task.resume()
        return task
    }
    
    // ************************* JSON PARSERS *************************
    
    func parseJSONForNearby(inputJSON: NSString) -> (Array<(name: String, placeId: String, latitude: Double, longitude: Double, distanceAway: Double)>)? {
        let inputStringToNSData = inputJSON.dataUsingEncoding(NSUTF8StringEncoding)
        var nearbyShit = Array<(name: String, placeId: String, latitude: Double, longitude: Double, distanceAway: Double)>()
        do {
            let myLat = TheDriver.locationDetails.currentLatitude
            let myLng = TheDriver.locationDetails.currentLongitude
            TheDriver.locationDetails.latDuringCheck = myLat
            TheDriver.locationDetails.lngDuringCheck = myLng
            let json = try NSJSONSerialization.JSONObjectWithData(inputStringToNSData!, options: .AllowFragments)
            if let results = json["results"] as? [[String: AnyObject]] {
                for result in results {
                    if let coordinates = result["geometry"] as? Dictionary<String,AnyObject> {
                        if let coloc = coordinates["location"] as? Dictionary<String,AnyObject> {
                            let lat: Double = coloc["lat"]!.doubleValue
                            let lng: Double = coloc["lng"]!.doubleValue
                            let distanceAway = getDistanceBetweenWithAppleLibComplete(myLat, originLon: myLng, destLat: String(lat), destLon: String(lng))
                            let locationToAdd = (result["name"] as! String, result["place_id"] as! String, lat, lng, distanceAway!)
                            nearbyShit.append(locationToAdd)
                        }
                    }
                }
            }
            return (nearbyShit)
        } catch {
            print("error serializing JSON: \(error)")
            return nil
        }
    }
    
    func parseJSONForDistanceReading(inputJSON: NSString) -> Int? {
        let inputStringToNSData = inputJSON.dataUsingEncoding(NSUTF8StringEncoding)
        var distanceBetween:Int!
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(inputStringToNSData!, options: .AllowFragments)
            if let rows = json["rows"] as? [[String: AnyObject]] {
                for row in rows {
                    if let elements = row["elements"] as? [[String: AnyObject]] {
                        for element in elements {
                            if let distance = element["distance"] as? Dictionary<String,AnyObject> {
                                distanceBetween = distance["value"] as? Int
                                    return(distanceBetween)
                            }
                        }
                    }
                }
            }
            return(nil)
        } catch {
            print("error serializing JSON: \(error)")
            //lock it down
        }
        return nil
    }
    
    func parseJSONForStreet(inputJSON: NSString) -> (String?) {
        let inputStringToNSData = inputJSON.dataUsingEncoding(NSUTF8StringEncoding)
        var returnRoad: String?
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(inputStringToNSData!, options: .AllowFragments)
            if let results = json["address"] as? [String: AnyObject] {
                let theRoad = results["road"] as? String
                returnRoad = theRoad
            }
        } catch {
            //lock this shit up
        }
        return(returnRoad)
    }
    
    func getAPIRequestStatus(inputJSON: NSString) -> String? {
        let inputStringToNSData = inputJSON.dataUsingEncoding(NSUTF8StringEncoding)
        do {
            let json = try NSJSONSerialization.JSONObjectWithData(inputStringToNSData!, options: .AllowFragments)
            if let theStatus = json["status"] as? String {
                print("The Status: \(theStatus)")
                return theStatus
            }
        } catch {
            //lock it down
        }
        return nil
    }

} // end APIMachine class
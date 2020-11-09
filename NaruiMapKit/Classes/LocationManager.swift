//
//  LocationManager.swift
//  test
//
//  Created by Changyul Seo on 2019/11/05.
//  Copyright © 2019 서창열. All rights reserved.
//

import Foundation
import CoreLocation
extension Notification.Name {
    static let locationUpdateNotification = Notification.Name(rawValue: "locationUpdateNotification")
}

public class LocationManager: NSObject {
    static let shared = LocationManager()
    var authStatus:CLAuthorizationStatus? = nil
    let manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    private var complete:((_ status:CLAuthorizationStatus?)->Void)? = nil
    private var getLocation:((_ locations:[CLLocation])->Void)? = nil
    
    func requestAuth(complete:@escaping(_ status:CLAuthorizationStatus?)->Void, getLocation:@escaping(_ locations: [CLLocation])->Void) {
        self.getLocation = getLocation
        if #available(iOS 9.0, *) {
            manager.requestLocation()
        }
        manager.startUpdatingLocation()
        if let status = authStatus {
            
            complete(status)
        } else {
            manager.requestWhenInUseAuthorization()
//            manager.requestAlwaysAuthorization()
            self.complete = complete
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authStatus = status
        complete?(status)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        #if targetEnvironment(simulator)
        let testLocations = [CLLocation(latitude: 37.0075355, longitude: 126.9816988)]
        self.getLocation?(testLocations)
        NotificationCenter.default.post(Notification(name: .locationUpdateNotification, object: testLocations, userInfo: nil))
        #endif
        print("fail : \(error.localizedDescription)")
        self.getLocation = nil
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        #if targetEnvironment(simulator)
        let testLocations = [CLLocation(latitude: 37.0075355, longitude: 126.9816988)]
        self.getLocation?(testLocations)
        NotificationCenter.default.post(Notification(name: .locationUpdateNotification, object: testLocations, userInfo: nil))
        #else
        self.getLocation?(locations)
        NotificationCenter.default.post(Notification(name: .locationUpdateNotification, object: locations, userInfo: nil))
        #endif
        
        self.getLocation = nil
    }
    
}


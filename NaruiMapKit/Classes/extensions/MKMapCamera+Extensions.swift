//
//  MKMapCamera+Extensions.swift
//  NaruiMapKit
//
//  Created by Changyeol Seo on 2020/11/09.
//

import Foundation
import MapKit
extension MKMapCamera {
    var distance:CLLocationDistance {
        set {
            if #available(iOS 13.0, *) {
                centerCoordinateDistance = newValue
            } else {
                altitude = newValue
            }
        }
        get {
            if #available(iOS 13.0, *) {
                return centerCoordinateDistance
            } else {
                return altitude
            }
        }
    }
}

//
//  UserDefault+Extensions.swift
//  NaruiMapKit
//
//  Created by Changyeol Seo on 2020/12/22.
//

import Foundation
extension UserDefaults {
    var lastSelectedRangeIndex:Int {
        set {
            setValue(newValue, forKey: "lastSelectedRangeIndex")
        }
        get {
            integer(forKey: "lastSelectedRangeIndex")
        }
    }
    
    func getLastSelectedRangeIndex(rangeCount:Int)->Int {
        if lastSelectedRangeIndex < rangeCount {
            return lastSelectedRangeIndex
        }
        return 0
    }
}

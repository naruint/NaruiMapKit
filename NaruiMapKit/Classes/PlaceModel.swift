//
//  PlaceModel.swift
//  NaruiMapKit
//
//  Created by Changyeol Seo on 2020/11/06.
//

import Foundation
import CoreLocation

extension NaruMapApiManager {
    public struct Document : Codable {
        let id:String
        let distance:String
        let road_address_name:String
        let x:String
        let y:String
        let phone:String
        let address_name:String
        let category_group_code:String
        let place_name:String
        let place_url:String
        let category_group_name:String
        let category_name:String
        
        var coordinate:CLLocationCoordinate2D {
            let lat = NSString(string:y).doubleValue
            let long = NSString(string:x).doubleValue
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
        
        var location : CLLocation {
            let lat = NSString(string:y).doubleValue
            let long = NSString(string:x).doubleValue
            return CLLocation(latitude: lat, longitude: long)
        }
        
        func getDistance(from:CLLocation? = nil)->CLLocationDistance? {
            let from = from ?? LocationManager.shared.myLocation.last
            return from?.distance(from: location)
        }
    }

    public struct SameName : Codable {
        let selected_region: String
        let region:[String]
        let keyword:String
    }

    public struct MetaData : Codable {
        let is_end:Bool
        let pageable_count:Int
        let total_count:Int
        let same_name:SameName
    }
    
    public struct ViewModel : Codable {
        let documents:[Document]
        let meta:MetaData
        public static func makeModel(string:String)->ViewModel? {
            do {
                if let data = string.data(using: .utf8) {
                    return try JSONDecoder().decode(
                        ViewModel.self, from: data)
                }
            } catch {
                print("error : \(error.localizedDescription) : \(string)")
            }
            return nil
        }
    }
    
}

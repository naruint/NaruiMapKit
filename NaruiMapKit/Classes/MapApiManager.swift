//
//  MapApiManager.swift
//  naver map api test
//
//  Created by Changyeol Seo on 2020/09/25.
//

import Foundation
import Alamofire
import CoreLocation

public class NaruMapApiManager {
    let apikey:String
    public init(apiKey:String) {
        self.apikey = apiKey
    }
    
    private let keyId = "93z75sc89q"
//    private let key = "PCzBfiKEeZGlKBfIJOjmlIH8iP5YDEuaUqu4lddx"
    
    private var page:Int = 1 {
        didSet {
            if page == 1 {
                result.removeAll()
            }
        }
    }
    private var result:[String] = []

    public func get(query:String, radius:Int ,complete:@escaping(_ result:ViewModel?)->Void)  {
        let apiKey = self.apikey
        func request(locations:[CLLocation]) {
            let s = self
            Alamofire.request("https://dapi.kakao.com/v2/local/search/keyword.json",
                              method: .get,
                              parameters: [
                                "x":locations.first?.coordinate.longitude ?? 0.0,
                                "y":locations.first?.coordinate.latitude  ?? 0.0,
                                "radius":radius,
                                "page":s.page,
                                "size":10,
                                "sort":"accuracy",
                                "query":query,
                              ], headers: ["Authorization":"KakaoAK \(apiKey)"])
                .responseJSON {(response) in
                    guard let data = response.data else {
                        return
                    }
                    if let str = String(data: data, encoding: .utf8) {
                        if let result = ViewModel.makeModel(string: str) {
                            complete(result)
                            return
                        }
                    }
                    complete(nil)
                }
        }
        
        if LocationManager.shared.myLocation.count == 0 {
            LocationManager.shared.requestAuth { (status) in
                print(status ?? "")
            } getLocation: { (locations) in
                print(locations)
                request(locations:locations)                
            }
        } else {
            request(locations:LocationManager.shared.myLocation)
        }

      
        
    }
    
}

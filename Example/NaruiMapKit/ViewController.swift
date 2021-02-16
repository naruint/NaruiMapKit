//
//  ViewController.swift
//  NaruiMapKit
//
//  Created by 서창열 on 11/06/2020.
//  Copyright (c) 2020 서창열. All rights reserved.
//

import UIKit
import NaruiMapKit
import CoreLocation

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NaruMapApiManager.shared.apikey = "78d4a28c8001ec71019d268aaf039d82"
    }
    
    @IBAction func onTouchupBtn(_ sender: Any) {
        let radius = 2000
        let vc = NaruMapViewController.viewController
        vc.ranges = [
            .init(range: 500, title: "500m"),
            .init(range: 1000, title: "1km"),
            .init(range: 5000, title: "5km"),
            .init(range: 10000, title: "10km")
        ]
        
        vc.altitude = CLLocationDistance(radius)
        vc.emptyViewImage = UIImage(named: "03IconEtcChallengeNormalComplete")
        vc.hidesBottomBarWhenPushed = true
        
        navigationController?.pushViewController(vc, animated: true)
         
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}


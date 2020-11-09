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

    let mapApiManager = NaruMapApiManager(apiKey:"78d4a28c8001ec71019d268aaf039d82")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    @IBAction func onTouchupBtn(_ sender: Any) {
        let radius = 2000
        mapApiManager.get(query: "병원", radius: radius) { (result) in
            let vc = NaruMapViewController.viewController
            vc.viewModel = result
            vc.altitude = CLLocationDistance(radius * 2)
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}


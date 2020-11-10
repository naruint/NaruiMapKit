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
        // Do any additional setup after loading the view, typically from a nib.
        NaruMapApiManager.shared.apikey = "78d4a28c8001ec71019d268aaf039d82"
        
    }
    @IBAction func onTouchupBtn(_ sender: Any) {
        let radius = 2000
        let vc = NaruMapViewController.viewController
        vc.altitude = CLLocationDistance(radius)
        self.present(vc, animated: true, completion: nil)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}


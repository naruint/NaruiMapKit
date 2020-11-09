//
//  ViewController.swift
//  NaruiMapKit
//
//  Created by 서창열 on 11/06/2020.
//  Copyright (c) 2020 서창열. All rights reserved.
//

import UIKit
import NaruiMapKit

class ViewController: UIViewController {

    let mapApiManager = NaruMapApiManager(apiKey:"78d4a28c8001ec71019d268aaf039d82")
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapApiManager.get(query: "병원", radius: 1000) { (result) in
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}


//
//  ViewController.swift
//  RoboHash
//
//  Created by Navin  Dev on 17/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let dataBase = RoboHashDataBase.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let history = SearchHistory(name: "Booo", date: Date(), image: UIImage(named: "navin.png"))
        try? dataBase.save(history)
        try? dataBase.fetchAll().map { print($0.name) }
        
        // Do any additional setup after loading the view.
    }
    
    
}


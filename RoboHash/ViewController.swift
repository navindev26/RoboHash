//
//  ViewController.swift
//  RoboHash
//
//  Created by Navin  Dev on 17/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import UIKit
import Alamofire
import ReactiveSwift
import DifferenceKit

class ViewController: UIViewController {
    let dataBase = RoboHashDataBase.shared

    @IBOutlet var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let history = SearchHistory(name: "Booo", date: Date(), image: UIImage(named: "navin.png"))
        try? dataBase.save(history)
        try? dataBase.fetchAll().map { print($0.name) }
        let endpoint = RoboHashAPI.avatar(hash: "/3242343/234234/234234234")
        let robohask = RoboHashNetworkService()
        robohask.makeRequest(endpoint).observe(on: UIScheduler()).on( failed: { error in
            print(error)
        }, value: { [weak self] (source) in
            self?.imageView.image = source.image
            print(source.name)
        }).start()
    }
}


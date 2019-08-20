//
//  Repository.swift
//  RoboHash
//
//  Created by Navin  Dev on 20/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import Foundation
import ReactiveSwift

class Repository {
    let dataBase = RoboHashDataBase.shared
    
    func totalCount() -> Int? {
        do {
            return try dataBase.totalCount()
        } catch {
            print(error)
            return nil
        }
    }

    func fetchAndCacheAvatar(forHash hash: String) -> SignalProducer<SearchHistory, NetworkError> {
        let endpoint = RoboHashAPI.avatar(hash: hash)
        return RoboHashNetworkService().makeRequest(endpoint).on(value: { [weak self] (history) in
            try? self?.dataBase.save(history)
        })
    }
}

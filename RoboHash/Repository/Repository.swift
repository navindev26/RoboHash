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
    let service = RoboHashNetworkService()
    
    func totalCount() ->  SignalProducer<Int, RoboHashError> {
        return SignalProducer { [weak self] (observer, lifetime) in
            guard let `self` = self else { return }
            do {
                let totalCount = try self.dataBase.totalCount()
                observer.send(value: totalCount)
            } catch {
                observer.send(error: .dataFetchError)
            }
        }
    }

    func fetchAllSearchHistory() -> SignalProducer<[SearchHistory], RoboHashError> {
        return SignalProducer {  [weak self] (observer, _) in
            guard let `self` = self else { return }
            do {
                let histroy = try self.dataBase.fetchAll()
                observer.send(value: histroy)
            } catch {
                observer.send(error: .dataFetchError)
            }
        }
    }

    func fetchAndCacheAvatar(forHash hash: String) -> SignalProducer<SearchHistory, RoboHashError> {
        let endpoint = RoboHashAPI.avatar(hash: hash)
        return SignalProducer {  [weak self] (observer, _) in
            guard let `self` = self else { return }
            self.service.makeRequest(endpoint).observe(on: UIScheduler()).on(event: { event in
                switch event {
                case .value(let value):
                    do {
                        try self.dataBase.save(value)
                        observer.send(value: value)// we try saving to DB else pass the error
                        observer.sendCompleted()
                    } catch {
                        observer.send(error: .dataFetchError)
                    }
                case .failed(let error):
                    observer.send(error: error)
                default:
                    observer.send(error: RoboHashError.genericError)
                }
            }).start()
        }
    }
}



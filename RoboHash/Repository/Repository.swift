//
//  Repository.swift
//  RoboHash
//
//  Created by Navin  Dev on 20/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import Foundation
import ReactiveSwift

protocol RepositoryRepresentable: class { 
    var database: RoboHashDataBase { get }
    var service: RoboHashNetworkService { get }
    func totalCount() ->  SignalProducer<Int, RoboHashError>
    func fetchAndCacheAvatar(forHash hash: String) -> SignalProducer<SearchHistory, RoboHashError>
}

extension RepositoryRepresentable {

    func fetchAllSearchHistory() -> SignalProducer<[SearchHistory], RoboHashError> {
        return SignalProducer {  [weak self] (observer, _) in
            guard let `self` = self else { return }
            do {
                let history = try self.database.fetchAll()
                observer.send(value: history)
            } catch {
                observer.send(error: .dataFetchError)
            }
        }
    }

    func totalCount() ->  SignalProducer<Int, RoboHashError> {
        return SignalProducer { [weak self] (observer, lifetime) in
            guard let `self` = self else { return }
            do {
                let totalCount = try self.database.totalCount()
                observer.send(value: totalCount)
            } catch {
                observer.send(error: .dataFetchError)
            }
        }
    }

    func fetchAndCacheAvatar(forHash hash: String) -> SignalProducer<SearchHistory, RoboHashError> {
        let endpoint = RoboHashAPI.avatar(hash: hash)
        return SignalProducer {  [weak self] (observer, lifetime) in
            guard let `self` = self else { return }
            guard !lifetime.hasEnded else {
                observer.sendInterrupted()
                return
            }
            self.service.makeRequest(endpoint).observe(on: UIScheduler()).on(event: { event in
                switch event {
                case .value(let value):
                    do {
                        try self.database.save(value)
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

class Repository: RepositoryRepresentable {
    let database: RoboHashDataBase
    let service = RoboHashNetworkService()

    init() {
        guard let database = RoboHashDataBase.shared else {
            fatalError()
        }
        self.database = database
    }
}

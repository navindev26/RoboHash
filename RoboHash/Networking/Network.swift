//
//  Network.swift
//  RoboHash
//
//  Created by Navin  Dev on 18/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import Foundation
import ReactiveSwift
import Alamofire
import UIKit


enum RoboHashError: Error {
    case noInternet
    case responseError
    case requestError
    case genericError
    case dataFetchError
    case dataSaveError
    case databaseError
    
    var localizedDescription: String {
        switch self {
        case .noInternet:
            return "There seems to be no network connectivity"
        default:
            return "Uh oh, something went wrong"
        }
    }
    
}

protocol ResponseDataSerializable {
    init?(httpResponse: HTTPURLResponse?, data: Data?)
}

protocol NetworkService {
    associatedtype Response
    func makeRequest(_ endpoint: Endpoint) -> SignalProducer<Response, RoboHashError>
}

class RoboHashNetworkService: NetworkService {
    typealias Response = SearchHistory
    func makeRequest(_ endpoint: Endpoint) -> SignalProducer<Response, RoboHashError> {
        return requestSignalProducer(endpoint)
    }
}

extension NetworkService {
    func requestSignalProducer<T:ResponseDataSerializable>(_ endpoint: Endpoint) -> SignalProducer<T, RoboHashError> {
        return SignalProducer { (observer, lifetime) in
            guard !lifetime.hasEnded else {
                observer.sendInterrupted()
                return
            }
            guard let request = endpoint.request else {
                observer.send(error: .requestError)
                return
            }
            Alamofire.request(request).responseData { (dataResponse) in
                switch dataResponse.result {
                case .success(let data):
                    guard let value =  T(httpResponse: dataResponse.response, data: data) else {
                        observer.send(error: .responseError)
                        return
                    }
                    observer.send(value:value)
                case .failure(let error):
                    if let err = error as? URLError, err.code  == URLError.Code.notConnectedToInternet {
                        observer.send(error: .noInternet)
                    } else {
                        observer.send(error: .genericError)
                    }
                }
            }
        }
    }
}

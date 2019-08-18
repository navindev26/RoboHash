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


enum NetworkError: Error {
    case noInternet
    case responseError
    case requestError
    case genericError
}

protocol ResponseDataSerializable {
     init?(httpResponse: HTTPURLResponse?, data: Data?)
}

protocol NetworkService {
    associatedtype ResponseData: ResponseDataSerializable
    func makeRequest(_ endpoint: Endpoint) -> SignalProducer<ResponseData, NetworkError>
}

extension NetworkService {
    func requestSignalProducer<T>(_ endpoint: Endpoint) -> SignalProducer<T, NetworkError> where T : ResponseDataSerializable {
        return SignalProducer { (observer, _) in
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
                case .failure:
                    observer.send(error: .genericError)
                }
            }
        }
    }
}

class RoboHashNetworkService: NetworkService {
    func makeRequest(_ endpoint: Endpoint) -> SignalProducer<SearchHistory, NetworkError>  {
        return requestSignalProducer(endpoint)
    }
}

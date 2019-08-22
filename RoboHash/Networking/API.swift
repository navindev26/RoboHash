//
//  API.swift
//  RoboHash
//
//  Created by Navin  Dev on 18/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import Foundation
import Alamofire

protocol Endpoint {
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
}

extension Endpoint {
    
    var url: URL?  {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        return try? components.asURL()
    }
    
    var request: URLRequest? {
        guard let url = self.url else { return nil }
        return URLRequest(url: url)
    }
}

enum RoboHashAPI {
    static let scheme = "https"
    static let host = "www.robohash.org"
    
    case avatar(hash: String)
}

extension RoboHashAPI: Endpoint {
    
    var scheme: String {
        return RoboHashAPI.scheme
    }
    
    var host: String {
        return RoboHashAPI.host
    }
    
    var path: String {
        switch self {
        case .avatar(let hash):
            return ("/\(hash)")
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
}

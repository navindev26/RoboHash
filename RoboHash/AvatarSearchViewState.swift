//
//  AvatarSearchViewState.swift
//  RoboHash
//
//  Created by Navin  Dev on 20/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import UIKit

enum AvatarSearchViewState {
   case loading(String)
   case success(SearchHistory)
   case error

    var image: UIImage? {
        switch self {
        case .success(let model):
            return model.image
        default:
            return nil
        }
    }

    var text: String {
        switch self {
        case .loading(let text):
            return text
        case .success(let model):
            return model.name
        case .error:
            return ""
        }
    }

    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
}

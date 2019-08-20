//
//  AvatarSearchViewState.swift
//  RoboHash
//
//  Created by Navin  Dev on 20/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import UIKit

enum AvatarSearchViewState {
   case loading(String, history: String) // SearchHistory count
   case success(SearchHistory, history: String)
   case error(history: String)

    var image: UIImage? {
        switch self {
        case .success(let model,_):
            return model.image
        default:
            return nil
        }
    }

    var text: String {
        switch self {
        case .loading(let text, _):
            return text
        case .success(let model, _):
            return model.name
        case .error:
            return ""
        }
    }

    var history: String {
        switch self {
        case .success(_, let history), .error(let history),.loading(_, let history):
            return history
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

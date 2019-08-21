//
//  SearchHistoryViewState.swift
//  RoboHash
//
//  Created by Navin  Dev on 21/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import UIKit

enum SearchHistoryViewState {
    case loading(SearchHistoryTableViewState)
    case empty(SearchHistoryTableViewState)
    case error(SearchHistoryTableViewState)
    case success(SearchHistoryTableViewState)

    var tableViewState: SearchHistoryTableViewState {
        switch self {
        case .loading(let tableViewState), .empty(let tableViewState),
             .error(let tableViewState),.success(let tableViewState):
            return tableViewState
        }
    }
}

struct SearchHistoryTableViewState {
    var sections: [Section]
    static let empty = SearchHistoryTableViewState(sections: [])
}

struct Section {
    var rows: [Row]
}

struct Row {
    var name: String
    var image: UIImage?
    var date: String
}



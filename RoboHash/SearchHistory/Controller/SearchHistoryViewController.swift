//
//  SearchHistoryViewController.swift
//  RoboHash
//
//  Created by Navin  Dev on 21/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import UIKit
import ReactiveSwift

class SearchHistoryViewController: UIViewController  {
    let repository = Repository()
    
    var searchHistoryView: SearchHistoryView? {
        return self.view as? SearchHistoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        repository.fetchAllSearchHistory().observe(on: UIScheduler()).on(event: { event in
            switch event {
            case .value(let history):
                let rows = history.map({ (history) -> Row in
                    Row(name: history.name, image: history.image, date: SharedDateformatter.shared.displayDateFormat.string(from: history.date))
                })
                guard !rows.isEmpty else {
                    self.searchHistoryView?.viewState = .empty(.empty)
                    return
                }
                let section = Section(rows: rows)
                self.searchHistoryView?.viewState = .success(SearchHistoryTableViewState(sections: [section]))
            case .failed(let error):
                self.searchHistoryView?.viewState = .error(.empty)
                self.showGenericError(title: error.localizedDescription)
            default:
                self.searchHistoryView?.viewState = .success(.empty)
            }
        }).start()
    }
    
}

//
//  SearchHistoryView.swift
//  RoboHash
//
//  Created by Navin  Dev on 21/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import UIKit

class SearchHistoryView: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!

    lazy var backgroundView: UILabel = {
        let label = UILabel()
        label.frame = tableView.bounds
        label.text = "You have no search history"
        label.textColor = .darkGray
        label.textAlignment = .center
        return label
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        tableView.tableFooterView = UIView()
    }

    var viewState =  SearchHistoryViewState.success(.empty) {
        didSet {
            update()
        }
    }

    // MARK: UITableView Datasource

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewState.tableViewState.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewState.tableViewState.sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryCell", for: indexPath)
        let rowModel = viewState.tableViewState.sections[indexPath.section].rows[indexPath.row]
        cell.imageView?.image = rowModel.image
        cell.textLabel?.text = rowModel.name
        cell.detailTextLabel?.text = rowModel.date
        return cell
    }

    private func update() {
        switch viewState {
        case .empty:
            tableView.backgroundView = backgroundView
        default:
            tableView.backgroundView = nil
        }
        tableView.reloadData()
    }
}

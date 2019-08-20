//
//  AvatarSearchView.swift
//  RoboHash
//
//  Created by Navin  Dev on 20/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import UIKit

protocol AvatarSearchViewDelegate: class {
    func view(view:AvatarSearchView, didPerformAction action: AvatarSearchView.Action)
}

class AvatarSearchView: UIView {
    enum Action {
        case textDidChange(String?)
    }
    @IBOutlet var searchTextField: UITextField!
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var searchHistory: UIBarButtonItem!
    weak var delegate: AvatarSearchViewDelegate?
    var viewState: AvatarSearchViewState? {
        didSet {
            update()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        searchTextField.addTarget(self, action: #selector(searchFieldDidChange(_:)), for: .editingChanged)
        searchTextField.placeholder = "type any name and find an avatar"
    }

    private func update() {
        guard let state = viewState else { return }
        searchTextField.text = state.text
        searchHistory.title = state.history
        avatarImageView.image = state.image
        state.isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }

    @objc func searchFieldDidChange(_ sender: UITextField) {
        delegate?.view(view: self, didPerformAction: .textDidChange(sender.text))
    }
}

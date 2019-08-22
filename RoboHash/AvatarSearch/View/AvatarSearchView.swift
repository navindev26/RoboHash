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

class AvatarSearchView: UIView, UITextFieldDelegate {
    enum Action {
        case textDidChange(String?)
        case didTapOnView
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
    }
    
    private func update() {
        guard let state = viewState else { return }
        searchTextField.text = state.text
        searchHistory.title = state.history
        avatarImageView.image = state.image
        state.isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    // MARK: Tapgesture Target
    
    @IBAction func didTapOnView(_ sender: UITapGestureRecognizer) {
        delegate?.view(view: self, didPerformAction: .didTapOnView)
    }
    
    // MARK: SearchTextField
    
    
    
    @objc func searchFieldDidChange(_ sender: UITextField) {
        delegate?.view(view: self, didPerformAction: .textDidChange(sender.text))
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return !(string.containsWhitespace)
    }
}

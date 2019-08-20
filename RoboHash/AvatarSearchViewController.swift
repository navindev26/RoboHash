//
//  ViewController.swift
//  RoboHash
//
//  Created by Navin  Dev on 17/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import UIKit
import Alamofire
import ReactiveCocoa
import ReactiveSwift
import DifferenceKit

class AvatarSearchViewController: UIViewController, AvatarSearchViewDelegate {

    let repository = Repository()
    var avatarSearchView: AvatarSearchView? {
        return self.view as? AvatarSearchView
    }
    private var textInput = MutableProperty<String?>(nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        avatarSearchView?.delegate = self

        let resultSignal = textInput.producer.debounce(0.5, on: QueueScheduler.main).flatMap(.latest) { [weak self] (query: String?) -> SignalProducer<SearchHistory, NetworkError> in
            guard let `self` = self, let hash = query  else { return SignalProducer.empty }
            self.avatarSearchView?.viewState = .loading(hash)
            return self.repository.fetchAvatar(forHash: hash)
        }
        resultSignal.observe(on:  UIScheduler()).on(event: { [weak self] (event) in
            guard let `self` = self else { return }
            switch event {
            case .value(let history):
                self.avatarSearchView?.viewState = .success(history)
            case .failed:
                self.avatarSearchView?.viewState = .error
            case .completed, .interrupted:
                self.avatarSearchView?.viewState = .error
            }
        }).start()
    }

    func view(view: AvatarSearchView, didPerformAction action: AvatarSearchView.Action) {
        switch action {
        case .textDidChange(let text):
            textInput.value = text
        }
    }
}

extension String {
    var containsWhitespace : Bool {
        return(self.rangeOfCharacter(from: .whitespacesAndNewlines) != nil)
    }
}


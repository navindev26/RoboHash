//
//  ViewController.swift
//  RoboHash
//
//  Created by Navin  Dev on 17/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import UIKit
import Alamofire
import ReactiveSwift
import DifferenceKit


class AvatarSearchViewController: UIViewController, AvatarSearchViewDelegate {
    var repository: RepositoryRepresentable = Repository()
    var avatarSearchView: AvatarSearchView? {
        return self.view as? AvatarSearchView
    }
    private var textInput = MutableProperty<String?>(nil)
    private var fetchAvatarSignal: SignalProducer<SearchHistory, RoboHashError>?
    private var inProgressSignal: Disposable?
    private var searchHistoryCount: Int = 0
    private var searchHistoryString: String {
        return "History(\(self.searchHistoryCount))"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        avatarSearchView?.delegate = self
        setupSignals()
        self.fetchHistoryCount { _ in
            self.avatarSearchView?.viewState = .success(SearchHistory.empty, history: self.searchHistoryString)
        }
    }

    private func setupSignals() {
        fetchAvatarSignal = textInput.producer.debounce(1.0, on: QueueScheduler.main).flatMap(.latest) { [weak self] (query: String?) -> SignalProducer<SearchHistory, RoboHashError> in
            guard let `self` = self else { return SignalProducer.empty }
            guard let hash = query else {
                self.avatarSearchView?.viewState = .success(SearchHistory.empty, history: self.searchHistoryString)
                return SignalProducer.empty
            }
            self.avatarSearchView?.viewState = .loading(hash, history: self.searchHistoryString)
            return self.repository.fetchAndCacheAvatar(forHash: hash)
        }
    }



    private func observeForChanges() {
        guard let signal = fetchAvatarSignal else {
            return
        }
        inProgressSignal?.dispose()
        inProgressSignal = signal.observe(on: UIScheduler()).on(event: { [weak self] (event) in
            guard let `self` = self else { return }
            switch event {
            case .value(let model):
                // Update the search history count
                self.fetchHistoryCount { _ in
                    self.avatarSearchView?.viewState = .success(model, history: self.searchHistoryString)
                    self.avatarSearchView?.searchTextField.resignFirstResponder()
                }
            case .failed(let error):
                self.avatarSearchView?.viewState = .error(history: "")
                self.showGenericError(title: error.localizedDescription)
            default:
                break
            }
        }).start()
    }

    private func fetchHistoryCount(completion: ((Int) -> Void)? = nil) {
        repository.totalCount().observe(on: UIScheduler()).on(event: { [weak self] (event) in
            guard let `self` = self else { return }
            switch event {
            case .value(let value):
                self.searchHistoryCount = value
                completion?(value)
            default:
                self.showGenericError(title: "Error fetching search history")
                self.searchHistoryCount = 0
                completion?(0)
            }
        }).start()
    }

    // MARK: AvatarSearchViewDelegate

    func view(view: AvatarSearchView, didPerformAction action: AvatarSearchView.Action) {
        switch action {
        case .textDidChange(let text):
            guard !(text?.isEmpty ?? true) else {
                textInput.value = nil
                return
            }
            textInput.value = text
            observeForChanges()
        case .didTapOnView:
            self.avatarSearchView?.searchTextField.resignFirstResponder()
        }
    }
}

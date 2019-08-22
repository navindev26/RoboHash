//
//  RoboHashDataBase.swift
//  RoboHash
//
//  Created by Navin  Dev on 17/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol DataBase {
    associatedtype Model
    var coreDataStack: CoreDataStack? { get }
    func totalCount() throws -> Int
    func fetchAll() throws -> [Model]
    func save(_ object: Model) throws
}

final class RoboHashDataBase: DataBase {

    var coreDataStack: CoreDataStack?
    static let shared = RoboHashDataBase(coreDataStack: CoreDataStack.prodStack())
    typealias Model = SearchHistory
    
    init?(coreDataStack: CoreDataStack?) {
        guard let coredataStack = coreDataStack else { return nil }
        self.coreDataStack = coredataStack
    }
    
    func fetchAll() throws -> [SearchHistory] {
        let request: NSFetchRequest<CDSearchHistory> = CDSearchHistory.sortedFetchRequest
        guard let result = try coreDataStack?.mainContext?.fetch(request) else {
            throw RoboHashError.dataFetchError
        }
        return result.compactMap { SearchHistory(from: $0) }
    }

    func totalCount() throws -> Int {
        let request: NSFetchRequest<CDSearchHistory> = CDSearchHistory.sortedFetchRequest
        guard let result = try coreDataStack?.mainContext?.count(for: request) else {
            throw RoboHashError.dataFetchError
        }
        return result
    }
    
    func save(_ object: SearchHistory) throws {
        guard let context = coreDataStack?.mainContext else {
            throw RoboHashError.dataSaveError
        }
        let cdModel = CDSearchHistory.createObject(from: object, in: context)
        context.insert(cdModel)
        try coreDataStack?.save()
    }
}

protocol SearchHistoryModel: ResponseDataSerializable {
    var name: String { get }
    var date: Date { get }
    var image: UIImage? { get }
    init?(httpResponse: HTTPURLResponse?, data: Data?)
}

struct SearchHistory: SearchHistoryModel {
    var name: String
    var date: Date
    var image: UIImage?
    
    init(name: String, date: Date, image: UIImage?) {
        self.name = name
        self.date = date
        self.image = image
    }
    
    init?(from model: CDSearchHistory) {
        guard let name = model.name else { return nil }
        guard let searchDate = model.date else { return nil }
        guard let imageData = model.image else { return nil }
        self.name = name
        self.date = searchDate
        self.image = UIImage(data: imageData)
    }

    init?(httpResponse: HTTPURLResponse?, data: Data?) {
        guard let components = httpResponse?.url?.pathComponents else { return nil }
        guard let dateString = httpResponse?.allHeaderFields["Date"] as? String else { return nil }
        guard let imageData = data else { return nil }
        guard let date = SharedDateformatter.shared.requestDateFormat.date(from: dateString) else { return nil }
        self.date = date
        self.name = components.dropFirst().joined(separator: "") // we remove the occurence of "/"
        self.image = UIImage(data: imageData)
    }

    static var empty: SearchHistory {
        return SearchHistory(name: "", date: Date(), image: nil)
    }
}

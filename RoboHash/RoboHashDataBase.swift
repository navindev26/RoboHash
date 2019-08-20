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

    typealias Model = SearchHistory
    var coreDataStack: CoreDataStack?
    static let shared = RoboHashDataBase()
    
    init() {
        do {
            coreDataStack = try CoreDataStack.setup(withModelName: "RoboHash", storeName: "RoboHash")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchAll() throws -> [SearchHistory] {
        let request: NSFetchRequest<CDSearchHistory> = CDSearchHistory.sortedFetchRequest
        guard let result = try coreDataStack?.mainContext?.fetch(request) else {
            throw CoreDataStackError.fetchError
        }
        return result.map { SearchHistory(from: $0) }
    }

    func totalCount() throws -> Int {
        let request: NSFetchRequest<CDSearchHistory> = CDSearchHistory.sortedFetchRequest
        guard let result = try coreDataStack?.mainContext?.count(for: request) else {
            throw CoreDataStackError.fetchError
        }
        return result
    }
    
    func save(_ object: SearchHistory) throws {
        guard let context = coreDataStack?.mainContext else {
            throw CoreDataStackError.contextSaveError
        }
        let cdModel = CDSearchHistory.createObject(from: object, in: context)
        context.insert(cdModel)
        try coreDataStack?.save()
    }
}

struct SearchHistory {
    var name: String
    var date: Date?
    var image: UIImage?
    
    init(name: String, date: Date?, image: UIImage?) {
        self.name = name
        self.date = date
        self.image = image
    }
    
    init(from model: CDSearchHistory) {
        name = model.name ?? ""
        date = model.date
        if let imageData = model.image {
             self.image = UIImage(data: imageData)
        }
    }

    static var empty: SearchHistory {
        return SearchHistory(name: "", date: nil, image: nil)
    }
}

extension SearchHistory: ResponseDataSerializable {

    init?(httpResponse: HTTPURLResponse?, data: Data?) {
        guard let components = httpResponse?.url?.pathComponents else { return nil }
        guard let dateString = httpResponse?.allHeaderFields["Date"] as? String else { return nil }
        guard let imageData = data else { return nil }
        self.date = SharedDateformatter.shared.dateFormat.date(from: dateString)
        self.name = components.dropFirst().joined(separator: "") // we remove the occurence of "/"
        self.image = UIImage(data: imageData)
    }
}

// Helper Singleton to avoid setting the format everytime

class SharedDateformatter {
    static let shared = SharedDateformatter()
    lazy var dateFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd LLL yyyy HH:mm:ss zzz"
        return dateFormatter
    }()
}

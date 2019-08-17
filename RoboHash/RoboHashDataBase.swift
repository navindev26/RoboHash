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
    func fetchAll() throws -> [Model]
    func save(_ object: Model) throws
}

final class RoboHashDataBase: DataBase {
    typealias Model = SearchHistory
    var coreDataStack: CoreDataStack?
    
    static let shared = RoboHashDataBase()
    
    init() {
        do {
            coreDataStack = try CoreDataStack.setup(modelName: "RoboHash", storeName: "RoboHash")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func fetchAll() throws -> [SearchHistory] {
        let request: NSFetchRequest<CDSearchHistory> = CDSearchHistory.sortedFetchRequest
        guard let result = try coreDataStack?.mainContext?.fetch(request) else {
            throw CoreDataStackError.contextSaveError
        }
        return result.map { SearchHistory(from: $0) }
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
    var name: String?
    var date: Date?
    var image: UIImage?
    
    init(name: String?, date: Date?, image: UIImage?) {
        self.name = name
        self.date = date
        self.image = image
    }
    
    init(from model: CDSearchHistory) {
        self.name = model.name
        self.date = model.date
        if let data = model.image {
            self.image = UIImage(data: data)
        }
    }
}

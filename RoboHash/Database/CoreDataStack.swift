//
//  CoreDataManager.swift
//  RoboHash
//
//  Created by Navin  Dev on 17/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataStack {
    
    var mainContext: NSManagedObjectContext?
    private var privateContext: NSManagedObjectContext?
    static let modelName = "RoboHash"
    static let storeName = "RoboHash"

    static func prodStack() -> CoreDataStack? {
        return try? CoreDataStack.setup(withModelName: modelName, storeName: storeName)
    }
    
    static func setup(withModelName modelName: String, storeName: String) throws -> CoreDataStack  {
        let stack = CoreDataStack()
        let model = try stack.setupModel(name: modelName)
        let persistentStoreCoordinator = try stack.setupPersistentStoreCoordinator(from: model, storeName: storeName)
        let privateContext = stack.setupPrivateContext(from: persistentStoreCoordinator)
        stack.privateContext = privateContext
        let mainContext = stack.setupMainContext(from: privateContext)
        stack.mainContext = mainContext
        return stack
    }
    
    private func setupMainContext(from parent :NSManagedObjectContext) -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = parent
        return managedObjectContext
    }
    
    private func setupPrivateContext(from coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }
    
    private func setupModel(name: String) throws -> NSManagedObjectModel  {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
            throw RoboHashError.databaseError
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            throw RoboHashError.databaseError
        }
        return managedObjectModel
    }
    
    private func setupPersistentStoreCoordinator(from model: NSManagedObjectModel, storeName: String) throws -> NSPersistentStoreCoordinator  {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let fileManager = FileManager.default
        let storeName = "\(storeName).sqlite"
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        let options = [ NSInferMappingModelAutomaticallyOption : true,
                        NSMigratePersistentStoresAutomaticallyOption : true]
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                              configurationName: nil,
                                                              at: persistentStoreURL,
                                                              options: options)
        } catch {
            throw RoboHashError.databaseError
        }
        return persistentStoreCoordinator
    }
}

extension CoreDataStack {
    
    func save() throws {
        guard let mainContext = mainContext, let privateContext = privateContext else {
            throw RoboHashError.dataSaveError
        }
        mainContext.perform {
            do {
                if mainContext.hasChanges {
                    try mainContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("\(saveError), \(saveError.localizedDescription)")
            }
            
            privateContext.perform {
                do {
                    if privateContext.hasChanges {
                        try privateContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    print("\(saveError), \(saveError.localizedDescription)")
                }
            }
        }
    }
}

extension CDSearchHistory {
    
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: "date", ascending: false)]
    }
    
    static var sortedFetchRequest: NSFetchRequest<CDSearchHistory> {
        let request: NSFetchRequest<CDSearchHistory> = CDSearchHistory.fetchRequest()
        request.sortDescriptors = CDSearchHistory.defaultSortDescriptors
        return request
    }
    
    static func createObject(from model: SearchHistoryModel, in context: NSManagedObjectContext) -> CDSearchHistory {
        let searchHistory = CDSearchHistory(context: context)
        searchHistory.name = model.name
        searchHistory.image = model.image?.pngData()
        searchHistory.date = model.date
        return searchHistory
    }
}

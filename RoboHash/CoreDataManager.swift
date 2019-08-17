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

protocol CoreDataManager: class {
    var mainContext: NSManagedObjectContext { get }
    var privateContext: NSManagedObjectContext { get }
}

extension CoreDataManager {

    static func setupCoreDataStack(modelName: String, storeName: String) throws -> (mainContext: NSManagedObjectContext, privateContext: NSManagedObjectContext) {
        let model = try setupModel(name: modelName)
        let persistentStoreCoordinator = try setupPersistentStoreCoordinator(from: model, storeName: storeName)
        let privateContext = setupPrivateContext(from: persistentStoreCoordinator)
        let mainContext = setupMainContext(from: privateContext)
        return (mainContext: mainContext, privateContext: privateContext)
    }

    private static func setupMainContext(from parent :NSManagedObjectContext) -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.parent = parent
        return managedObjectContext
    }

    private static func setupPrivateContext(from coordinator: NSPersistentStoreCoordinator) -> NSManagedObjectContext {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }

    private static func setupModel(name: String) throws -> NSManagedObjectModel  {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
            throw CoreDataManagerError.stackSetupError
        }
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
             throw CoreDataManagerError.stackSetupError
        }
        return managedObjectModel
    }

    private static func setupPersistentStoreCoordinator(from model: NSManagedObjectModel, storeName: String) throws -> NSPersistentStoreCoordinator  {
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
            throw CoreDataManagerError.stackSetupError
        }

        return persistentStoreCoordinator
    }

    func save() throws {
        mainContext.perform {
            do {
                if self.mainContext.hasChanges {
                    try self.mainContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("\(saveError), \(saveError.localizedDescription)")
            }

            self.privateContext.perform {
                do {
                    if self.privateContext.hasChanges {
                        try self.privateContext.save()
                    }
                } catch {
                    let saveError = error as NSError
                    print("\(saveError), \(saveError.localizedDescription)")
                }
            }
        }
    }
}

enum CoreDataManagerError: Error {
    // can extend this to add in more error types
    case stackSetupError
    case contextSaveError
}

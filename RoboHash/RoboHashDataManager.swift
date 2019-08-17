//
//  RoboHashDataManager.swift
//  RoboHash
//
//  Created by Navin  Dev on 17/8/19.
//  Copyright © 2019 Navin  Dev. All rights reserved.
//

import Foundation
import CoreData

final class RoboHashDataManager: CoreDataManager {
    var mainContext: NSManagedObjectContext
    var privateContext: NSManagedObjectContext

    static let sharedManager = try? RoboHashDataManager()

    init() throws {
        let contexts = try RoboHashDataManager.setupCoreDataStack(modelName: "RoboHash", storeName: "RoboHash")
        mainContext = contexts.mainContext
        privateContext = contexts.privateContext
    }
}

//
//  PersistenceManager.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import os

public struct PersistenceManager {
    let modelName = "Grout"

    public static let shared = PersistenceManager()

    public static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PersistenceManager.self)
    )

    public static var preview: PersistenceManager = {
        let result = PersistenceManager(inMemory: true)
//        do {
//            try result.container.persistentStoreCoordinator.destroyPersistentStore(at: result.container.persistentStoreDescriptions.first!.url!, type: .sqlite, options: nil)
//        } catch {
//            if let error = error as NSError? {
//                Self.logger.error("\(#function): preview, \(error) \(error.userInfo)")
//            }
//        }
        return result
    }()

    public let container: NSPersistentCloudKitContainer

    public init(inMemory: Bool = false) {
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: modelName, withExtension: ".momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        container = NSPersistentCloudKitContainer(name: modelName, managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
//        let configs = container.managedObjectModel.configurations
//        ([String]) $R0 = 2 values {
//          [0] = "Archive"
//          [1] = "PF_DEFAULT_CONFIGURATION_NAME"
//        }
        
        if container.persistentStoreDescriptions.count < 2 {
            print(">>>>>> LOADING ARCHIVE STORE DESCRIPTION")
            let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
            let archiveStoreURL = defaultDirectoryURL.appendingPathComponent("GroutArchive.sqlite")
            let archiveStoreDescription = NSPersistentStoreDescription(url: archiveStoreURL)
            archiveStoreDescription.configuration = "Archive"
            archiveStoreDescription.isReadOnly = false
            archiveStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.org.openalloc.grout.archive")
            container.persistentStoreDescriptions.append(archiveStoreDescription)
        }
        
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                Self.logger.error("\(#function): loading persistent stores, \(error) \(error.userInfo)")
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    public func save(forced: Bool = false) {
        let ctx = container.viewContext
        if forced || ctx.hasChanges {
            do {
                Self.logger.notice("\(#function) saving context, forced=\(forced)")
                try ctx.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                if let error = error as NSError? {
                    Self.logger.error("\(#function): saving context, \(error) \(error.userInfo)")
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
    }
}

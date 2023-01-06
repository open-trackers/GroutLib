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
    static let modelName = "Grout"

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
//            Self.logger.error("\(#function): preview, \(error) \(error.userInfo)")
//        }
        return result
    }()

    public let container: NSPersistentCloudKitContainer

    public init(inMemory: Bool = false) {
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: PersistenceManager.modelName, withExtension: ".momd")!
        let model = NSManagedObjectModel(contentsOf: modelURL)!
        container = NSPersistentCloudKitContainer(name: PersistenceManager.modelName, managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

//        let configs = container.managedObjectModel.configurations
//        ([String]) $R0 = 2 values {
//          [0] = "Archive"
//          [1] = "PF_DEFAULT_CONFIGURATION_NAME"
//        }

//        #if os(iOS)
//            if container.persistentStoreDescriptions.count < 2 {
//                print(">>>>>> LOADING ARCHIVE STORE DESCRIPTION")
//                let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
//                let archiveStoreURL = defaultDirectoryURL.appendingPathComponent("GroutArchive.sqlite")
//                let archiveStoreDescription = NSPersistentStoreDescription(url: archiveStoreURL)
//                archiveStoreDescription.configuration = "Archive"
//                archiveStoreDescription.isReadOnly = false
//                archiveStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.org.openalloc.grout.archive")
//                container.persistentStoreDescriptions.append(archiveStoreDescription)
//            }
//        #endif

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

    /// Save context if changes pending, with optional force.
    public func save(forced: Bool = false) throws {
        let ctx = container.viewContext
        if forced || ctx.hasChanges {
            Self.logger.notice("\(#function) saving context, forced=\(forced)")
            try ctx.save()
        }
    }
}

//// For use with Xcode Previews, provides some data to work with for examples
// static var preview: StorageProvider = {
//
//    // Create an instance of the provider that runs in memory only
//    let storageProvider = StorageProvider(inMemory: true)
//
//    // Add a few test movies
//    let titles = [
//                "The Godfather",
//                "The Shawshank Redemption",
//                "Schindler's List",
//                "Raging Bull",
//                "Casablanca",
//                "Citizen Kane",
//                ]
//
//    for title in titles {
//        storageProvider.saveMovie(named: title)
//    }
//
//    // Now save these movies in the Core Data store
//    do {
//        try storageProvider.persistentContainer.viewContext.save()
//    } catch {
//        // Something went wrong 😭
//        print("Failed to save test movies: \(error)")
//    }
//
//    return storageProvider
// }()

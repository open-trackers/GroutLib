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

import Collections

// NOTE that we're using two stores with a single configuration,
// where the Z* records on 'main' store eventually will be transferred
// to the 'archive' store on iOS, to reduce watch storage needs.
public struct PersistenceManager {
    static let modelName = "Grout"
    static let cloudPrefix = "iCloud.org.openalloc.grout"
    static let archiveSuffix = "archive"
    static let baseName = "Grout"

    public enum StoreType: Hashable {
        case main
        case archive
    }

    public typealias StoresDict = OrderedDictionary<StoreType, NSPersistentStoreDescription>
    public static var stores = StoresDict()
    public static let shared = PersistenceManager()

    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                               category: String(describing: PersistenceManager.self))

    public let container: NSPersistentCloudKitContainer

    public init(inMemory: Bool = false) {
        container = PersistenceManager.getContainer(isCloud: true,
                                                    isTest: false,
                                                    inMemory: inMemory) as! NSPersistentCloudKitContainer
    }

    /// Save context if changes pending, with optional force.
    public func save(forced: Bool = false) throws {
        let ctx = container.viewContext
        if forced || ctx.hasChanges {
            Self.logger.notice("\(#function) saving context, forced=\(forced)")
            try ctx.save()
        }
    }

//    public static func getMainStore(_ context: NSManagedObjectContext) -> NSPersistentStore? {
//        PersistenceManager.getStore(context, .main)
//    }
//
    public static func getArchiveStore(_ context: NSManagedObjectContext) -> NSPersistentStore? {
        PersistenceManager.getStore(context, .archive)
    }

    public static var preview: PersistenceManager = .init(inMemory: true)

    // MARK: - Internal

    static func getStore(_ context: NSManagedObjectContext, _ storeType: StoreType) -> NSPersistentStore? {
        guard let url = PersistenceManager.stores[storeType]?.url,
              let psc = context.persistentStoreCoordinator,
              let store = psc.persistentStore(for: url)
        else {
            return nil
        }
        return store
    }

    static var model: NSManagedObjectModel {
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: PersistenceManager.modelName, withExtension: ".momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }

    static func getContainer(isCloud: Bool,
                             isTest: Bool,
                             inMemory: Bool) -> NSPersistentContainer
    {
        let container = isCloud
            ? NSPersistentCloudKitContainer(name: modelName, managedObjectModel: model)
            : NSPersistentContainer(name: modelName, managedObjectModel: model)

        stores[.main] = getStoreDescription(suffix: nil, isCloud: isCloud, isTest: isTest, inMemory: inMemory)

        #if !os(watchOS)
            // NOTE the watch won't get the archive store
            stores[.archive] = getStoreDescription(suffix: archiveSuffix, isCloud: isCloud, isTest: isTest)
        #endif

        container.persistentStoreDescriptions = stores.values.elements

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

        return container
    }

    static func getStoreDescription(suffix: String?,
                                    isCloud: Bool,
                                    isTest: Bool,
                                    inMemory: Bool = false) -> NSPersistentStoreDescription
    {
        let url: URL = {
            // NOTE used exclusively by preview; may need rethinking
            if inMemory {
                return URL(fileURLWithPath: "/dev/null")
            }

            let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
            let prefix = isTest ? "Test" : ""
            let netSuffix = suffix?.capitalized ?? ""
            let baseFileName = "\(prefix)\(baseName)\(netSuffix)"

            return defaultDirectoryURL.appendingPathComponent(baseFileName).appendingPathExtension("sqlite")
        }()

        let desc = NSPersistentStoreDescription(url: url)
        // desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

        if isCloud {
            let suffix2: String = {
                guard let name = suffix else { return "" }
                return ".\(name.lowercased())"
            }()
            let identifier = "\(cloudPrefix)\(suffix2)"
            desc.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: identifier)
        }

        return desc
    }

    static func getTestContainer() throws -> NSPersistentContainer {
        // NOTE: not using inMemory storage for testing, for two reasons:
        // (1) We're using two stores, where /dev/null may not be usable for both
        // (2) Batch delete may not be supported for inMemory

        let container = getContainer(isCloud: false, isTest: true, inMemory: false)

        // clear all data that persisted from earlier tests
        try container.managedObjectModel.entities.forEach {
            guard let name = $0.name else { return }
            try container.viewContext.deleter(entityName: name)
        }

        return container
    }
}

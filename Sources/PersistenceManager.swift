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

    #if os(watchOS)
        static let includeArchiveStore = false
    #else
        static let includeArchiveStore = true
    #endif

    public static let shared = PersistenceManager(withArchiveStore: includeArchiveStore)

    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: PersistenceManager.self)
    )

    public let container: NSPersistentCloudKitContainer

    public init(withArchiveStore: Bool = false, inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: PersistenceManager.modelName, managedObjectModel: PersistenceManager.model)

        container.persistentStoreDescriptions = [
            PersistenceManager.getDefaultStoreDescription(isCloud: true, isTest: false),
        ]

        // NOTE the watch won't get the archive store
        if withArchiveStore {
            container.persistentStoreDescriptions.append(
                PersistenceManager.getArchiveStoreDescription(isCloud: true, isTest: false)
            )
        }

        // NOTE used exclusively by preview; may need rethinking
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
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

    /// Save context if changes pending, with optional force.
    public func save(forced: Bool = false) throws {
        let ctx = container.viewContext
        if forced || ctx.hasChanges {
            Self.logger.notice("\(#function) saving context, forced=\(forced)")
            try ctx.save()
        }
    }

    static var model: NSManagedObjectModel {
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: PersistenceManager.modelName, withExtension: ".momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }

    // TODO: rethink this
    public static var preview: PersistenceManager = .init(inMemory: true)

    static func getDefaultStoreDescription(isCloud: Bool, isTest: Bool) -> NSPersistentStoreDescription {
        getStoreDescription(configurationName: nil, isCloud: isCloud, isTest: isTest)
    }

    static func getArchiveStoreDescription(isCloud: Bool, isTest: Bool) -> NSPersistentStoreDescription {
        getStoreDescription(configurationName: "Archive", isCloud: isCloud, isTest: isTest)
    }

    // specific nil configurationName for default configuration
    static func getStoreDescription(configurationName: String?, isCloud: Bool, isTest: Bool) -> NSPersistentStoreDescription {
        let defaultDirectoryURL = NSPersistentContainer.defaultDirectoryURL()
        let fileName = "\(isTest ? "Test" : "")Grout\(configurationName ?? "")"
        let archiveStoreURL = defaultDirectoryURL.appendingPathComponent(fileName).appendingPathExtension("sqlite")
        let desc = NSPersistentStoreDescription(url: archiveStoreURL)

        desc.configuration = configurationName // nil for default
//        desc.isReadOnly = false
//        desc.type = NSSQLiteStoreType
//        desc.shouldInferMappingModelAutomatically = true
//        desc.shouldMigrateStoreAutomatically = true
//        desc.shouldAddStoreAsynchronously = false
//        desc.setOption(true as NSNumber, forKey: NSSQLiteAnalyzeOption)
//        desc.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        if isCloud {
            let suffix: String = {
                guard let name = configurationName else { return "" }
                return ".\(name.lowercased())"
            }()
            let identifier = "iCloud.org.openalloc.grout\(suffix)"
            desc.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: identifier)
        }
        return desc
    }

    static func getTestContainer() throws -> NSPersistentContainer {
        // NOTE: not using inMemory storage for testing, for two reasons:
        // (1) We're using two stores, where /dev/null may not be usable for both
        // (2) Batch delete may not be supported for inMemory

        let container = NSPersistentContainer(name: PersistenceManager.modelName, managedObjectModel: model)

        container.persistentStoreDescriptions = [
            getDefaultStoreDescription(isCloud: false, isTest: true),
            getArchiveStoreDescription(isCloud: false, isTest: true),
        ]

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        // clear all data that persisted from earlier tests
        try container.managedObjectModel.entities.forEach {
            guard let name = $0.name else { return }
            try container.viewContext.deleter(entityName: name)
        }

        return container
    }
}

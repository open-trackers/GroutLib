//
//  CoreDataStack.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

// NOTE: needed to pass as .environmentObject
extension CoreDataStack: ObservableObject {}

// NOTE that we're using two stores with a single configuration,
// where the Z* records on 'main' store eventually will be transferred
// to the 'archive' store on iOS, to reduce watch storage needs.
public final class CoreDataStack: BaseCoreDataStack {
    static let modelName = "Grout"
    static let baseFileName = "Grout"
    static let cloudPrefix = "iCloud.org.openalloc.grout"
    // static let archiveSuffix = "archive"

    #if os(watchOS)
        // NOTE the watch won't get the archive store
        let storeKeys = [StoreType.main.rawValue]
    #else
        let storeKeys = [StoreType.main.rawValue, StoreType.archive.rawValue]
    #endif

    public init(isCloud: Bool, fileNamePrefix: String = "") {
        let cloudPrefix = isCloud ? CoreDataStack.cloudPrefix : nil

        super.init(modelName: CoreDataStack.modelName,
                   baseFileName: CoreDataStack.baseFileName,
                   cloudPrefix: cloudPrefix,
                   fileNamePrefix: fileNamePrefix,
                   storeKeys: storeKeys)
    }

    override public func loadModel(modelName: String) -> NSManagedObjectModel {
        let bundle = Bundle.module
        let modelURL = bundle.url(forResource: modelName, withExtension: ".momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }

    // for de-duping
    // NOTE that this is happening on background thread
    // NOTE handler is responsible for saving context
    override public func handleInsert(backgroundContext: NSManagedObjectContext,
                                      entityName: String,
                                      objectID: NSManagedObjectID,
                                      storeID: String)
    {
        logger.debug("handleInsert: name=\(entityName) uri=\(objectID.uriRepresentation().absoluteString.suffix(5)), storeID=\(storeID.suffix(5))")

        guard let mainStore = getMainStore(backgroundContext) else {
            logger.error("handleInsert: unable to get main store")
            return
        }

        #if !os(watchOS)
            guard let archiveStore = getArchiveStore(backgroundContext) else {
                logger.error("handleInsert: unable to get archive store")
                return
            }
        #endif

        let object = backgroundContext.object(with: objectID)

        do {
            switch entityName {
//            case AppSetting.entity().name:
//                try AppSetting.dedupe(backgroundContext)
//            case MFoodGroup.entity().name:
//                try MFoodGroup.dedupe(backgroundContext, object)
//            case MCategory.entity().name:
//                try MCategory.dedupe(backgroundContext, object)
//            case MServing.entity().name:
//                try MServing.dedupe(backgroundContext, object)
//            case ZCategory.entity().name:
//                try ZCategory.dedupe(backgroundContext, object, inStore: mainStore)
//                #if !os(watchOS)
//                    try ZCategory.dedupe(backgroundContext, object, inStore: archiveStore)
//                #endif
//            case ZServing.entity().name:
//                try ZServing.dedupe(backgroundContext, object, inStore: mainStore)
//                #if !os(watchOS)
//                    try ZServing.dedupe(backgroundContext, object, inStore: archiveStore)
//                #endif
//            case ZServingRun.entity().name:
//                try ZServingRun.dedupe(backgroundContext, object, inStore: mainStore)
//                #if !os(watchOS)
//                    try ZServingRun.dedupe(backgroundContext, object, inStore: archiveStore)
//                #endif
//            case ZDayRun.entity().name:
//                try ZDayRun.dedupe(backgroundContext, object, inStore: mainStore)
//                #if !os(watchOS)
//                    try ZDayRun.dedupe(backgroundContext, object, inStore: archiveStore)
//                #endif
            default:
                _ = 0
            }

            try backgroundContext.save() // should automatically merge changes into foreground context
        } catch let error as TrackerError {
            logger.error("handleInsert: \(error)")
        } catch {
            logger.error("handleInsert: \(error.localizedDescription)")
        }
    }
}

//
//  CoreDataStack-stores.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData

import TrackerLib

public extension CoreDataStack {
    enum StoreType: String {
        case main = ""
        case archive
    }

    func getMainStore(_ context: NSManagedObjectContext) -> NSPersistentStore? {
        getStore(context, .main)
    }

    func getArchiveStore(_ context: NSManagedObjectContext) -> NSPersistentStore? {
        getStore(context, .archive)
    }

    private func getStore(_ context: NSManagedObjectContext, _ storeType: StoreType) -> NSPersistentStore? {
        getStore(context, storeKey: storeType.rawValue)
    }
}

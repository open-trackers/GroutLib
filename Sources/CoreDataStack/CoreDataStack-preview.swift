//
//  CoreDataStack-preview.swift
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
    // obtain a manager that has been cleared of all data
    static func getPreviewStack() -> CoreDataStack {
        do {
            let stack = CoreDataStack(isCloud: false, fileNamePrefix: "Test")

            let ctx = stack.container.viewContext
            try stack.clearPrimaryEntities(ctx)
            try stack.clearZEntities(ctx)
            try ctx.save()

            return stack
        } catch {
            fatalError("Could not obtain preview core data stack.")
        }
    }
}

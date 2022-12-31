//
//  UserOrdered.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import SwiftUI

public protocol UserOrdered {
    var userOrder: Int16 { get set }
}

public extension UserOrdered {
    // NOTE: adapted from https://stackoverflow.com/questions/59742218/swiftui-reorder-coredata-objects-in-list
    static func move<T: UserOrdered>(_ results: FetchedResults<T>, from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
        var revisedItems: [T] = results.map { $0 }

        // change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // update the userOrder attribute in revisedItems to
        // persist the new order. This is done in reverse order
        // to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1,
                                   through: 0,
                                   by: -1)
        {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }
    }
}

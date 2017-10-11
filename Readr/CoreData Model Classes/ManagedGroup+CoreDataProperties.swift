//
//  ManagedGroup+CoreDataProperties.swift
//  Readr
//
//  Created by Justin Oakes on 11/10/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedGroup {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedGroup> {
        return NSFetchRequest<ManagedGroup>(entityName: "ManagedGroup")
    }

    @NSManaged public var name: String?
    @NSManaged public var order: Int16
    @NSManaged public var feeds: NSSet?

}

// MARK: Generated accessors for feeds
extension ManagedGroup {

    @objc(addFeedsObject:)
    @NSManaged public func addToFeeds(_ value: ManagedFeed)

    @objc(removeFeedsObject:)
    @NSManaged public func removeFromFeeds(_ value: ManagedFeed)

    @objc(addFeeds:)
    @NSManaged public func addToFeeds(_ values: NSSet)

    @objc(removeFeeds:)
    @NSManaged public func removeFromFeeds(_ values: NSSet)

}

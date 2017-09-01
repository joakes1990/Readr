//
//  ManagedFeed+CoreDataProperties.swift
//  Readr
//
//  Created by Justin Oakes on 8/31/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedFeed {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeed> {
        return NSFetchRequest<ManagedFeed>(entityName: "ManagedFeed")
    }

    @NSManaged public var canonicalURL: String?
    @NSManaged public var favIcon: String?
    @NSManaged public var lastUpdated: NSDate?
    @NSManaged public var mimeType: Int16
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var stories: NSSet?

}

// MARK: Generated accessors for stories
extension ManagedFeed {

    @objc(addStoriesObject:)
    @NSManaged public func addToStories(_ value: ManagedStory)

    @objc(removeStoriesObject:)
    @NSManaged public func removeFromStories(_ value: ManagedStory)

    @objc(addStories:)
    @NSManaged public func addToStories(_ values: NSSet)

    @objc(removeStories:)
    @NSManaged public func removeFromStories(_ values: NSSet)

}

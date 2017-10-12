//
//  ManagedPlaylist+CoreDataProperties.swift
//  Readr
//
//  Created by justin on 10/12/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedPlaylist {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedPlaylist> {
        return NSFetchRequest<ManagedPlaylist>(entityName: "ManagedPlaylist")
    }

    @NSManaged public var name: String?
    @NSManaged public var order: Int16
    @NSManaged public var stories: NSSet?

}

// MARK: Generated accessors for stories
extension ManagedPlaylist {

    @objc(addStoriesObject:)
    @NSManaged public func addToStories(_ value: ManagedStory)

    @objc(removeStoriesObject:)
    @NSManaged public func removeFromStories(_ value: ManagedStory)

    @objc(addStories:)
    @NSManaged public func addToStories(_ values: NSSet)

    @objc(removeStories:)
    @NSManaged public func removeFromStories(_ values: NSSet)

}

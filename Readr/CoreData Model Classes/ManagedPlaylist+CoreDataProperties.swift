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
    @NSManaged public var sort: Int16

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

extension ManagedPlaylist {
    
    func sortDescripters(forType type: sortType) -> [NSSortDescriptor] {
        switch type {
        case .read:
            let read: NSSortDescriptor = NSSortDescriptor(key: "read", ascending: true)
            let pubdate: NSSortDescriptor = NSSortDescriptor(key: "pubdate", ascending: false)
            return [read, pubdate]
        case.pubdate:
            return [NSSortDescriptor(key: "pubdate", ascending: false)]
        case .host:
            return [NSSortDescriptor(key: "feedURL", ascending: true)]
        case .title:
            return [NSSortDescriptor(key: "title", ascending: true)]
        }
    }
    
    enum sortType: Int {
        case read
        case pubdate
        case host
        case title
    }
}

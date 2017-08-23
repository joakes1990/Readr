//
//  ManagedStory+CoreDataProperties.swift
//  Readr
//
//  Created by Justin Oakes on 8/22/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedStory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedStory> {
        return NSFetchRequest<ManagedStory>(entityName: "Story")
    }

    @NSManaged public var audioContent: String?
    @NSManaged public var author: String?
    @NSManaged public var feedURL: String?
    @NSManaged public var htmlContent: String?
    @NSManaged public var image: String?
    @NSManaged public var podcast: Bool
    @NSManaged public var pubdate: NSDate?
    @NSManaged public var read: Bool
    @NSManaged public var textContent: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var feed: ManagedFeed?

}

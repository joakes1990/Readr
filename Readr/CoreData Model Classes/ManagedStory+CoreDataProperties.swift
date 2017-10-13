//
//  ManagedStory+CoreDataProperties.swift
//  Readr
//
//  Created by justin on 10/12/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//
//

import Cocoa
import CoreData


extension ManagedStory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedStory> {
        return NSFetchRequest<ManagedStory>(entityName: "ManagedStory")
    }

    @NSManaged public var audioContentURL: String?
    @NSManaged public var author: String?
    @NSManaged public var feedURL: String?
    @NSManaged public var htmlContent: String?
    @NSManaged public var image: NSData?
    @NSManaged public var imageURL: String?
    @NSManaged public var podcast: Bool
    @NSManaged public var pubdate: NSDate?
    @NSManaged public var read: Bool
    @NSManaged public var textContent: String?
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var feed: ManagedFeed?

}

extension ManagedStory {
    
    func requestPodcastImage() {
        guard let url: URL = URL(string: imageURL ?? "") else {
            return
        }
        let rssNetwork: RSSNetworking = (NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()).rssNetwork
        rssNetwork.requestImageData(forStory: self, at: url)
    }
    
}

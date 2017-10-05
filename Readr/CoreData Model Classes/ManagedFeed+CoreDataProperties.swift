//
//  ManagedFeed+CoreDataProperties.swift
//  Readr
//
//  Created by Justin Oakes on 8/31/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//
//

import Cocoa
import CoreData


extension ManagedFeed {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedFeed> {
        return NSFetchRequest<ManagedFeed>(entityName: "ManagedFeed")
    }
    
    @NSManaged public var canonicalURL: String?
    @NSManaged public var favIcon: NSData?
    @NSManaged public var lastUpdated: NSDate?
    @NSManaged public var mimeType: Int16
    @NSManaged public var title: String?
    @NSManaged public var url: String?
    @NSManaged public var stories: NSSet?
    @NSManaged public var order: Int16
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

//MARK: Custom methods

extension ManagedFeed {
    
    func requestNewFavIcon() {
        guard let feedURL: URL = URL(string: canonicalURL ?? "") else{
            return
        }
        let rssNetwork: RSSNetworking = (NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()).rssNetwork
        rssNetwork.requestNewFavIcon(forURL: feedURL)
    }
    
    func requestNewStories() {
        guard let feedURL: URL = URL(string: url ?? "") else {
            return
        }
        let rssNetwork: RSSNetworking = (NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()).rssNetwork
        rssNetwork.requestNewStories(forURL: feedURL, ofType: intAsMimetype(number: mimeType))
    }
    
    func intAsMimetype(number: Int16) -> mimeTypes {
        switch number {
        case 0:
            return .atom
        case 1:
            return .atomXML
        case 2:
            return .rss
        case 3:
            return .rssXML
        case 4:
            return .simpleRSS
        case 5:
            return .html
        default:
            return .rss
        }
    }
}


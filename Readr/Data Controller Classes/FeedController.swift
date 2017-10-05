//
//  FeedController.swift
//  Readr
//
//  Created by justin on 10/4/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class FeedController {
    
    static let shared: FeedController = FeedController()
    var allFeeds: [ManagedFeed]?
    
    init() {
        allFeeds = populateAllFeeds()
    }
    
    func populateAllFeeds() -> [ManagedFeed] {
        let appDelegate: AppDelegate = NSApplication.shared.delegate  as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedFeed> = NSFetchRequest(entityName: ManagedFeed.feedEntitty)
        do {
            let feeds: [ManagedFeed] = try context.fetch(fetchRequest)
            return feeds.sorted(by: ({$0.order > $1.order}))
        } catch {
            return []
        }
    }
    
    // MARK: Tableview support methods
    
    func tableString(forIndex index: Int) -> String? {
        guard let feed: ManagedFeed = allFeeds?[index],
            let url: String = feed.canonicalURL,
            let hosturl: String = URL(string: url)?.host,
            let name: String = feed.title
            else {
            return nil
        }
        return "\(hosturl) - \(name)"
    }
    
    func tableImage(forIndex index: Int) -> NSImage? {
        guard let feed: ManagedFeed = allFeeds?[index],
            let imageData: Data = feed.favIcon as Data?
            else {
                return nil
        }
        return NSImage(data: imageData)
    }
}

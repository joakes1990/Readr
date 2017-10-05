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
}

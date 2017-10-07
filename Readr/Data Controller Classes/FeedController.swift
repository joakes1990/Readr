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
        updateFeedsArray()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateFeedsArray),
                                               name: .newFeedSaved,
                                               object: nil)
    }
    
    func populateAllFeeds() -> [ManagedFeed] {
        let appDelegate: AppDelegate = NSApplication.shared.delegate  as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedFeed> = NSFetchRequest(entityName: ManagedFeed.feedEntitty)
        let sortDescripter: NSSortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescripter]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    @objc func updateFeedsArray() {
        allFeeds = populateAllFeeds()
    }
    
    func allFeedsCount() -> Int16 {
        return Int16(populateAllFeeds().count)
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
    
    func tableviewCellDidMove(from oldIndex: Int, to newIndex: Int) {
        //offset for folders and playlists row
        let old: Int = oldIndex - 2
        let new: Int = newIndex - 2
        
        var managedFeeds: [ManagedFeed] = allFeeds ?? populateAllFeeds()
        let affectedFeed: ManagedFeed = managedFeeds.remove(at: old)
        managedFeeds.insert(affectedFeed, at: new == 0 ? new : new - 1)
        for number: Int in 0..<managedFeeds.count {
            let feed: ManagedFeed = managedFeeds[number]
            feed.order = Int16(number)
        }
        let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        do {
            try context.save()
        } catch {
            //TODO: log error
            print(error)
        }
        
    }
}

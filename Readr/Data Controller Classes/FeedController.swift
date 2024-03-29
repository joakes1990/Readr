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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceaveUpdatedFevIcon(aNotification:)),
                                               name: .foundFavIcon,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceaveUpdatedStories(aNotification:)),
                                               name: .finishedFindingStories,
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
    
    @objc func insertNewFeed(feed: ManagedFeed) {
        allFeeds?.append(feed)
    }
    
    func saveContext() {
        let delegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = delegate.persistentContainer.viewContext
        do {
            try context.save()
            updateFeedsArray()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func remove(feed: ManagedFeed) {
        let delegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = delegate.persistentContainer.viewContext
        allFeeds?.remove(at: Int(feed.order))
        context.delete(feed)
        do {
            try context.save()
            
        } catch{
            print(error.localizedDescription)
        }
        allFeeds = populateAllFeeds()
        reorderFeeds()
    }
    
    func reorderFeeds() {
        if let feeds: [ManagedFeed] = allFeeds {
            if feeds.count > 0 {
                for index in 0 ..< feeds.count {
                    let feed: ManagedFeed = feeds[index]
                    feed.setValue(index, forKey: "order")
                }
                saveContext()
            }
        }
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
            print(error.localizedDescription)
        }
        
    }
    
    func originalFeed(tempFeed: ManagedFeed) -> ManagedFeed {
        let url: String = tempFeed.url
        let originalFeed: ManagedFeed? = allFeeds?.first(where: { (feed) -> Bool in
            feed.url == url
        })
        return originalFeed ?? tempFeed
    }
    
    //MARK: Adding FavIcon
    
    @objc func didReceaveUpdatedFevIcon(aNotification: Notification) {
        guard let userInfo: [AnyHashable : Any] = aNotification.userInfo,
            let url: URL = userInfo[Notification.Name.urlKey] as? URL,
            let image: NSImage = userInfo[Notification.Name.favIconKey] as? NSImage,
            let imageData: Data = image.tiffRepresentation else {
                //TODO: Log error
                return
        }
        let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedFeed> = NSFetchRequest(entityName: ManagedFeed.feedEntitty)
        let predicate: NSPredicate = NSPredicate(format: "canonicalURL = '\(url)'")
        fetchRequest.predicate = predicate
        do {
            let managedFeeds: [ManagedFeed] = try context.fetch(fetchRequest)
            managedFeeds.forEach({ (feed) in
                feed.favIcon = imageData as NSData
            })
            
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    //MARK: Adding stories
    
    @objc func didReceaveUpdatedStories(aNotification: Notification) {
        guard let userInfo: [AnyHashable : Any] = aNotification.userInfo,
            let feedURL: URL = userInfo.keys.first as? URL ?? URL(string: ""),
            let stories: [Story] = (userInfo[feedURL] as? [Story]?) ?? []
            else {
                return
        }
        let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let feedFetchrequest: NSFetchRequest<ManagedFeed> = NSFetchRequest(entityName: ManagedFeed.feedEntitty)
        let feedPredicate: NSPredicate = NSPredicate(format: "url = '\(feedURL)'")
        feedFetchrequest.predicate = feedPredicate
        
        var feeds: [ManagedFeed] = []
        
        do {
            feeds = try context.fetch(feedFetchrequest)
        } catch {
            //TODO: Log error
            print("did not fetch feeds")
        }
        
        if feeds.count > 0 {
            feeds.forEach({ (feed) in
                let lastUpdated: NSDate = feed.lastUpdated ?? NSDate()
                for story: Story in stories {
                    if story.pubdate == (story.pubdate as NSDate).laterDate(lastUpdated as Date) {
                        // Create new Managed Story and add to feed
                        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ManagedStory.storyEntity, in: context)!
                        let managedStory: ManagedStory = NSManagedObject(entity: entity, insertInto: context) as! ManagedStory
                        
                        managedStory.setValue(story.title, forKey: "title")
                        managedStory.setValue(story.url.absoluteString, forKey: "url")
                        managedStory.setValue(story.textContent, forKey: "textContent")
                        managedStory.setValue(story.htmlContent, forKey: "htmlContent")
                        managedStory.setValue(story.pubdate as NSDate, forKey: "pubdate")
                        managedStory.setValue(false, forKey: "read")
                        managedStory.setValue(feedURL.absoluteString, forKey: "feedURL")
                        managedStory.setValue(story.author, forKey: "author")
                        
                        if let podcast: PodCast = story as? PodCast {
                            managedStory.setValue(true, forKey: "podcast")
                            managedStory.setValue(podcast.audioContent[0].absoluteString, forKey: "audioContentURL")
                            managedStory.requestPodcastImage()
                        } else {
                            managedStory.setValue(false, forKey: "podcast")
                        }
                        feed.addToStories(managedStory)
                        feed.setValue(Date() as NSDate, forKey: "lastUpdated")
                    }
                }
            })
            saveContext()
        }
        
    }
}

//
//  UpdateFeed.swift
//  Readr
//
//  Created by justin on 9/29/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class UpdateFeed {
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceaveUpdatedFevIcon(aNotification:)),
                                               name: .foundFavIcon,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceaveUpdatedStories(aNotification:)),
                                               name: .finishedFindingStories,
                                               object: nil)
    }
    
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
            //TODO: Log error
            print("didn't save fav icon")
        }
        
    }
    
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
                        
                        managedStory.title = story.title
                        managedStory.url = story.url.absoluteString
                        managedStory.textContent = story.textContent
                        managedStory.htmlContent = story.htmlContent
                        managedStory.pubdate = story.pubdate as NSDate
                        managedStory.read = false
                        managedStory.feedURL = feedURL.absoluteString
                        managedStory.author = story.author
                        
                        if let podcast: PodCast = story as? PodCast {
                            managedStory.podcast = true
                            managedStory.audioContentURL = podcast.audioContent[0].absoluteString
                            managedStory.requestPodcastImage()

                        } else {
                            managedStory.podcast = false
                        }
                        feed.addToStories(managedStory)
                        feed.lastUpdated = Date() as NSDate
                    }
                }
            })
            do {
                try context.save()
            } catch {
                //TODO: Print errors
                print(error)
            }
        }
        
    }
}

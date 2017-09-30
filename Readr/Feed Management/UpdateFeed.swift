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
}

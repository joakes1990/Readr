//
//  FeedViewControllerDelegate.swift
//  Readr
//
//  Created by Justin Oakes on 8/21/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa
import CoreData

class ImportFeedManager {
    
    
    
    var delegate: ImportViewProtocol?
    static let shared: ImportFeedManager = ImportFeedManager()
    
    static let addedFeedString: String = NSLocalizedString("New feed added", comment: "New feed added")
    var feeds: [Feed] = []
    
    class func urlIsUnique(_ url: String) -> Bool {
        var unique: Bool = true
        let context: NSManagedObjectContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
        let fetchRequest: NSFetchRequest<ManagedFeed> = NSFetchRequest(entityName: ManagedFeed.feedEntitty)
        fetchRequest.predicate = NSPredicate(format: "url = %@", url)
        do {
            let feeds: [NSManagedObject] = try context.fetch(fetchRequest)
            unique = feeds.count < 1
        } catch {
            unique = false
        }
        return unique
    }
    
    func found(feed: Feed) {
        print("Look I was found")
        feeds.append(feed)
    }
    
    func found(html: Data, from url: URL) {
        let parser: XMLParser = XMLParser(data: html)
        parser.parse
    }
    
    func receavedNetworkError(error: Error) {
        //TODO: populate func
    }
}

protocol ImportViewProtocol {
    func toggleModal(enable: Bool, message: String?)
    
}

//
//  ManagedFeed+CoreDataClass.swift
//  Readr
//
//  Created by justin on 10/12/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//
//

import Cocoa
import CoreData

@objc(ManagedFeed)
public class ManagedFeed: NSManagedObject, NSCoding {
    static let feedEntitty = "ManagedFeed"
    
    public required convenience init(coder aDecoder: NSCoder) {
        let context: NSManagedObjectContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ManagedFeed.feedEntitty, in: context)!
        
        self.init(entity: entity, insertInto: nil)
        canonicalURL = aDecoder.decodeObject(forKey: "canonicalURL") as? String
        favIcon = aDecoder.decodeObject(forKey: "favIcon") as? NSData
        lastUpdated = aDecoder.decodeObject(forKey: "lastUpdated") as? NSDate
        mimeType = aDecoder.decodeObject(forKey: "mimeType") as! Int16
        order = aDecoder.decodeObject(forKey: "order") as! Int16
        title = aDecoder.decodeObject(forKey: "title") as? String
        url = aDecoder.decodeObject(forKey: "url") as! String
        groups = aDecoder.decodeObject(forKey: "groups") as? NSSet
        stories = aDecoder.decodeObject(forKey: "stories") as? NSSet
    }
    
    public override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        let context: NSManagedObjectContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedFeed> = NSFetchRequest(entityName: ManagedFeed.feedEntitty)
        let predicate: NSPredicate = NSPredicate(format: "url == %@", url)
        fetchRequest.predicate = predicate
        do {
            if let feed: ManagedFeed = try context.fetch(fetchRequest).first {
                return feed
            }
        } catch {
            context.insert(self)
            return self
        }
        context.insert(self)
        return self
    }
}

extension ManagedFeed: NSPasteboardWriting {
    public func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    
    public func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.feedType]
    }
    
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(canonicalURL, forKey: "canonicalURL")
        aCoder.encode(favIcon, forKey: "favIcon")
        aCoder.encode(lastUpdated, forKey: "lastUpdated")
        aCoder.encode(mimeType, forKey: "mimeType")
        aCoder.encode(order, forKey: "order")
        aCoder.encode(title, forKey: "title")
        aCoder.encode(url, forKey: "url")
        aCoder.encode(groups, forKey: "groups")
        aCoder.encode(stories, forKey: "stories")
    }
    
}

//
//  PlaylistOutlineViewController.swift
//  Readr
//
//  Created by Justin Oakes on 9/17/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class PlaylistOutlineViewDelegate: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {

    var allFeeds: [ManagedFeed]
    
    override init() {
        let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedFeed> = NSFetchRequest(entityName: ManagedFeed.feedEntitty)
        do {
        allFeeds = try context.fetch(fetchRequest) as [ManagedFeed]
        } catch {
            //TODO: Log error
            print(error)
            allFeeds = [ManagedFeed]()
        }
    }
    //MARK: DataSource methods
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        switch item {
        default:
            return 4
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return NSObject()
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        return NSObject()
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return true
    }
    
}

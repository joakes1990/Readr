//
//  PlaylistOutlineViewController.swift
//  Readr
//
//  Created by Justin Oakes on 9/17/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class PlaylistOutlineViewDelegate: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    var dataModel: DataModel?
    var outline: NSOutlineView?
    
    override init() {
        super.init()
        populateOutlineView()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(populateOutlineView),
                                               name: .newFeedSaved,
                                               object: nil)
    }
    
    @objc fileprivate func populateOutlineView() {
        let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedFeed> = NSFetchRequest(entityName: ManagedFeed.feedEntitty)
        do {
            let allFeeds: [ManagedFeed] = try context.fetch(fetchRequest) as [ManagedFeed]
            dataModel = DataModel(name: NSLocalizedString("Feeds", comment: "Feeds"),
                                  children: allFeeds)
            unowned let unownedSelf: PlaylistOutlineViewDelegate = self
            DispatchQueue.main.async {
                unownedSelf.outline?.reloadItem(nil)
            }
            
            
        } catch {
            //TODO: Log error
            dataModel = DataModel(name: String(), children: [ManagedFeed]())
            print(error)
        }
    }
    
    //MARK: DataSource methods
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        outline = outlineView
        if let outlineItem: DataModel = item as? DataModel {
            return outlineItem.children.count
        } else {
            return 1
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            return dataModel as Any
        } else {
            let outlineItem: DataModel = item as? DataModel ?? DataModel(name: "Feeds", children: [])
            return outlineItem.children[index] as Any
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        let tableCell = outlineView.makeView(withIdentifier: .cellView, owner: self) as! NSTableCellView
        if let _: DataModel = item as? DataModel {
            tableCell.textField?.stringValue = NSLocalizedString("Feeds", comment: "Feeds")
            tableCell.imageView?.image = #imageLiteral(resourceName: "RSSCellImage")
            return tableCell
        } else if let managedFeedItem: ManagedFeed = item as? ManagedFeed,
            let imageData: Data = managedFeedItem.favIcon as Data?,
            let urlName: String = URL(string: managedFeedItem.canonicalURL ?? "")?.host {
                tableCell.textField?.stringValue = "\(urlName) - \(managedFeedItem.title ?? "")"
            tableCell.imageView?.image = imageData != nil ? NSImage(data: imageData) : #imageLiteral(resourceName: "genaricfeed")
                return tableCell
        }
        return nil
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let _: DataModel = item as? DataModel {
            return true
        } else {
            return false
        }
    }
    
}


struct DataModel {
    var name: String
    var children: [ManagedFeed]
}


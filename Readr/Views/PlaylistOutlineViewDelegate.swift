//
//  PlaylistOutlineViewController.swift
//  Readr
//
//  Created by Justin Oakes on 9/17/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class PlaylistOutlineViewDelegate: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    var rootDataModel: DataModel?
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
            rootDataModel = DataModel(name: NSLocalizedString("Feeds", comment: "Feeds"),
                                      children: allFeeds)
            unowned let unownedSelf: PlaylistOutlineViewDelegate = self
            DispatchQueue.main.async {
                unownedSelf.outline?.reloadItem(nil)
            }
            
            
        } catch {
            //TODO: Log error
            rootDataModel = DataModel(name: String(), children: [ManagedFeed]())
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
            return rootDataModel as Any
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
            tableCell.imageView?.image = NSImage(data: imageData)
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
    
    //MARK DelegateMethods
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if let dataModel: DataModel = item as? DataModel {
            let children: [ManagedFeed] = dataModel.children
            var allStories: [ManagedStory] = []
            children.forEach({ (feed) in
                let stories: [ManagedStory] = feed.stories?.allObjects as? [ManagedStory] ?? []
                allStories.append(contentsOf: stories)
            })
            allStories.sort(by: { (story1, story2) -> Bool in
                return story1.pubdate as Date? == story1.pubdate?.laterDate(story2.pubdate as Date? ?? Date.distantPast)
            })
            print(allStories)
        }
        print(item)
        return true
    }
}


struct DataModel {
    var name: String
    var children: [ManagedFeed]
}


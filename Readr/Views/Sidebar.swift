//
//  Sidebar.swift
//  Readr
//
//  Created by justin on 10/7/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

extension MainViewController: NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    
    func populateDataSource() -> sourceData {
        let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let allFeedFetchRequest: NSFetchRequest<ManagedFeed> = NSFetchRequest(entityName: ManagedFeed.feedEntitty)
        let allFeedsSort: NSSortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        allFeedFetchRequest.sortDescriptors = [allFeedsSort]
        var allFeeds: [ManagedFeed] = [ManagedFeed]()
        do {
            allFeeds = try context.fetch(allFeedFetchRequest)
        } catch {
            return sourceData(allFeeds: [], allGroups: [], allPlaylists: [])
        }
        
        let allGroupsFetchRequest: NSFetchRequest<ManagedGroup> = NSFetchRequest(entityName: ManagedGroup.groupEntitty)
        let allGroupSort: NSSortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        allGroupsFetchRequest.sortDescriptors = [allGroupSort]
        var allGroups: [ManagedGroup] = [ManagedGroup]()
        do {
            allGroups = try context.fetch(allGroupsFetchRequest)
        } catch {
            return sourceData(allFeeds: allFeeds, allGroups: [], allPlaylists: [])
        }
        //TODO: populate playlists
        
        return sourceData(allFeeds: allFeeds, allGroups:allGroups, allPlaylists: [])
    }
    
    //MARK: Datasource/Delegate Methods
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let _: [Any] = item as? [Any] {
            return true
        } else {
            return false
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 3
        }
        if let feeds: [ManagedFeed] = item as? [ManagedFeed] {
            return feeds.count
        } else if let groups: [ManagedGroup] = item as? [ManagedGroup] {
            return groups.count
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let _: [Any] = item as? [Any] {
            let cell: NSTableCellView = outlineview.makeView(withIdentifier: .headerCell, owner: nil) as? NSTableCellView ?? NSTableCellView()
            var title: String
            if sidebarDataSource?.usedFeeds == true && sidebarDataSource?.usedGroups == true {
                title = NSLocalizedString("Playlists", comment: "Playlists")
                sidebarDataSource?.resetUsedFlags()
            } else if sidebarDataSource?.usedFeeds == true {
                title = NSLocalizedString("Groups", comment: "Groups")
                sidebarDataSource?.usedGroups = true
            } else {
                title = NSLocalizedString("Feeds", comment: "Feeds")
                sidebarDataSource?.usedFeeds = true
            }
            cell.textField?.stringValue = title
            return cell
        } else if let feed: ManagedFeed = item as? ManagedFeed {
            let cell: NSTableCellView = outlineView.makeView(withIdentifier: .dataCell, owner: nil) as? NSTableCellView ?? NSTableCellView()
            let host: String = URL(string: feed.canonicalURL ?? "")?.host ?? ""
            let imageData: Data = feed.favIcon as Data? ?? Data()
            let favicon: NSImage = NSImage(data: (imageData)) ?? #imageLiteral(resourceName: "genaricfeed")
            cell.textField?.stringValue = "\(host) - \(feed.title ?? "RSS")"
            cell.imageView?.image = favicon
            return cell
        }
        
        return NSView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            switch index {
            case 0:
                return sidebarDataSource?.allFeeds as Any
            case 1:
                return sidebarDataSource?.allGroups as Any
            case 2:
                return sidebarDataSource?.allPlaylists as Any
            default:
                return ()
            }
        }
        if let _: [ManagedFeed] = item as? [ManagedFeed] {
            return sidebarDataSource?.allFeeds[index] as Any
        }
        if let _: [ManagedGroup] = item as? [ManagedGroup] {
            return sidebarDataSource?.allGroups[index] as Any
        }
        return NSObject()
    }
}

struct sourceData {
    var allFeeds: [ManagedFeed]
    var usedFeeds: Bool
    var allGroups: [ManagedGroup]
    var usedGroups: Bool
    var allPlaylists: [Any]
    
    init(allFeeds: [ManagedFeed], allGroups: [ManagedGroup], allPlaylists: [Any]) {
        self.allFeeds = allFeeds
        self.allGroups = allGroups
        self.allPlaylists = allPlaylists
        usedFeeds = false
        usedGroups = false
    }
    mutating func resetUsedFlags()  {
        usedFeeds = false
        usedGroups = false
    }
}

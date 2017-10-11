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
        //TODO: populate groups and playlists
        
        return sourceData(allFeeds: allFeeds, allGroups: [], allPlaylists: [])
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
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let _: [ManagedFeed] = item as? [ManagedFeed] {
            let cell: NSTableCellView = outlineview.makeView(withIdentifier: .headerCell, owner: nil) as? NSTableCellView ?? NSTableCellView()
            cell.textField?.stringValue = NSLocalizedString("Feeds", comment: "Feeds")
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
        if let feeds: [ManagedFeed] = item as? [ManagedFeed] {
            return feeds[index]
        }
        return NSObject()
    }
}

struct sourceData {
    var allFeeds: [ManagedFeed]
    var allGroups: [Any]
    var allPlaylists: [Any]
}

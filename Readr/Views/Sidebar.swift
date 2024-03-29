//
//  Sidebar.swift
//  Readr
//
//  Created by justin on 10/7/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

extension MainViewController: NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate {
    
    
    func populateDataSource() -> sourceData {
        let allFeeds: [ManagedFeed] = FeedController.shared.allFeeds ?? [ManagedFeed]()
        let allGroups: [ManagedGroup] = GroupController.shared.allGroups ?? [ManagedGroup]()
        let allPlaylists: [ManagedPlaylist] = PlaylistController.shared.allPlatlists ?? [ManagedPlaylist]()
        
        return sourceData(allFeeds: allFeeds, allGroups: allGroups, allPlaylists: allPlaylists)
    }
    
    //MARK: Datasource/Delegate Methods
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let _: [Any] = item as? [Any] {
            return true
        }
        if let _: ManagedGroup = item as? ManagedGroup{
            return true
        }
        if let _: ManagedPlaylist = item as? ManagedPlaylist {
            return true
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            return 3
        }
        if let set: [Any] = item as? [Any] {
            return set.count
        }
        if let group: ManagedGroup = item as? ManagedGroup {
            let feeds: NSSet = group.feeds ?? []
            return feeds.count
        }
        if let playlist: ManagedPlaylist = item as? ManagedPlaylist {
            let stories: NSSet = playlist.stories ?? []
            return stories.count
        }
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if let _: [Any] = item as? [Any] {
            let cell: NSTableCellView = outlineview.makeView(withIdentifier: .headerCell, owner: nil) as? NSTableCellView ?? NSTableCellView()
            var title: String = String()
            if outlineView.parent(forItem: item) == nil {
                let index: Int = outlineView.childIndex(forItem: item)
                switch index {
                case 0:
                    title = NSLocalizedString("Feeds", comment: "Feeds")
                    break
                case 1:
                    title = NSLocalizedString("Groups", comment: "Groups")
                    break
                case 2:
                    title = NSLocalizedString("Playlists", comment: "Playlists")
                    break
                default:
                    break
                }
                cell.textField?.stringValue = title
                return cell
            }
        }
            if let feed: ManagedFeed = item as? ManagedFeed {
                let cell: NSTableCellView = outlineView.makeView(withIdentifier: .dataCell, owner: nil) as? NSTableCellView ?? NSTableCellView()
                let imageData: Data = feed.favIcon as Data? ?? Data()
                let favicon: NSImage = NSImage(data: (imageData)) ?? #imageLiteral(resourceName: "genaricfeed")
                cell.textField?.stringValue = feed.title ?? NSLocalizedString("Untitled", comment: "Untitled")
                cell.toolTip = feed.title ?? NSLocalizedString("Untitled", comment: "Untitled")
                cell.textField?.delegate = self
                cell.imageView?.image = favicon
                return cell
            }
            if let group: ManagedGroup = item as? ManagedGroup {
                let cell: NSTableCellView = outlineView.makeView(withIdentifier: .dataCell, owner: nil) as? NSTableCellView ?? NSTableCellView()
                cell.textField?.stringValue = group.name ?? NSLocalizedString("Unnamed", comment: "Unnamed")
                cell.imageView?.image = #imageLiteral(resourceName: "Folder")
                cell.textField?.delegate = self
                return cell
            }
            if let playlist: ManagedPlaylist = item as? ManagedPlaylist {
                let cell: NSTableCellView = outlineView.makeView(withIdentifier: .dataCell, owner: nil) as? NSTableCellView ?? NSTableCellView()
                cell.textField?.stringValue = playlist.name ?? NSLocalizedString("Unnamed", comment: "Unnamed")
                cell.imageView?.image = #imageLiteral(resourceName: "Playlist")
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
        if let _: [ManagedPlaylist] = item as? [ManagedPlaylist] {
            return sidebarDataSource?.allPlaylists[index] as Any
        }
        if let group: ManagedGroup = item as? ManagedGroup {
            let feeds: NSSet = group.feeds ?? []
            let sortType: ManagedGroup.sortType = ManagedGroup.sortType(rawValue: Int(group.sort)) ?? .host
            let sortDescripter: [NSSortDescriptor] = group.sortDescripters(forType: sortType)
            let sortedArray = feeds.sortedArray(using: sortDescripter)
            return sortedArray[index] as Any
        }
        if let playlist: ManagedPlaylist = item as? ManagedPlaylist {
            let stories: NSSet = playlist.stories ?? []
            let sortType: ManagedPlaylist.sortType = ManagedPlaylist.sortType(rawValue: Int(playlist.sort)) ?? .read
            let sortDescripter: [NSSortDescriptor] = playlist.sortDescripters(forType: sortType)
            let sortedArray = stories.sortedArray(using: sortDescripter)
            return sortedArray[index] as Any
        }
        return NSObject()
    }
    
    //MARK: Misc outlineview support
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        if let collection: [Any] = item as? [Any] {
            if let feeds: [ManagedFeed] = collection as? [ManagedFeed] {
                return feeds.count > 0 ? true : false
            } else {
                return false
            }
        }
        return true
    }
    
    //MARK: Drag and drop
    
    func outlineView(_ outlineView: NSOutlineView, writeItems items: [Any], to pasteboard: NSPasteboard) -> Bool {
        if let item: ManagedFeed = items[0] as? ManagedFeed {
            pasteboard.clearContents()
            let data: Data = NSKeyedArchiver.archivedData(withRootObject: item)
            pasteboard.setData(data, forType: .feedType)
            return true
        }
        if let _: ManagedGroup = items[0] as? ManagedGroup {
            return false
        }
        if let _: ManagedPlaylist = items[0] as? ManagedPlaylist {
            return false
        }
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
        let dragedItems: [NSPasteboardItem]? = info.draggingPasteboard().pasteboardItems
        if dragedItems?.count == 1 {
            if let _: Data = dragedItems?[0].data(forType: .feedType) {
                return dragOperation(forItem: item)
            }
        }
        return .generic
    }
    
    func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
        if let group: ManagedGroup = item as? ManagedGroup {
            guard let pasteboardItems: [NSPasteboardItem] = info.draggingPasteboard().pasteboardItems,
                let pbItem: NSPasteboardItem = pasteboardItems.first,
                let data: Data = pbItem.data(forType: .feedType),
                let feed: ManagedFeed = NSKeyedUnarchiver.unarchiveObject(with: data) as? ManagedFeed else {
                return false
            }
            group.addToFeeds(FeedController.shared.originalFeed(tempFeed: feed))
            GroupController.shared.saveContext()
            GroupController.shared.updateGroupsArray()
            sidebarDataSource = populateDataSource()
            if outlineView.isItemExpanded(item) {
                outlineview.reloadItem(item, reloadChildren: true)
            }
            return true
        }
        return false
    }
    
    // Drag and drop support
    
    
    func dragOperation(forItem item: Any?) -> NSDragOperation {
        if let _: [ManagedFeed] = item as? [ManagedFeed] {
            return .move
        }
        if let _: ManagedGroup = item as? ManagedGroup {
            return .copy
        }
        return []
    }
    
    //MARK: Textfield Delegate
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField: NSTextField = obj.object as? NSTextField else {
            return
        }
        let newString: String = textField.stringValue
        let row: Int = outlineview.selectedRow
        let item = outlineview.item(atRow: row)
        
        if let feed: ManagedFeed = item as? ManagedFeed {
            feed.setValue(newString, forKey: "title")
            FeedController.shared.saveContext()
        }
        
        if let group: ManagedGroup = item as? ManagedGroup {
            group.setValue(newString, forKey: "name")
            GroupController.shared.saveContext()
        }
    }
    
    //MARK: Removing Items
    
    func removeSelectedItem() {
        let selectedRow: Int = outlineview.selectedRow
        let selectedItem: Any? = outlineview.item(atRow: selectedRow)
        if let group: ManagedGroup = selectedItem as? ManagedGroup {
            let childIndex: Int = outlineview.childIndex(forItem: group)
            outlineview.removeItems(at: [childIndex],
                                    inParent: outlineview.parent(forItem: group),
                                    withAnimation: .slideLeft)
            GroupController.shared.remove(group: group)
            sidebarDataSource = populateDataSource()
        }
        
        if let feed: ManagedFeed = selectedItem as? ManagedFeed {
            let childIndex: Int = outlineview.childIndex(forItem: feed)
            let parentItem = outlineview.parent(forItem: feed)
            if let feeds: [ManagedFeed] = parentItem as? [ManagedFeed] {
                removeFeedFromGroups(feed: feed)
                FeedController.shared.remove(feed: feed)
                FeedController.shared.saveContext()
            }
            if let group: ManagedGroup = parentItem as? ManagedGroup {
                group.removeFromFeeds(feed)
                GroupController.shared.saveContext()
                sidebarDataSource = populateDataSource()
            }
            if let group: ManagedGroup = parentItem as? ManagedGroup {
                group.removeFromFeeds(feed)
            }
            outlineview.removeItems(at: [childIndex],
                                    inParent: parentItem,
                                    withAnimation: .slideLeft)
            sidebarDataSource = populateDataSource()
            
        }
    }
    
    func removeFeedFromGroups(feed: ManagedFeed) {
        feed.groups?.forEach({ (item) in
            guard let group: ManagedGroup = item as? ManagedGroup else {
                return
            }
            group.removeFromFeeds(feed)
            outlineview.reloadItem(group, reloadChildren: true)
        })
        FeedController.shared.saveContext()
        
    }
}

struct sourceData {
    var allFeeds: [ManagedFeed]
    var allGroups: [ManagedGroup]
    var allPlaylists: [ManagedPlaylist]
    
    init(allFeeds: [ManagedFeed], allGroups: [ManagedGroup], allPlaylists: [ManagedPlaylist]) {
        self.allFeeds = allFeeds
        self.allGroups = allGroups
        self.allPlaylists = allPlaylists
    }
}

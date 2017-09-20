//
//  PlaylistOutlineViewController.swift
//  Readr
//
//  Created by Justin Oakes on 9/17/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class PlaylistOutlineViewDelegate: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    var dataModel: [outlineType : [ManagedFeed]] = [.all : [],
                                                    .folders : [],
                                                    .playlists : [],
                                                    .smartPlaylists : []]
    
    override init() {
        let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedFeed> = NSFetchRequest(entityName: ManagedFeed.feedEntitty)
        do {
            dataModel[.all] = try context.fetch(fetchRequest) as [ManagedFeed]
        } catch {
            //TODO: Log error
            print(error)
            dataModel[.all] = [ManagedFeed]()
        }
    }
    //MARK: DataSource methods
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let outlineItem: [outlineType : ManagedFeed] = item as? [outlineType : ManagedFeed] {
            return outlineItem.count
        } else {
            return dataModel.keys.count
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let outlineItem: [outlineType : [ManagedFeed]?] = item as? [outlineType : [ManagedFeed]?] else {
            switch index {
            case 0:
                return [.all : dataModel[.all]] as [outlineType : [ManagedFeed]?]
            case 1:
                return [.folders : dataModel[.folders]] as [outlineType : [ManagedFeed]?]
            case 2:
                return [.playlists : dataModel[.playlists]] as [outlineType : [ManagedFeed]?]
            case 3:
                return [.smartPlaylists : dataModel[.smartPlaylists]] as [outlineType : [ManagedFeed]?]
            default:
                return [.all : dataModel[.all]] as [outlineType : [ManagedFeed]?]
            }
        }
        return outlineItem
    }
    
    func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
        guard let outlineItem: [ManagedFeed] = item as? [ManagedFeed] else {
            var view: NSTableCellView?
            if let outlineItem: [outlineType : [ManagedFeed]?] = item as? [outlineType : [ManagedFeed]?]{
                let type: outlineType = outlineItem.keys.first ?? .all
                switch type {
                case .all:
                    view = outlineView.makeView(withIdentifier: .feedCell, owner: self) as? NSTableCellView
                case .folders:
                    view = outlineView.makeView(withIdentifier: .folderCell, owner: self) as? NSTableCellView
                case .playlists:
                    view = outlineView.makeView(withIdentifier: .playlistCell, owner: self) as? NSTableCellView
                case .smartPlaylists:
                    view = outlineView.makeView(withIdentifier: .smartPlaylistCell, owner: self) as? NSTableCellView
                }
            }
            return view
        }
        
        return tableColumn
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let _: outlineType = item as? outlineType {
            return true
        } else {
            return false
        }
    }
    
}

enum outlineType: String {
    typealias RawValue = String
    case all = "all"
    case folders = "folders"
    case playlists = "playlists"
    case smartPlaylists = "smartPlaylists"
}

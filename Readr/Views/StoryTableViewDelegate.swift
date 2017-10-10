//
//  StoryTableViewDelegate.swift
//  Readr
//
//  Created by Justin Oakes on 7/10/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class StoryTableViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Int(StoryController.shared.allStoriesCount())
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let story: ManagedStory? = StoryController.shared.allStories?[row]
        let cell = tableView.makeView(withIdentifier: .storyCell, owner: nil) as! NSTableCellView
        guard let imageData: Data = story?.feed?.favIcon as Data?,
            let image: NSImage = NSImage(data: imageData) else {
            cell.imageView?.image = #imageLiteral(resourceName: "rss")
            cell.textField?.stringValue = story?.title ?? NSLocalizedString("Untitled", comment: "Untitled")
            return cell
        }
        
        cell.imageView?.image = image
         cell.textField?.stringValue = story?.title ?? NSLocalizedString("Untitled", comment: "Untitled")
        
        return cell
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 76.0
    }
}

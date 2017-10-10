//
//  Sidebar.swift
//  Readr
//
//  Created by justin on 10/7/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

extension MainViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        // Get number of feeds and add two
        return (FeedController.shared.allFeeds?.count ?? 0) + 2
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var text: String?
        var image: NSImage?
        
        switch row {
        case 0:
            text = NSLocalizedString("Folders", comment: "Folders")
            image = #imageLiteral(resourceName: "Folder")
            break
        case 1:
            text = NSLocalizedString("Playlists", comment: "Playlists")
            image = #imageLiteral(resourceName: "Playlist")
            break
        default:
            let index: Int = row - 2
            text = FeedController.shared.tableString(forIndex: index)
            image = FeedController.shared.tableImage(forIndex: index)
        }
        if let cell: MainCellView = tableView.makeView(withIdentifier: .mainCell, owner: nil) as? MainCellView {
            cell.textField?.stringValue = text ?? ""
            cell.imageView?.image = image != nil ? image : #imageLiteral(resourceName: "genaricfeed")
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 65.0
    }
    
    //MARK: Drag and drop methods
    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
        guard let index: Int = rowIndexes.first else {
            return false
        }
        if index <= 1 {
            return false
        } else {
            pboard.clearContents()
            let data: Data = NSKeyedArchiver.archivedData(withRootObject: rowIndexes)
            pboard.setData(data, forType: .mainCellType)
            return true
        }
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        if row >= 3 {
            return .move
        } else {
            return .generic
        }
    }
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
        if dropOperation == .above && row >= 2 {
            let indexData: Data = info.draggingPasteboard().data(forType: .mainCellType) ?? Data()
            let indexSet: IndexSet? = NSKeyedUnarchiver.unarchiveObject(with: indexData) as? IndexSet
            guard let startIndex: Int = indexSet?.first else {
                return false
            }
            tableView.beginUpdates()
            tableView.moveRow(at: startIndex, to: row == tableView.numberOfRows ? row - 1 : row > startIndex ? row - 1 : row)
            tableView.endUpdates()
            FeedController.shared.tableviewCellDidMove(from: startIndex, to: row)
            return true
        } else {
            return false
        }
    }
}

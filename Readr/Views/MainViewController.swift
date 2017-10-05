//
//  ViewController.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {

    @IBOutlet weak var outlineView: NSOutlineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

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
        if let cell: MainCellView = tableView.makeView(withIdentifier: MainCellView.identifier, owner: nil) as? MainCellView {
            cell.textField?.stringValue = text ?? ""
            cell.imageView = NSImageView(image: image ?? #imageLiteral(resourceName: "genaricfeed"))
            return cell
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 65.0
    }
}

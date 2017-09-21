//
//  SelectFeedsViewController.swift
//  Readr
//
//  Created by Justin Oakes on 9/9/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class SelectFeedsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var tableView: NSTableView!
    var links: [Link] = []
    let feedImporter: ImportFeed = ImportFeed()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear() {
        view.window?.standardWindowButton(.zoomButton)?.isHidden = true
        view.window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        view.window?.minSize = view.window?.frame.size ?? NSSize(width: 440.0, height: 263.0)
        view.window?.maxSize = view.window?.frame.size ?? NSSize(width: 44.0, height: 263.0)
    }
    
    override func viewDidDisappear() {
        links = []
    }
    
    func displayLinks(links: [Link]) {
        self.links = links
        tableView.reloadData()
    }
    
    //MARK: TableView Datasource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        var origenalLinks: Int = links.count
        for link: Link in links {
            origenalLinks = ImportFeed.shared.wasPreviousltAdded(link: link) ? (origenalLinks - 1) : origenalLinks
        }
        return links.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell: AddFeedCellView = AddFeedCellView(frame: NSRect(x: 0.0, y: 0.0, width: 400.0, height: 75.0))
        let link: Link = links[row]
        cell.titleLabel.stringValue = link.title
        if ImportFeed.shared.wasPreviousltAdded(link: link) {
            cell.checkBox.state = .on
            cell.checkBox.isEnabled = false
            cell.checkBox.title = NSLocalizedString("Added", comment: "Added")
        } else {
        cell.checkBox.toolTip = "Add \(link.title)"
        }
        return cell
    }
    
    @IBAction func addLinks(_ sender: Any) {
        for index in 0 ..< tableView.numberOfRows {
            let row: AddFeedCellView = tableView.view(atColumn: 0, row: index, makeIfNecessary: false) as? AddFeedCellView ?? AddFeedCellView(frame: NSRect(x: 0, y: 0, width: 0, height: 0))
            if row.checkBox.state == .on && row.checkBox.isEnabled {
                ImportFeed.shared.identifyFeed(at: links[index].link.absoluteString, with: links[index].title)
            }
        }
        view.window?.close()
    }
    
    @IBAction func cancel(_ sender: Any) {
        view.window?.close()
    }
    
}

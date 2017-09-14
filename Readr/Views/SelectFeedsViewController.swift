//
//  SelectFeedsViewController.swift
//  Readr
//
//  Created by Justin Oakes on 9/9/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class SelectFeedsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var TableView: NSTableView!
    var links: [Link] = []
    let feedImporter: ImportFeed = ImportFeed()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        TableView.delegate = self
        TableView.dataSource = self
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
        TableView.reloadData()
    }
    
    //MARK: TableView Datasource
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return links.count
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 75.0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell: AddFeedCellView = AddFeedCellView(frame: NSRect(x: 0.0, y: 0.0, width: 400.0, height: 75.0))
        let link: Link = links[row]
        cell.titleLabel.stringValue = link.title
        cell.checkBox.toolTip = "Add \(link.title)"
        return cell
    }
    
    @IBAction func addLinks(_ sender: Any) {
        for index in 0 ..< TableView.numberOfRows {
            ImportFeed.shared.identifyFeed(at: links[index].link.absoluteString)
        }
        view.window?.close()
    }
    
    @IBAction func cancel(_ sender: Any) {
        view.window?.close()
    }
    
}

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        TableView.delegate = self
        TableView.dataSource = self
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
        return 100.0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell: AddFeedCellView = AddFeedCellView(frame: NSRect(x: 0.0, y: 0.0, width: 400.0, height: 100.0))
        let link: Link = links[row]
        cell.titleLabel.stringValue = link.title
        return cell
    }
}

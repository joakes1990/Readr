//
//  SelectFeedsViewController.swift
//  Readr
//
//  Created by Justin Oakes on 9/9/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class SelectFeedsViewController: NSViewController, NSTableViewDataSource {

    @IBOutlet weak var TableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func displayLinks(links: [Link]) {
        print(links)
    }
}

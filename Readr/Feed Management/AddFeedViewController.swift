//
//  AddFeedViewController.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class AddFeedViewController: NSViewController {

    @IBOutlet weak var urlTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        if let clipBoardURL: String = ImportFeed.urlFromClipboard() {
            urlTextField.stringValue = clipBoardURL
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        view.window?.close()
    }
    
}

//
//  ViewController.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var sidebarOffsetConstraint: NSLayoutConstraint!
    fileprivate var sidebarOpen: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.intercellSpacing = NSSize(width: 0.0, height: 0.0)
        tableView.registerForDraggedTypes([.mainCellType])
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceaveNewFeeds(aNotification:)),
                                               name: .newFeedSaved,
                                               object: nil)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @objc func didReceaveNewFeeds(aNotification: Notification) {
        unowned let unownedSelf: MainViewController = self
        DispatchQueue.main.async {
            unownedSelf.tableView.reloadData()
        }
    }
    
    //MARK: Animation
    
    func toggleSidebar() {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.250
            sidebarOffsetConstraint.animator().constant = self.sidebarOpen ? -350 : 0
        }) {
            let windowController: MainWindowController = self.view.window?.windowController as? MainWindowController ?? MainWindowController()
            windowController.sidebarToolbarItem.image = self.sidebarOpen ? #imageLiteral(resourceName: "sidebar") : #imageLiteral(resourceName: "closesidebar")
            self.sidebarOpen = self.sidebarOpen ? false : true
        }
    }
}



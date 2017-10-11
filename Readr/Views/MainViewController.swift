//
//  ViewController.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    @IBOutlet weak var outlineview: NSOutlineView!
    @IBOutlet weak var storyTableView: NSTableView!
    let storiesTabledelegate: StoryTableViewDelegate = StoryTableViewDelegate()
    var sidebarDataSource: sourceData?
    fileprivate var sidebarOpen: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sidebarDataSource = populateDataSource()
        outlineview.dataSource = self
        outlineview.delegate = self
        storyTableView.dataSource = storiesTabledelegate
        storyTableView.delegate = storiesTabledelegate
//        tableView.registerForDraggedTypes([.mainCellType])
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
        guard let userinfo: [AnyHashable : Any] = aNotification.userInfo,
            let newFeed: ManagedFeed = userinfo[Notification.Name.newFeedKey] as? ManagedFeed else {
            return
        }
        DispatchQueue.main.async {
            let index: Int = unownedSelf.sidebarDataSource?.allFeeds.count ?? 0
            unownedSelf.sidebarDataSource = unownedSelf.populateDataSource()
            let parentItem = unownedSelf.outlineview.parent(forItem: unownedSelf.sidebarDataSource?.allFeeds[0])
            unownedSelf.outlineview.insertItems(at: NSIndexSet(index: index) as IndexSet,
                                                inParent: parentItem,
                                                withAnimation: NSTableView.AnimationOptions.slideRight)
//            unownedSelf.outlineview.reloadItem(unownedSelf.sidebarDataSource?.allFeeds, reloadChildren: false)
        }
    }
    
    //MARK: Animation
    
    func toggleSidebar() {
//        NSAnimationContext.runAnimationGroup({ (context) in
//            context.duration = 0.250
//            sidebarOffsetConstraint.animator().constant = self.sidebarOpen ? -350 : 0
//        }) {
//            let windowController: MainWindowController = self.view.window?.windowController as? MainWindowController ?? MainWindowController()
//            windowController.sidebarToolbarItem.image = self.sidebarOpen ? #imageLiteral(resourceName: "sidebar") : #imageLiteral(resourceName: "closesidebar")
//            self.sidebarOpen = self.sidebarOpen ? false : true
//        }
    }
}



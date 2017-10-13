//
//  ViewController.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var outlineview: NSOutlineView!
    @IBOutlet weak var storyTableView: NSTableView!
    @IBOutlet weak var addButton: NSButton!
    @IBOutlet weak var removeButton: NSButton!
    let storiesTabledelegate: StoryTableViewDelegate = StoryTableViewDelegate()
    var sidebarDataSource: sourceData?
    fileprivate var sidebarOpen: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sidebarDataSource = populateDataSource()
        outlineview.dataSource = self
        outlineview.delegate = self
        storyTableView.dataSource = storiesTabledelegate
        storyTableView.delegate = storiesTabledelegate
        
        let addMenu: NSMenu = NSMenu()
        let addGroupMenuItem: NSMenuItem = NSMenuItem(title: NSLocalizedString("Add Group", comment: "Add Group"),
                                                      action: #selector(addGroup),
                                                      keyEquivalent: "g")
        let addPlaylistItem: NSMenuItem = NSMenuItem(title: NSLocalizedString("Add Playlist", comment: "Add Playlist"),
                                                     action: #selector(addPlaylist),
                                                     keyEquivalent: "P")
        addMenu.addItem(addGroupMenuItem)
        addMenu.addItem(addPlaylistItem)
        let removeMenu: NSMenu = NSMenu()
        let removeGroupMenuItem: NSMenuItem = NSMenuItem(title: "Remove Group", action: nil, keyEquivalent: "hello")
        let removePlaylistMenuItem: NSMenuItem = NSMenuItem(title: "Remove Playlist", action: nil, keyEquivalent: "good bye")
        removeMenu.addItem(removeGroupMenuItem)
        removeMenu.addItem(removePlaylistMenuItem)
        removeButton.menu = removeMenu
        addButton.menu = addMenu
        
        outlineview.registerForDraggedTypes([.feedType])
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceaveNewFeeds(aNotification:)),
                                               name: .newFeedSaved,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceaveNewGroup(aNotification:)),
                                               name: .newGroupCreated,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceaveNewPlaylist(aNotification:)),
                                               name: .newPlaylistCreated,
                                               object: nil)
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    //MARK: outline view
    @objc func didReceaveNewFeeds(aNotification: Notification) {
        unowned let unownedSelf: MainViewController = self
        DispatchQueue.main.async {
            let index: Int = unownedSelf.sidebarDataSource?.allFeeds.count ?? 0
            unownedSelf.sidebarDataSource = unownedSelf.populateDataSource()
            let parentItem = unownedSelf.outlineview.parent(forItem: unownedSelf.sidebarDataSource?.allFeeds.first)
            if parentItem != nil && unownedSelf.outlineview.isItemExpanded(parentItem) {
                
                
                unownedSelf.outlineview.insertItems(at: NSIndexSet(index: index) as IndexSet,
                                                    inParent: parentItem,
                                                    withAnimation: NSTableView.AnimationOptions.slideDown)
                unownedSelf.outlineview.reloadItem(parentItem)
//                unownedSelf.outlineview.reloadData()
            } else {
//                unownedSelf.outlineview.reloadData()
                unownedSelf.outlineview.reloadItem(parentItem)
            }
        }
    }
    
    @objc func didReceaveNewGroup(aNotification: Notification) {
        unowned let unownedSelf: MainViewController = self
        DispatchQueue.main.async {
            let index: Int = unownedSelf.sidebarDataSource?.allGroups.count ?? 0
            unownedSelf.sidebarDataSource = unownedSelf.populateDataSource()
            let parentItem = unownedSelf.outlineview.parent(forItem: unownedSelf.sidebarDataSource?.allGroups.first)
            if parentItem != nil && unownedSelf.outlineview.isItemExpanded(parentItem) {
                unownedSelf.outlineview.insertItems(at: NSIndexSet(index: index) as IndexSet,
                                                    inParent: parentItem,
                                                    withAnimation: NSTableView.AnimationOptions.slideRight)
                unownedSelf.sidebarDataSource?.usedFeeds = true
                unownedSelf.outlineview.reloadItem(parentItem)
            }
            else {
                unownedSelf.sidebarDataSource?.usedFeeds = true
                unownedSelf.outlineview.reloadItem(parentItem)
                unownedSelf.sidebarDataSource?.resetUsedFlags()
            }
        }
    }
    
    @objc func didReceaveNewPlaylist(aNotification: Notification) {
        unowned let unownedSelf: MainViewController = self
        DispatchQueue.main.async {
            let index: Int = unownedSelf.sidebarDataSource?.allPlaylists.count ?? 0
            unownedSelf.sidebarDataSource = unownedSelf.populateDataSource()
            let parentItem = unownedSelf.outlineview.parent(forItem: unownedSelf.sidebarDataSource?.allPlaylists.first)
            if parentItem != nil && unownedSelf.outlineview.isItemExpanded(parentItem) {
                unownedSelf.outlineview.insertItems(at: NSIndexSet(index: index) as IndexSet,
                                                    inParent: parentItem,
                                                    withAnimation: NSTableView.AnimationOptions.slideRight)
                unownedSelf.sidebarDataSource?.usedFeeds = true
                unownedSelf.sidebarDataSource?.usedGroups = true
                unownedSelf.outlineview.reloadItem(parentItem)
            }
            else {
                unownedSelf.sidebarDataSource?.usedFeeds = true
                unownedSelf.sidebarDataSource?.usedGroups = true
//                unownedSelf.outlineview.reloadData()
                unownedSelf.outlineview.reloadItem(parentItem)
                unownedSelf.sidebarDataSource?.resetUsedFlags()
            }
        }
    }
    
    //MARK: Animation
    
    func toggleSidebar() {
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.200
            widthConstraint.animator().constant = self.sidebarOpen ? 0 : 225
        }) {
            let windowController: MainWindowController = self.view.window?.windowController as? MainWindowController ?? MainWindowController()
            windowController.sidebarToolbarItem.image = self.sidebarOpen ? #imageLiteral(resourceName: "sidebar") : #imageLiteral(resourceName: "closesidebar") 
            self.sidebarOpen = self.sidebarOpen ? false : true
        }
    }
    
    //MARK: Add / Remove Groups/Feeds
    
    @objc func addGroup() {
        GroupController.shared.createGroup(with: NSLocalizedString("Untitled", comment: "Untitled"))
    }
    
    @objc func addPlaylist() {
        PlaylistController.shared.createPlaylist(with: NSLocalizedString("Untitled", comment: "Untitled"))
    }
    
    
}

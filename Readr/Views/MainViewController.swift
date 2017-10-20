//
//  ViewController.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
    
    
    @IBOutlet weak var sidebarOffsetConstraint: NSLayoutConstraint!
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
        guard let info: [AnyHashable : Any] = aNotification.userInfo,
            let feed: ManagedFeed = info[Notification.Name.newFeedKey] as? ManagedFeed
            else {
                unowned let unownedSelf: MainViewController = self
                DispatchQueue.main.async {
                    FeedController.shared.updateFeedsArray()
                    unownedSelf.sidebarDataSource?.allFeeds = FeedController.shared.allFeeds ?? []
                    unownedSelf.outlineview.reloadData()
                }
                return
        }
        unowned let unownedSelf: MainViewController = self
        DispatchQueue.main.async {
            unownedSelf.sidebarDataSource?.allFeeds.append(feed)
            let index: Int = unownedSelf.sidebarDataSource?.allFeeds.count ?? 0
            let parentItem = unownedSelf.outlineview.item(atRow: 0)
            
            if unownedSelf.outlineview.isItemExpanded(parentItem) {
                unownedSelf.outlineview.insertItems(at: NSIndexSet(index: index - 1 >= 0 ? index - 1 : 0) as IndexSet,
                                                    inParent: parentItem,
                                                    withAnimation: .slideDown)
            } else {
                unownedSelf.outlineview.reloadItem(parentItem, reloadChildren: true)
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
            sidebarOffsetConstraint.animator().constant = self.sidebarOpen ? -225 : 0
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

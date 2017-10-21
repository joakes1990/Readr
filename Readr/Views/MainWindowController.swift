//
//  MainWindowController.swift
//  Readr
//
//  Created by justin on 10/7/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    @IBOutlet weak var sidebarToolbarItem: NSToolbarItem!
    override func windowDidLoad() {
        super.windowDidLoad()
    
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    }

    @IBAction func toggleSidebar(_ sender: Any) {
        let childView: MainViewController = window?.contentViewController as? MainViewController ?? MainViewController()
        childView.toggleSidebar()
    }
    
    func removeSelectedItemFromOutline() {
        let childView: MainViewController = window?.contentViewController as? MainViewController ?? MainViewController()
        childView.removeSelectedItem()
    }
    
    //MARK: Accept keyboard shortcuts
    override func keyDown(with event: NSEvent) {
        if event.modifierFlags.intersection(.deviceIndependentFlagsMask).contains(.command) {
            switch event.keyCode {
                // Command + Delete
            case 51:
                removeSelectedItemFromOutline()
                break
            default:
                break
            }
        }
    }
    
}

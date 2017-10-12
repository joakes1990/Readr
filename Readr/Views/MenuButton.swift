//
//  MenuButton.swift
//  Readr
//
//  Created by justin on 10/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class MenuButton: NSButton {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    override func mouseDown(with event: NSEvent) {
        if let menu: NSMenu = self.menu {
            NSMenu.popUpContextMenu(menu, with: event, for: self)
        }
    }
}

//
//  MainCellView.swift
//  Readr
//
//  Created by Justin Oakes on 5/10/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class MainCellView: NSTableCellView {

    static let identifier: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier(rawValue: "mainCell")
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.feedListBackground.setFill()
        dirtyRect.fill()
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}

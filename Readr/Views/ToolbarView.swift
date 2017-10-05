//
//  ToolbarView.swift
//  Readr
//
//  Created by justin on 10/4/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class ToolbarView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        NSColor.feedListBackground.setFill()
       dirtyRect.fill()
        super.draw(dirtyRect)
        // Drawing code here.
    }
    
}

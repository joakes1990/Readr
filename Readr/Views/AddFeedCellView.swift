//
//  AddFeedCellView.swift
//  Readr
//
//  Created by Justin Oakes on 9/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class AddFeedCellView: NSTableRowView {
    
    let titleLabel: NSTextField = NSTextField(labelWithString: "Feed Title")
    var checkBox: NSButton!
    var feedTitle: String?
    var delegate: AddFeedCellDelegate?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        checkBox = NSButton(checkboxWithTitle: NSLocalizedString("Add Feed", comment: "AddFeed"),
                            target: self,
                            action: #selector(cmdClick))
        translatesAutoresizingMaskIntoConstraints = true
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.preferredMaxLayoutWidth = 250
        titleLabel.lineBreakMode = .byTruncatingTail
        let labelDefaultFrame: NSRect = titleLabel.frame
        titleLabel.frame = NSRect(x: 20.0,
                                  y: ((frameRect.height / 2) - (labelDefaultFrame.height / 2)),
                                  width: labelDefaultFrame.width,
                                  height: labelDefaultFrame.height)
        let checkBoxDefaultFrame: NSRect = checkBox.frame
        checkBox.frame = NSRect(x: ((frameRect.width - checkBoxDefaultFrame.width) - 20),
                                y: ((frameRect.height / 2) - (checkBoxDefaultFrame.height / 2)),
                                width: checkBoxDefaultFrame.width,
                                height: checkBoxDefaultFrame.height)
        checkBox.state = .on
        addSubview(titleLabel)
        addSubview(checkBox)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        translatesAutoresizingMaskIntoConstraints = true
        titleLabel.font = NSFont.systemFont(ofSize: 24.0, weight: .heavy)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(checkBox)
    }
    
    @objc func cmdClick() {
        if NSEvent.modifierFlags.contains(.command) && checkBox.isEnabled {
            delegate?.wasCmdClicked(state: checkBox.state)
        }
        
    }
    
}

protocol AddFeedCellDelegate {
    func wasCmdClicked(state: NSControl.StateValue)
}

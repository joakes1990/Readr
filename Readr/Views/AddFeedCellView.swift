//
//  AddFeedCellView.swift
//  Readr
//
//  Created by Justin Oakes on 9/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class AddFeedCellView: NSView {
    
    let titleLabel: NSTextField = NSTextField(labelWithString: "Feed Title")
    let checkBox: NSButton = NSButton(checkboxWithTitle: NSLocalizedString("Add Feed", comment: "AddFeed"), target: nil, action: nil)
    var feedTitle: String?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        titleLabel.font = NSFont.systemFont(ofSize: 24.0, weight: .heavy)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(checkBox)
        titleLabel.addConstraints(labelConstraints())
        checkBox.addConstraints(checkBoxConstraints())
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        titleLabel.font = NSFont.systemFont(ofSize: 24.0, weight: .heavy)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        addSubview(checkBox)
        titleLabel.addConstraints(labelConstraints())
        checkBox.addConstraints(checkBoxConstraints())
    }
    
    func labelConstraints() -> [NSLayoutConstraint] {
        let left: NSLayoutConstraint = NSLayoutConstraint(item: titleLabel,
                                                          attribute: .leading,
                                                          relatedBy: .equal,
                                                          toItem: self,
                                                          attribute: .left,
                                                          multiplier: 1.0,
                                                          constant: 20.0)
        let centerY: NSLayoutConstraint = NSLayoutConstraint(item: checkBox,
                                                             attribute: .centerY,
                                                             relatedBy: .equal,
                                                             toItem: self,
                                                             attribute: .centerX,
                                                             multiplier: 1.0,
                                                             constant: 0.0)
        return [left, centerY]
    }
    
    func checkBoxConstraints() -> [NSLayoutConstraint] {
        let right: NSLayoutConstraint = NSLayoutConstraint(item: checkBox,
                                                           attribute: .trailing,
                                                           relatedBy: .equal,
                                                           toItem: self,
                                                           attribute: .right,
                                                           multiplier: 1.0,
                                                           constant: 20.0)
        let centerY: NSLayoutConstraint = NSLayoutConstraint(item: checkBox,
                                                             attribute: .centerY,
                                                             relatedBy: .equal,
                                                             toItem: self,
                                                             attribute: .centerX,
                                                             multiplier: 1.0,
                                                             constant: 0.0)
        return [right, centerY]
    }
    
}

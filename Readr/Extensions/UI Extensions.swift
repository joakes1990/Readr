//
//  Segues.swift
//  Readr
//
//  Created by Justin Oakes on 9/9/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa
 
extension NSStoryboardSegue.Identifier {
    static let selectFeedsSegue = NSStoryboardSegue.Identifier(rawValue: "selectFeeds")
}

extension NSStoryboard.SceneIdentifier {
    static let selectFeeds = NSStoryboard.SceneIdentifier(rawValue: "selectFeeds")
}

extension NSNib.Name {
    static let addFeedCell = NSNib.Name(rawValue: "AddFeedCellView")
}

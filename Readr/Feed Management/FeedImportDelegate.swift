//
//  FeedImportDelegate.swift
//  Readr
//
//  Created by Justin Oakes on 9/13/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class FeedImportDelegate: NSObject, FeedImportProtocol {
    
    static let shared: FeedImportDelegate = FeedImportDelegate()
    
    func foundFeed(feed: ManagedFeed?) {
        //TODO: create Managed object and save to core data
    }
    
    func foundLinks(links: [Link]?) {
        var storyboard: NSStoryboard
        // Remove this check after min suported version >= 10.13
        if #available(OSX 10.13, *) {
            storyboard = NSStoryboard.main ?? NSStoryboard(name: .main, bundle: Bundle.main)
        } else {
            // Fallback on earlier versions
            storyboard = NSStoryboard(name: .main, bundle: Bundle.main)
        }
        if let nonOptLinks: [Link] = links {
            let selectFeedsView: SelectFeedsViewController = storyboard.instantiateController(withIdentifier: .selectFeeds) as? SelectFeedsViewController ?? SelectFeedsViewController()
            selectFeedsView.links = nonOptLinks
            selectFeedsView.presentViewControllerAsModalWindow(selectFeedsView)
        } else {
            return
        }
    }
    
    func returned(error: Error) {
        //TODO: Log error
    }
    
    
}

protocol FeedImportProtocol {
    func foundFeed(feed: ManagedFeed?)
    func foundLinks(links: [Link]?)
    func returned(error: Error)
}

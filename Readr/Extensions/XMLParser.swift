//
//  OklasoftXML.swift
//  OklasoftRSS
//
//  Created by Justin Oakes on 7/21/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation

public extension XMLParser {
    
    public func parseRSSFeed(fromParent url: URL) {
        let rssDelegate: RSSDelegate = RSSDelegate(with: url)
        externalEntityResolvingPolicy = .never
        delegate = rssDelegate
        parse()
    }
    
    public func parseAtomFeed(fromParent url: URL) {
        let atomDelegate: AtomDelegate = AtomDelegate(with: url)
        delegate = atomDelegate
        parse()
    }
    
    public func parseHTMLforFavIcon(fromSite url: URL) {
        let favIconDelegate: FavIconDelegate = FavIconDelegate(with: url)
        delegate = favIconDelegate
        parse()
    }
    
    public func parseHTMLforFeeds(fromSite url: URL) {
        let htmlDelegate: HTMLDelegate = HTMLDelegate(with: url)
        delegate = htmlDelegate
        parse()
    }
}

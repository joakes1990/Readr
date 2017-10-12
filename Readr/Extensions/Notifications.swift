//
//  Notifications.swift
//  Readr
//
//  Created by Justin Oakes on 22/9/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let favIconKey = "favIcon"
    static let newFeedKey = "newFeed"
    static let urlKey = "url"
    
    static let newFeedSaved = Notification.Name("newFeedSaved")
    static let foundFavIcon = Notification.Name("foundFavIcon")
    static let finishedFindingStories = Notification.Name("finishedFindingStories")
    static let newGroupCreated = Notification.Name(rawValue: "newGroupCreated")
    static let newPlaylistCreated = Notification.Name("newPlaylistCreated")
}

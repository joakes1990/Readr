//
//  FeedViewControllerDelegate.swift
//  Readr
//
//  Created by Justin Oakes on 8/21/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation
import OklasoftRSS

class ImportFeedObserver {
  
    var delegate: ImportProtocol?
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(feedIsValid(aNotification:)), name: .finishedReceavingFeed,
                                               object: nil)
    }
    
    class func urlIsUnique(_ url: String) {
    
    }
    
    @objc func feedIsValid(aNotification: Notification) -> Bool {
        delegate?.stopAnimation()
        guard let userInfo: [AnyHashable:Any] = aNotification.userInfo,
            let newFeed: Feed = userInfo[feedInfoKey] as? Feed
            else {
                return false
        }
        return true
    }
}

protocol ImportProtocol {
    func stopAnimation()
}

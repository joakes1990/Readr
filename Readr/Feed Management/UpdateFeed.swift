//
//  UpdateFeed.swift
//  Readr
//
//  Created by justin on 9/29/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation

class UpdateFeed {
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceaveUpdatedFevIcon(aNotification:)),
                                               name: .foundFavIcon,
                                               object: nil)
    }
    
    @objc func didReceaveUpdatedFevIcon(aNotification: Notification) {
        print("ready to update icon")
    }
}

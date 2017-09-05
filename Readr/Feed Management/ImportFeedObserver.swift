//
//  FeedViewControllerDelegate.swift
//  Readr
//
//  Created by Justin Oakes on 8/21/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation
import OklasoftRSS
import OklasoftNetworking

class ImportFeedObserver {
    
    var delegate: ImportProtocol?
    
    init() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(feedIsValid(aNotification:)),
                                               name: .finishedReceavingFeed,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(networkingErrorOccured(aNotification:)),
                                               name: .networkingErrorNotification,
                                               object: nil)
    }
    
    class func urlIsUnique(_ url: String) -> Bool {
        var unique: Bool = true
        let context: NSManagedObjectContext = (NSApplication.shared.delegate as! AppDelegate).persistentContainer.newBackgroundContext()
        let fetchRequest: NSFetchRequest<ManagedFeed> = NSFetchRequest(entityName: ManagedFeed.feedEntitty)
        fetchRequest.predicate = NSPredicate(format: "url = %@", url)
        do {
            let feeds: [NSManagedObject] = try context.fetch(fetchRequest)
            unique = feeds.count < 1
        } catch {
            unique = false
        }
        return unique
    }
    
    @objc func feedIsValid(aNotification: Notification) {
        guard let userInfo: [AnyHashable:Any] = aNotification.userInfo,
            let newFeed: Feed = userInfo[feedInfoKey] as? Feed
            else {
                delegate?.toggleModal(enable: false, message: unrecognizableDataError.localizedDescription)
                return
        }
        //TODO: insert new managed object into Coredate
        return
    }
    @objc func networkingErrorOccured(aNotification: Notification) {
        guard let userInfo: [AnyHashable : Any] = aNotification.userInfo,
            let error: Error = userInfo[errorInfoKey] as? Error else {
                delegate?.toggleModal(enable: true, message: NSLocalizedString("Network Error Occured", comment: "Network Error Occured"))
                return
        }
        delegate?.toggleModal(enable: true, message: error.localizedDescription)
    }
}

protocol ImportProtocol {
    func toggleModal(enable: Bool, message: String?)
    
}

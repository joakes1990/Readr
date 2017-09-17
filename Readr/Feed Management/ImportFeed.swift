//
//  ImportFeed.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class ImportFeed: RSSNetworkingDelegate {
    
    var delegateView: AddFeedViewController?
    var feeds: [ManagedFeed] = []
    static let shared: ImportFeed = ImportFeed()
    
    class func validProtocol(_ latestClip: String) -> Bool {
        do {
            let httpString: String = "^http://"
            let httpsString: String = "^https://"
            let feedString: String = "^feed://"
            
            let httpRegEx: NSRegularExpression = try NSRegularExpression(pattern: httpString)
            let httpsRegEx: NSRegularExpression = try NSRegularExpression(pattern: httpsString)
            let feedRegEx: NSRegularExpression = try NSRegularExpression(pattern: feedString)
            
            let httpMatch: [NSTextCheckingResult] = httpRegEx.matches(in: latestClip, range: NSRange(latestClip.startIndex..., in: latestClip))
            let httpsMatch: [NSTextCheckingResult] = httpsRegEx.matches(in: latestClip, range: NSRange(latestClip.startIndex..., in: latestClip))
            let feedMatch: [NSTextCheckingResult] = feedRegEx.matches(in: latestClip, range: NSRange(latestClip.startIndex..., in: latestClip))
            
            if (httpMatch.count > 0 || httpsMatch.count > 0 || feedMatch.count > 0) {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    class func urlFromClipboard() -> String? {
        let pasteBoard: NSPasteboard = NSPasteboard.general
        
        var clipBoardStrings: [String] = []
        
        for item: NSPasteboardItem in pasteBoard.pasteboardItems ?? [] {
            if let string: String = item.string(forType: NSPasteboard.PasteboardType.string) {
                clipBoardStrings.append(string)
            }
        }
        let latestClip: String = clipBoardStrings.count > 0 ? clipBoardStrings[0] : ""
        
        if ImportFeed.validProtocol(latestClip) {
            return latestClip
        } else {
            return nil
        }
    }
    
    func identifyFeed(at url: String) {
        guard let feedURL: URL = URL(string: url) else {
            let error: oklasoftError = invalidURLError
            delegateView?.returned(error: error)
            return
        }
        let appDellegate: AppDelegate? = NSApplication.shared.delegate as? AppDelegate
        let netManager: RSSNetworking? = appDellegate?.rssNetwork
        netManager?.delegate = self
        netManager?.identifyFeeds(url: feedURL)
    }
    
    func found(feeds: [ManagedFeed]) {
        self.feeds.append(contentsOf: feeds)
        let multipulFeedsString: String = NSLocalizedString("other feeds added", comment: "number of feeds added")
        let informitiveText: String = feeds.count > 1 ? "\(feeds[0].title) and \(feeds.count - 1) \(multipulFeedsString)" : "\(feeds[0].title) added"
        let singleTitle: String = NSLocalizedString("Added feed", comment: "Added feed")
        let multiTitle: String = NSLocalizedString("Added feeds", comment: "Added feeds")
        let notification: NSUserNotification = NSUserNotification()
        notification.title = feeds.count > 1 ? multiTitle : singleTitle
        notification.subtitle = NSLocalizedString("Somthing good happened", comment: "Somthing good happened")
        notification.informativeText = informitiveText
        
        for feed in feeds {
            createManagedFeedObjects(feed: feed)
        }
        
        DispatchQueue.main.async {
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
    
    func found(html: Data, from url: URL) {
        do {
            let xmlDocument: XMLDocument = try XMLDocument(data: html, options: .documentTidyXML)
            let parser: XMLParser = XMLParser(data: xmlDocument.xmlData)
            parser.parseHTMLforFeeds(fromSite: url, for: self)
        } catch {
            receavedNetworkError(error: error)
        }
    }
    
    func found(links: [Link]?) {
        if let returnedLinks: [Link] = links {
            unowned let unownedSelf: ImportFeed = self
            DispatchQueue.main.async {
                if #available(OSX 10.13, *) {
                    let selectView: SelectFeedsViewController = NSStoryboard.main?.instantiateController(withIdentifier: .selectFeeds) as? SelectFeedsViewController ?? SelectFeedsViewController()
                    selectView.presentViewControllerAsModalWindow(selectView)
                    selectView.displayLinks(links: returnedLinks)
                } else {
                    // Fallback on earlier versions
                    let selectView: SelectFeedsViewController = NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: Bundle.main).instantiateController(withIdentifier: .selectFeeds) as? SelectFeedsViewController ?? SelectFeedsViewController()
                    selectView.presentViewControllerAsModalWindow(selectView)
                    selectView.displayLinks(links: returnedLinks)
                }
                unownedSelf.delegateView?.dismiss(self)
            }
        }
    }
    
    func receavedNetworkError(error: Error) {
        //TODO: write error to logs
        print(error.localizedDescription)
        if delegateView != nil {
            unowned let unownedSelf: ImportFeed = self
            DispatchQueue.main.async {
                unownedSelf.delegateView?.returned(error: error)
            }
        } else {
            let notification: NSUserNotification = NSUserNotification()
            notification.title = NSLocalizedString("Could not add feed", comment: "Could not add feed")
            notification.subtitle = NSLocalizedString("Somthing not good happened", comment: "Somthing not good happened")
            notification.informativeText = NSLocalizedString("Readr could not find a feed or could not add a feed that was provided", comment: "Readr could not find a feed or could not add a feed that was provided")
            DispatchQueue.main.async {
                NSUserNotificationCenter.default.deliver(notification)
            }
        }
    }
    
    func createManagedFeedObjects(feed: ManagedFeed) {
        print(feed.url)
//        let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()
//        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
//        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ManagedFeed.feedEntitty, in: context)!
//        let managedFeed: NSManagedObject = NSManagedObject(entity: entity, insertInto: context)
//
//        managedFeed.setValue(feed.canonicalURL?.absoluteString, forKey: "canonicalURL")
    }
}

protocol ImportFeedDelegate {
    func foundFeed(feed: ManagedFeed?)
    func foundLinks(links: [Link]?)
    func returned(error: oklasoftError)
}

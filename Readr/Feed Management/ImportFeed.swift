//
//  ImportFeed.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class ImportFeed: RSSNetworkingDelegate {
    
    var delegate: AddFeedViewController?
    
    
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
            delegate?.returned(error: error)
            return
        }
        let appDellegate: AppDelegate? = NSApplication.shared.delegate as? AppDelegate
        let netManager: RSSNetworking? = appDellegate?.rssNetwork
        netManager?.delegate = self
        netManager?.identifyFeeds(url: feedURL)
    }
    
    func found(feeds: [Feed]) {
        print("I found feeds")
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
            }
        }
    }
    
    func receavedNetworkError(error: Error) {
        print(error.localizedDescription)
    }
}


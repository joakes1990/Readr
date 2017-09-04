//
//  ImportFeed.swift
//  Readr
//
//  Created by Justin Oakes on 8/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa
import OklasoftRSS
class ImportFeed {
    
    static let shared: ImportFeed = ImportFeed()
    
    let observer: ImportFeedObserver = ImportFeedObserver()
    
    func validProtocol(_ latestClip: String) -> Bool {
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
            
            if httpMatch.count > 0 || httpsMatch.count > 0 || feedMatch.count > 0 {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func urlFromClipboard() -> String? {
        let pasteBoard: NSPasteboard = NSPasteboard.general
        
        var clipBoardStrings: [String] = []
        
        for item: NSPasteboardItem in pasteBoard.pasteboardItems ?? [] {
            if let string: String = item.string(forType: NSPasteboard.PasteboardType.string) {
                clipBoardStrings.append(string)
            }
        }
        let latestClip: String = clipBoardStrings.count > 0 ? clipBoardStrings[0] : ""
        
        if validProtocol(latestClip) {
            return latestClip
        } else {
            return nil
        }
    }
    
    func identifyFeed(at url: String) {
        guard let feedURL: URL = URL(string: url) else {
            let error: Error = invalidURLError as Error
            NotificationCenter.default.post(name: .feedIdentificationError,
                                            object: nil,
                                            userInfo: [url : error])
            return
        }
        URLSession.shared.getReturnedDataFrom(url: feedURL, with: URLSession.identifyFeedsCompletion)
    }
}

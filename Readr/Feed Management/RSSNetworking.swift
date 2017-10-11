//
//  NetworkClosures.swift
//  OklasoftRSS
//
//  Created by Justin Oakes on 7/6/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

public class RSSNetworking {
    
    public var delegate: RSSNetworkingProtocol?
    
    public func createManagedFeedFrom(url: URL, with name: String) {
        unowned let unownedSelf: RSSNetworking = self
        
        // Attempts to find a news feeds at the provided URL.
        //If a url to an HTML page is found it will return all the links in the page's head with html or atom mimetypes
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, responce, error) in
            if let foundError:Error = error {
                unownedSelf.delegate?.receavedNetworkError(error: foundError)
                return
            }
            
            guard let headers: URLResponse = responce,
                let validData: Data = data,
                let typeString: String = headers.mimeType,
                let mimeType: mimeTypes = mimeTypes(rawValue:typeString)
                else {
                    let error: Error = unrecognizableDataError
                    unownedSelf.delegate?.receavedNetworkError(error: error)
                    return
            }
            var canonicalURL: URL? = nil
            
            let appDelegate: AppDelegate = NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ManagedFeed.feedEntitty, in: context)!
            let newFeed: ManagedFeed = NSManagedObject(entity: entity, insertInto: context) as! ManagedFeed
            
            switch mimeType {
            case .rss, .rssXML, .simpleRSS:
                canonicalURL = unownedSelf.parentURLForRSS(data: validData)
                
                newFeed.setValue(name, forKey: "title")
                newFeed.setValue(url.absoluteString, forKey: "url")
                newFeed.setValue(canonicalURL?.absoluteString, forKey: "canonicalURL")
                newFeed.setValue(NSDate.distantPast as NSDate, forKey: "lastUpdated")
                newFeed.setValue(mimeType.hashValue, forKey: "mimeType")
                newFeed.setValue(FeedController.shared.allFeedsCount(), forKey: "order")
                newFeed.requestNewFavIcon()
                newFeed.requestNewStories()
                
                unownedSelf.delegate?.found(feeds: [newFeed])
                do {
                    try context.save()
                    let userInfo: [AnyHashable : Any] = [Notification.Name.newFeedKey : newFeed]
                    NotificationCenter.default.post(name: .newFeedSaved,
                                                    object: nil,
                                                    userInfo: userInfo)
                } catch {
                    //TODO: Log inability to save nsmanged cotext
                    //Note this is called if the html mimetype is returned
                }
                break
            case .atom, .atomXML:
                if let hostString: String = url.host,
                    let protocolString: String = url.absoluteString.contains("https://") ? "https://\(hostString)" : "http://\(hostString)",
                    let hostURL: URL = URL(string: protocolString) {
                    canonicalURL = hostURL
                }
                
                newFeed.setValue(name, forKey: "title")
                newFeed.setValue(url.absoluteString, forKey: "url")
                newFeed.setValue(canonicalURL?.absoluteString, forKey: "canonicalURL")
                newFeed.setValue(NSDate.distantPast as NSDate, forKey: "lastUpdated")
                newFeed.setValue(mimeType.hashValue, forKey: "mimeType")
                newFeed.setValue(FeedController.shared.allFeedsCount(), forKey: "order")
                newFeed.requestNewFavIcon()
                newFeed.requestNewStories()
                
                unownedSelf.delegate?.found(feeds: [newFeed])
                do {
                    try context.save()
                    NotificationCenter.default.post(name: .newFeedSaved, object: nil)
                } catch {
                    //TODO: Log inability to save nsmanged cotext
                    //Note this is called if the html mimetype is returned
                }
                break
            case .html:
                context.delete(newFeed)
                unownedSelf.delegate?.found(html: validData, from: url)
            }
        })
        task.resume()
    }
    
    func parentURLForRSS(data: Data) -> URL? {
        guard let pageXML: String = String(data: data, encoding: .utf8),
            let linkRange: Range = pageXML.range(of: "(?<=<link>)(.+)(?=</link>)",
                                                 options: .regularExpression,
                                                 range: pageXML.range(of: pageXML),
                                                 locale: nil)
            else {
                return nil
        }
        
        let linkString: String = String(pageXML[linkRange]).contains("http://") || String(pageXML[linkRange]).contains("https://") ? String(pageXML[linkRange]) : "http://\(String(pageXML[linkRange]))"
        return URL(string: linkString)
    }
    
    func requestNewFavIcon(forURL url: URL) {
        if let favIcon: NSImage = clasicFavIconFor(url: url) {
            let userInfo: [AnyHashable : Any] = [Notification.Name.favIconKey : favIcon,
                                                 Notification.Name.urlKey : url]
            NotificationCenter.default.post(name: .foundFavIcon,
                                            object: nil,
                                            userInfo: userInfo)
            return
        }
        
        //        URLSession.shared.getReturnedDataFrom(url: url) { (data, responce, error) in
        //            if let foundError: Error = error {
        //                //TODO: Log error
        //                print(foundError)
        //                return
        //            }
        //            guard let validData: Data = data else {
        //                  return
        //            }
        //            do {
        //                let xmlDocument: XMLDocument = try XMLDocument(data: validData, options: .documentTidyHTML)
        //                let parser: XMLParser = XMLParser(data: xmlDocument.xmlData)
        //                parser.parseHTMLforFavIcon(fromSite: url)
        //            } catch {
        //                return
        //            }
        //        }
        
    }
    
    func requestNewStories(forURL url: URL, ofType type: mimeTypes) {
        URLSession.shared.getReturnedDataFrom(url: url) { (data, responce, error) in
            if let foundError: Error = error {
                //TODO: Log error
                print(foundError)
                return
            }
            guard let validData: Data = data else {
                return
            }
            do {
                let xmlDocument: XMLDocument = try XMLDocument(data: validData, options: .documentTidyXML)
                let parser: XMLParser = XMLParser(data: xmlDocument.xmlData)
                
                switch type {
                case .atomXML, .atom:
                    parser.parseAtomFeed(fromParent: url)
                    break
                case .rss, .rssXML, .simpleRSS:
                    parser.parseRSSFeed(fromParent: url)
                    break
                default:
                    break
                }
            } catch {
                return
            }
        }
    }
    
    func requestImageData(forStory story: ManagedStory, at url: URL) {
        URLSession.shared.getReturnedDataFrom(url: url) { (data, headers, error) in
            if let foundError: Error = error {
                //TODO: Log error
                print(foundError)
                return
            }
            guard let validData: Data = data else {
                return
            }
            story.image = validData as NSData
            do {
                try (NSApplication.shared.delegate as? AppDelegate ?? AppDelegate()).persistentContainer.viewContext.save()
            } catch {
                //TODO: Log error
                print(error)
            }
        }
    }
    
    func clasicFavIconFor(url: URL) -> NSImage? {
        guard let sanitizedString: String = url.host,
            let sanitizedURL: URL = URL(string: "http://\(sanitizedString)/favicon.ico"),
            let favIcon: NSImage = NSImage(contentsOf: sanitizedURL) else {
                return nil
        }
        return favIcon
    }
}

public protocol RSSNetworkingProtocol {
    func found(feeds: [ManagedFeed])
    func found(links: [Link]?)
    func found(html: Data, from url: URL)
    func receavedNetworkError(error: Error)
}

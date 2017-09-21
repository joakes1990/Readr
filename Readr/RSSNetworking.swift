//
//  NetworkClosures.swift
//  OklasoftRSS
//
//  Created by Justin Oakes on 7/6/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

public class RSSNetworking {
    
    public var delegate: RSSNetworkingDelegate?
    
    public func createManagedFeedFrom(url: URL, with name: String) {
        unowned let unownedSelf: RSSNetworking = self
        
        let task: URLSessionDataTask = URLSession.shared.dataTask(with: url, completionHandler: { (data, responce, error) in
            if let foundError:Error = error {
                unownedSelf.delegate?.receavedNetworkError(error: foundError)
                return
            }
            
            guard let headers: URLResponse = responce,
                let validData: Data = data,
                let typeString: String = headers.mimeType,
                let mimeType: mimeTypes = mimeTypes(rawValue:typeString),
                let url: URL = headers.url
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
                newFeed.setValue(NSDate(), forKey: "lastUpdated")
                newFeed.setValue(mimeType.hashValue, forKey: "mimeType")
                
                unownedSelf.delegate?.found(feeds: [newFeed])
                break
            case .atom, .atomXML:
                if let hostString: String = url.host,
                    let hostURL: URL = URL(string: hostString) {
                    canonicalURL = hostURL
                }
                
                newFeed.setValue(name, forKey: "title")
                newFeed.setValue(url.absoluteString, forKey: "url")
                newFeed.setValue(canonicalURL?.absoluteString, forKey: "canonicalURL")
                newFeed.setValue(NSDate(), forKey: "lastUpdated")
                newFeed.setValue(mimeType.hashValue, forKey: "mimeType")
                
                unownedSelf.delegate?.found(feeds: [newFeed])
                break
            case .html:
                context.delete(newFeed)
                unownedSelf.delegate?.found(html: validData, from: url)
            }
            do {
                try context.save()
            } catch {
                //TODO: Log inability to save nsmanged cotext
                //Note this is called if the html mimetype is returned
            }
        })
        task.resume()
    }
    
    static let identifyStoriesCompletion: URLSession.Completion = {(data, responce, error) in
        if let foundError:Error = error {
            //TODO: replace with protocol callback
//            NotificationCenter.default.post(name: .networkingErrorNotification,
//                                            object: nil,
//                                            userInfo:errorInfo(error: foundError).toDict())
            return
        }
        guard let headers: URLResponse = responce,
            let validData: Data = data,
            let mimeType: mimeTypes = mimeTypes(rawValue:(headers.mimeType ?? "")),
            let url: URL = headers.url
            else {
                return
        }
        switch mimeType {
        case .rss, .rssXML:
            let parser: XMLParser = XMLParser(data: validData)
            parser.parseRSSFeed(fromParent: url)
            break
        case .atom, .atomXML:
            let parser: XMLParser = XMLParser(data: validData)
            parser.parseAtomFeed(fromParent: url)
            break
            
        default:
            break
        }
    }
    
    static let findFeedsCompletion: URLSession.Completion = {(data, responce, error) in
        if let foundError:Error = error {
            //TODO: replace with protocol callback
//            NotificationCenter.default.post(name: .networkingErrorNotification,
//                                            object: nil,
//                                            userInfo:errorInfo(error: foundError).toDict())
            return
        }
        guard let headers: URLResponse = responce,
            let validData: Data = data,
            let mimeType: mimeTypes = mimeTypes(rawValue:(headers.mimeType ?? "")),
            let url: URL = headers.url
            else {
                return
        }
        switch mimeType {
        case .html:
            guard let htmlString: String = String(data: validData, encoding: .utf8) else {
                //TODO: replace with protocol callback
//                NotificationCenter.default.post(name: .errorConvertingHTML,
//                                                object: nil,
//                                                userInfo: [errorInfoKey:unrecognizableDataError])
                return
            }
            do {
                let document: XMLDocument = try XMLDocument(xmlString: htmlString, options: .documentTidyHTML)
                let parser: XMLParser = XMLParser(data: document.xmlData)
//                parser.parseHTMLforFeeds(fromSite: url, for: )
            } catch {
                //TODO: replace with protocol callback
//                NotificationCenter.default.post(name: .errorConvertingHTML,
//                                                object: nil,
//                                                userInfo: [errorInfoKey:unrecognizableDataError])
                return
            }
            break
        default:
            break
        }
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
        
        let linkString: String = String(pageXML[linkRange])
        return URL(string: linkString)
    }
}

public protocol RSSNetworkingDelegate {
    func found(feeds: [ManagedFeed])
    func found(links: [Link]?)
    func found(html: Data, from url: URL)
    func receavedNetworkError(error: Error)
}

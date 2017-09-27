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
                NotificationCenter.default.post(name: .newFeedSaved, object: nil)
            } catch {
                //TODO: Log inability to save nsmanged cotext
                //Note this is called if the html mimetype is returned
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
        
        let linkString: String = String(pageXML[linkRange])
        return URL(string: linkString)
    }
    
    func requestNewFavIcon(forURL url: URL) {
        URLSession.shared.getReturnedDataFrom(url: url, completion: <#T##URLSession.Completion##URLSession.Completion##(Data?, URLResponse?, Error?) -> Void#>)
    }
}

public protocol RSSNetworkingProtocol {
    func found(feeds: [ManagedFeed])
    func found(links: [Link]?)
    func found(html: Data, from url: URL)
    func receavedNetworkError(error: Error)
}

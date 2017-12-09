//
//  HTMLDelegate.swift
//  OklasoftRSS
//
//  Created by Justin Oakes on 8/8/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation

class HTMLDelegate: NSObject, XMLParserDelegate {
    
    var parsingHead: Bool = false
    let url: URL
    var caller: RSSNetworkingProtocol?
    fileprivate var links: [Link]?
    
    init(with url: URL) {
        self.url = url
        self.links = nil
        super.init()
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        //TODO: Log error
        if let linksArray: [Link] = links,
            linksArray.count > 0 {
            parserDidEndDocument(parser)
        }
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        guard let element: parsingElements = parsingElements(rawValue: elementName) else {
            return
        }
        switch element {
        case .head:
            parsingHead = true
            break
        case .link:
            if parsingHead {
                guard let type: mimeTypes = mimeTypes(rawValue:attributeDict["type"] ?? ""),
                    let link: String = attributeDict["href"],
                    let linkURL: URL = URL(string: link, relativeTo: url)
                    else {
                        return
                }
                if type == .html {
                    return
                }
                let newLink: Link = Link(link: linkURL,
                                         type: type,
                                         title: attributeDict["title"] ?? "\(linkURL.lastPathComponent)")
                links == nil ? links = [newLink] : links?.append(newLink)
            }
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        guard let element: parsingElements = parsingElements(rawValue: elementName) else {
            return
        }
        
        switch element {
        case .head:
            parsingHead = false
            break
        default:
            break
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        caller?.found(links: links)
    }
    
    private enum parsingElements: String {
        typealias rawValue = String
        
        case head = "head"
        case link = "link"
    }

}

public struct Link {
    let link: URL
    let type: mimeTypes
    let title: String
}

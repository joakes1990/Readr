//
//  FavIconDelegate.swift
//  OklasoftRSS
//
//  Created by Justin Oakes on 7/22/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation

class FavIconDelegate: NSObject, XMLParserDelegate {
    
    var parsingHead: Bool = false
    let url: URL
    fileprivate var foundIcon: Icon?
    
    init(with url: URL) {
        self.url = url
        self.foundIcon = nil
        super.init()
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
                guard let linkType: supportedLinkTypes = supportedLinkTypes(rawValue:attributeDict["rel"] ?? ""),
                    let link: String = attributeDict["href"],
                    let imageLink: URL = URL(string: link, relativeTo: url)
                    else {
                        return
                }
                // apple touch icons are higher res but less common. Try to use em if you can get em.
                if foundIcon == nil || foundIcon?.imageType != .touchIcon {
                    foundIcon = Icon(imageLink: imageLink, imageType: linkType)
                }
            }
            break
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        if let link: URL = foundIcon?.imageLink {
            //TODO: REplace with protocol callback
            NotificationCenter.default.post(name: .foundFavIcon,
                                            object: nil,
                                            userInfo: [url:link])
        } else {
            //TODO: REplace with protocol callback
//            NotificationCenter.default.post(name: .errorFindingStories,
//                                            object: nil,
//                                            userInfo: [errorInfoKey:parseError])
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
        if let link: URL = foundIcon?.imageLink {
            NotificationCenter.default.post(name: .foundFavIcon,
                                            object: nil,
                                            userInfo: [url:link])
        }
    }
    
    private enum parsingElements: String {
        typealias rawValue = String
        
        case head = "head"
        case link = "link"
    }
    
    enum supportedLinkTypes: String {
        typealias rawValue = String
        
        case favIcon = "shortcut icon"
        case touchIcon = "apple-touch-icon-precomposed"
    }
    
    public struct Icon {
        let imageLink: URL
        let imageType: supportedLinkTypes
    }
}

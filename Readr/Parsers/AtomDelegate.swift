//
//  AtomParser.swift
//  OklasoftRSS
//
//  Created by Justin Oakes on 7/16/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation

class AtomDelegate: RSSDelegate {
    
    fileprivate var element: parseValues?
    
    override func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        if let atomProperty: parseValues = parseValues(rawValue: elementName) {
            element = atomProperty
            
            switch atomProperty {
            case .link:
                if attributeDict["rel"] == "alternate" && attributeDict[parseValues.type.rawValue]?.contains(parseValues.html.rawValue) == true {
                    guard let altLink: String = attributeDict[parseValues.href.rawValue],
                        let altURL: URL = URL(string: altLink) else {
                            break
                    }
                    url = altURL
                }
                break
            case .entry:
                url = nil
                title = nil
                htmlContent = nil
                audioContent = nil
                pubDate = nil
                break
            case .content:
                if attributeDict[parseValues.type.rawValue]?.contains(parseValues.html.rawValue) == true {
                    element = .content
                }
                break
            case .updated:
                element = .updated
                break
            case .title:
                element = .title
                break
            default:
                break
            }
        }
    }
    
    override func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let hasElement: parseValues = element else {
            return
        }
        switch hasElement {
        case .title:
            guard let prefix: String = title else {
                title = string
                break
            }
            title = "\(prefix)\(string)"
            break
        case .updated:
            pubDate = rfc3339DateFromString(string: string)
            break
        case .content:
            guard let prefix: String = htmlContent else {
                htmlContent = string
                break
            }
            htmlContent = "\(prefix)\(string)"
            break
        default:
            break
        }
    }
    
    override func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let atomProperty: parseValues = parseValues(rawValue: elementName) {
            switch atomProperty {
            case .entry:
                pushStory()
                break
            default:
                element = nil
                break
            }
        }
    }
    
    func rfc3339DateFromString(string: String) -> Date? {
        if #available(OSX 10.12, iOS 10.0, *) {
            let dateFormater: ISO8601DateFormatter = ISO8601DateFormatter()
            return dateFormater.date(from:string)
        } else {
            let RFC3339Date = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let dateFormater: DateFormatter = DateFormatter()
            dateFormater.dateFormat = RFC3339Date
            return dateFormater.date(from:string)
        }
    }
    fileprivate enum parseValues: String {
        typealias rawValue = String
        
        // Tag names
        case entry = "entry" //between tags
        case title = "title" //between tags
        case link = "link" // in atttabutes
        case content = "content" //between tags but need to read the attributes to know what king of data you're dealing with. figure out if i should use content or summery on case by case
        case updated = "updated" //between tags
        // attribute names and values
        case type = "type"
        case html = "html"
        case href = "href"
    }
}

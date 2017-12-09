//
//  RSSParser.swift
//  OklasoftRSS
//
//  Created by Justin Oakes on 7/14/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation

class RSSDelegate: NSObject, XMLParserDelegate {
    
    var stories: [Story] = []
    fileprivate var element: parseValues?
    
    let feedURL: URL
    var url: URL?
    var title: String?
    var htmlContent: String?
    var audioContent: [URL]?
    var pubDate: Date?
    var image: URL?
    
    init(with url: URL) {
        self.feedURL = url
        super.init()
    }
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if let rssProperty: parseValues = parseValues(rawValue: elementName) {
            switch rssProperty {
            case .enclosure:
                if let _: mediaMimeTypes = mediaMimeTypes(rawValue: attributeDict["type"] ?? ""),
                    let audioLocation: String = attributeDict["url"],
                    let audioURL: URL = URL(string: audioLocation) {
                    guard var podcasrURLs: [URL] = audioContent else {
                        audioContent = [audioURL]
                        break
                    }
                    podcasrURLs.append(audioURL)
                }
                break
            case .item:
                url = nil
                title = nil
                htmlContent = nil
                audioContent = nil
                pubDate = nil
                break
            case .podcastImage:
                guard let imageLink: String = attributeDict["href"],
                    let imageURL: URL = URL(string: imageLink) else {
                        break
                }
                image = imageURL
                break
            default:
                break
            }
            element = rssProperty
        }
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
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
        case .link:
            guard let itemURL = URL(string: string) else {
                return
            }
            url = itemURL
            break
        case .description:
            guard let prefix: String = htmlContent else {
                htmlContent = string
                break
            }
            htmlContent = "\(prefix)\(string)"
            break
        case .pubDate:
            pubDate = rfc822DateFromString(string: string)
            break
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let rssProperty: parseValues = parseValues(rawValue: elementName) {
            switch rssProperty {
            case .item:
                pushStory()
                break
            default:
                element = nil
                break
            }
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if stories.count > 0 {
            let notification: NSUserNotification = NSUserNotification()
            notification.title = NSLocalizedString("New stories are available", comment: "New stories are available")
            DispatchQueue.main.async {
                NSUserNotificationCenter.default.deliver(notification)
            }
            NotificationCenter.default.post(name: .finishedFindingStories,
                                            object: nil,
                                            userInfo: [feedURL:stories])
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        if stories.count > 0 {
            let notification: NSUserNotification = NSUserNotification()
            notification.title = NSLocalizedString("New stories are available", comment: "New stories are available")
            DispatchQueue.main.async {
                NSUserNotificationCenter.default.deliver(notification)
            }
            NotificationCenter.default.post(name: .finishedFindingStories,
                                            object: nil,
                                            userInfo: [feedURL:stories])
        }
    }
    
    func rfc822DateFromString(string: String) -> Date? {
        let RFC822Date1: String = "EEE, dd MMM yyyy HH:mm:ss zzz"
        let RFC822Date2: String = "EEE, dd MMM yyyy HH:mm:ss Z"
        let dateFormater: DateFormatter = DateFormatter()
        
        dateFormater.dateFormat = RFC822Date1
        
        if let validDate: Date = dateFormater.date(from: string) {
            return validDate
        } else {
            dateFormater.dateFormat = RFC822Date2
            return dateFormater.date(from: string)
        }
    }
    
    func pushStory() {
        
        
        guard let storyURL: URL = url,
            let storyTitle: String = title,
            let storyHTML: String = htmlContent?.stringByDecodingHTMLEntities,
            let storyDate: Date = pubDate
            else {
                return
        }
        let newStory: baseStory = baseStory(title: storyTitle,
                                            url: storyURL,
                                            textContent: storyHTML.stringByStrippingHTMLTags,
                                            htmlContent: storyHTML,
                                            pubdate: storyDate,
                                            read: false,
                                            feedURL: feedURL,
                                            author: nil)
        if let storyaudio: [URL] = audioContent,
            let storyImage: URL = image {
            let podCast: PodCast = PodCast(story: newStory, audio: storyaudio, imageURL: storyImage)
            stories.append(podCast)
        } else {
            stories.append(newStory)
        }
    }
    
    
    fileprivate enum parseValues: String {
        typealias rawValue = String
        
        case item = "item"
        case title = "title"
        case link = "link"
        case description = "description"
        case pubDate = "pubDate"
        case enclosure = "enclosure"
        case podcastImage = "itunes:image"
        
    }
}

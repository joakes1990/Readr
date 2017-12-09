//
//  RSSsupport.swift
//  OklasoftRSS
//
//  Created by Justin Oakes on 7/8/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Foundation
    
    public protocol Story {
        
        var title: String {get}
        var url: URL {get}
        var textContent: String {get}
        var htmlContent: String {get}
        var pubdate: Date {get}
        var read: Bool {get set}
        var feedURL: URL {get}
        var author: String? {get}
    }
    
    public struct baseStory: Story {
        public let title: String
        public let url: URL
        public let textContent: String
        public let htmlContent: String
        public let pubdate: Date
        public var read: Bool
        public let feedURL: URL
        public let author: String?
    }
    
    public class PodCast: Story {
        
        public let title: String
        public let url: URL
        public let textContent: String
        public let htmlContent: String
        public let pubdate: Date
        public var read: Bool
        public let feedURL: URL
        public let author: String?
        
        let audioContent: [URL]
        let imageURL: URL
        var image: Data?
        
        init(story: Story, audio: [URL], imageURL: URL) {
            self.title = story.title
            self.url = story.url
            self.textContent = story.textContent
            self.htmlContent = story.htmlContent
            self.pubdate = story.pubdate
            self.read = story.read
            self.feedURL = story.feedURL
            self.author = story.author
            self.audioContent = audio
            self.imageURL = imageURL
            self.image = nil
            
        }
        
        func setImage(imageData: Data) {
            image = imageData
        }
        
        func setImageFromNotification(anotification: Notification) {
            
        }
    }
    
    public enum mimeTypes: String {
        public typealias rawValue = String
        
        case atom = "application/atom"
        case atomXML = "application/atom+xml"
        case rss = "application/rss"
        case rssXML = "application/rss+xml"
        case simpleRSS = "text/xml"
        case html = "text/html"
    }
    
    public enum mediaMimeTypes: String {
        public typealias rawValue = String
        
        case m4a = "audio/x-m4a"
        case mpegA = "audio/mpeg"
        case mpeg3 = "audio/mpeg3"
        case xmpeg3 = "audio/x-mpeg-3"
        case aac = "audio/aac"
        case mp4A = "audio/mp4"
    }
    
    enum faviconMimeTypes: String {
        typealias rawValue = String
        
        case microsoft = "image/vnd.microsoft.icon"
        case icon = "image/x-icon"
    }


//
//  StoryController.swift
//  Readr
//
//  Created by Justin Oakes on 7/10/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class StoryController {
    
    static let shared: StoryController = StoryController()
    
    var allStories: [ManagedStory]?
    
    init() {
        updateStoriesArray()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateStoriesArray),
                                               name: .finishedFindingStories,
                                               object: nil)
    }
    
    func populateAllStories() -> [ManagedStory] {
        let appDelegate: AppDelegate = NSApplication.shared.delegate  as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedStory> = NSFetchRequest(entityName: ManagedStory.storyEntity)
        let sortDescripter: NSSortDescriptor = NSSortDescriptor(key: "pubdate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescripter]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    @objc func updateStoriesArray() {
        allStories = populateAllStories()
    }
    
    func allStoriesCount() -> Int16 {
        return Int16(populateAllStories().count)
    }
}

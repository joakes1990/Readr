//
//  PlaylistController.swift
//  Readr
//
//  Created by justin on 10/12/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class PlaylistController {
    
    static let shared: PlaylistController = PlaylistController()
    
    var allPlatlists: [ManagedPlaylist]?
    
    init() {
        updatePlaylistArray()
    }
    
    func updatePlaylistArray() {
        allPlatlists = populateAllPlaylists()
    }
    
    func populateAllPlaylists() -> [ManagedPlaylist] {
        let appDelegate: AppDelegate = NSApplication.shared.delegate  as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedPlaylist> = NSFetchRequest(entityName: ManagedPlaylist.playlistEntity)
        let sortDescripter: NSSortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescripter]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func allPlaylistCount() -> Int16 {
        return Int16(populateAllPlaylists().count)
    }
    
    func createPlaylist(with name: String?) {
        let appDelegate: AppDelegate = NSApplication.shared.delegate  as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ManagedPlaylist.playlistEntity, in: context)!
        let newPlaylist: ManagedPlaylist = NSManagedObject(entity: entity, insertInto: context) as! ManagedPlaylist
        
        if let goodName: String = name {
            newPlaylist.name = goodName
        }
        newPlaylist.order = allPlaylistCount() - 1
        do {
            updatePlaylistArray()
            try context.save()
            NotificationCenter.default.post(name: .newPlaylistCreated, object: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
}

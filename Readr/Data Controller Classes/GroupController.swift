//
//  GroupController.swift
//  Readr
//
//  Created by justin on 10/11/17.
//  Copyright © 2017 Oklasoft LLC. All rights reserved.
//

import Cocoa

class GroupController {
    
    static let shared: GroupController = GroupController()
    
    var allGroups: [ManagedGroup]?
    
    init() {
        updateGroupsArray()
        
    }
    
    func updateGroupsArray() {
        allGroups = populateAllGroups()
    }
    
    func populateAllGroups() -> [ManagedGroup] {
        let appDelegate: AppDelegate = NSApplication.shared.delegate  as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ManagedGroup> = NSFetchRequest(entityName: ManagedGroup.groupEntitty)
        let sortDescripter: NSSortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescripter]
        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }
    
    func allGroupsCount() -> Int16 {
        return Int16(populateAllGroups().count)
    }
    
    func createGroup(with name: String?) {
        let appDelegate: AppDelegate = NSApplication.shared.delegate  as? AppDelegate ?? AppDelegate()
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let entity: NSEntityDescription = NSEntityDescription.entity(forEntityName: ManagedGroup.groupEntitty, in: context)!
        let newGroup: ManagedGroup = NSManagedObject(entity: entity, insertInto: context) as! ManagedGroup
        
        if let goodName: String = name {
            newGroup.name = goodName
            NotificationCenter.default.post(name: .newGroupCreated, object: nil)
        }
        newGroup.order = allGroupsCount() - 1
        do {
            updateGroupsArray()
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        
    }
}

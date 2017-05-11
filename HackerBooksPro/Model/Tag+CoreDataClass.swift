//
//  Tag+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//

import Foundation
import CoreData


// This class represents a book tag in the system

@objc(Tag)
public class Tag: NSManagedObject {
    
    // Model entity name for this class
    static let entityName = "Tag"
    
    
    // Initializer (convenience so that CoreData can invoke super.init() from outside)
    convenience init(name: String, proxyForSorting: String, inContext context: NSManagedObjectContext) {
        
        // Get the appropiate model entity, then create a new entity of that kind in the given context
        let ent = NSEntityDescription.entity(forEntityName: Tag.entityName, in: context)!
        self.init(entity: ent, insertInto: context)
        
        // Assign initial values to the properties
        self.name = name
        self.proxyForSorting = proxyForSorting
    }
}

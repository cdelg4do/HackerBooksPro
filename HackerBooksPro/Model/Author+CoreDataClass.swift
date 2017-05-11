//
//  Author+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//

import Foundation
import CoreData


// This class represents a book author in the system

@objc(Author)
public class Author: NSManagedObject {
    
    // Model entity name for this class
    static let entityName = "Author"
    
    // Initializer (convenience so that CoreData can invoke super.init() from outside)
    convenience init(name: String, inContext context: NSManagedObjectContext) {
        
        // Get the appropiate model entity, then create a new entity of that kind in the given context
        let ent = NSEntityDescription.entity(forEntityName: Author.entityName, in: context)!
        self.init(entity: ent, insertInto: context)
        
        // Assign initial values to the properties
        self.name = name
    }

}

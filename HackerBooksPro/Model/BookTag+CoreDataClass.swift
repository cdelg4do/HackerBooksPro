//
//  BookTag+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//

import Foundation
import CoreData


// This class connects a Book with a Tag in the system

@objc(BookTag)
public class BookTag: NSManagedObject {
    
    // Model entity name for this class
    static let entityName = "BookTag"
    
    
    // Initializer (convenience so that CoreData can invoke super.init() from outside)
    convenience init(book: Book, tag: Tag, inContext context: NSManagedObjectContext) {
        
        // Get the appropiate model entity, then create a new entity of that kind in the given context
        let ent = NSEntityDescription.entity(forEntityName: BookTag.entityName, in: context)!
        self.init(entity: ent, insertInto: context)
        
        // Assign initial values to the properties
        self.book = book
        self.tag = tag
    }

}

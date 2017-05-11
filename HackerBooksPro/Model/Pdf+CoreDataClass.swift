//
//  Pdf+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//

import Foundation
import CoreData


// This class represents a Pdf document in the system

@objc(Pdf)
public class Pdf: NSManagedObject {
    
    // Model entity name for this class
    static let entityName = "Pdf"
    
    
    // Initializer (convenience so that CoreData can invoke super.init() from outside)
    convenience init(url: String, inContext context: NSManagedObjectContext) {
        
        // Get the appropiate model entity, then create a new entity of that kind in the given context
        let ent = NSEntityDescription.entity(forEntityName: Pdf.entityName, in: context)!
        self.init(entity: ent, insertInto: context)
        
        // Assign initial values to the properties (only the url)
        self.url = url
    }
}

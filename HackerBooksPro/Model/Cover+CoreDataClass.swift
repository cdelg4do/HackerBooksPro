//
//  Cover+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//

import Foundation
import CoreData
import UIKit   // to use UIImage


// This class represents a cover image in the system

@objc(Cover)
public class Cover: NSManagedObject {
    
    // Model entity name for this class
    static let entityName = "Cover"
    
    // Calculated variable to manage the cover image as UIImage, instead NSData which is the model internal type.
    // Also, this prevents from errors between Cocoa (NSData) and Swift (Data).
    var image: UIImage? {
        
        // Getter -> if image data are empty, return nil. If not, return a new UIImage from the data
        get {
            guard let data = coverData else {
                return nil
            }
            
            return UIImage(data: data as Data)!
        }
        
        // Setter -> if the new value is not nil, convert it to a JPG binary representation (Data) and store it as NSData.
        set {
            guard let img = newValue else {
                self.coverData = nil
                return
            }
            
            coverData = UIImageJPEGRepresentation(img, 1.0) as NSData?
        }
    }
    
    // Initializer (convenience so that CoreData can invoke super.init() from outside)
    convenience init(url: String, inContext context: NSManagedObjectContext) {
        
        // Get the appropiate model entity, then create a new entity of that kind in the given context
        let ent = NSEntityDescription.entity(forEntityName: Cover.entityName, in: context)!
        self.init(entity: ent, insertInto: context)
        
        // Assign initial values to the properties (only the url)
        self.url = url
    }
}

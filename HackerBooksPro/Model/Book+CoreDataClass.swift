//
//  Book+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//

import Foundation
import CoreData


// This class represents a book in the system

@objc(Book)
public class Book: NSManagedObject {
    
    // Model entity name for this class
    static let entityName = "Book"
    
    
    // Initializer (convenience so that CoreData can invoke super.init() from outside)
    convenience init(title: String, cover: Cover, pdf: Pdf, inContext context: NSManagedObjectContext) {
        
        // Get the appropiate model entity, then create a new entity of that kind in the given context
        let ent = NSEntityDescription.entity(forEntityName: Book.entityName, in: context)!
        self.init(entity: ent, insertInto: context)
        
        // Assign initial values to the properties
        self.title = title
        self.cover = cover
        self.pdf = pdf
    }
    
}


//MARK: class extension --> auxiliary functions

extension Book {
    
    // Function to get a comma-separated String with the authors
    func authorsToString() -> String {
        
        if self.authors == nil {
            
            return "<This book has no authors>"
        }
        
        var bookAuths = ""
        var i = 0
        
        for author in self.authors! {
            
            let authorName = (author as! Author).name
            bookAuths += authorName!
            i += 1
            
            if (i<(self.authors?.count)!) {
                bookAuths += ", "
            }
        }
        
        return bookAuths
    }
    
    
    // Function to get a comma-separated String with the tags
    // (if the book is in favorites, that tag will appear first)
    func tagsToString() -> String {
        
        if self.bookTags == nil || self.bookTags?.count == 0 {
            
            return "<This book has no tags>"
        }
        
        var favTagName = ""
        var tagString = ""
        var tagCounter = 0
        
        for bookTag in self.bookTags! {
            
            if (bookTag as! BookTag).tag?.proxyForSorting == "_favorites" {
                favTagName = ((bookTag as! BookTag).tag?.name)!
            }
                
            else {
                let tagName = (bookTag as! BookTag).tag?.name
                tagString += tagName!
                tagCounter += 1
                
                if (tagCounter<(self.bookTags?.count)!) {
                    tagString += ", "
                }
            }
        }
        
        if favTagName != "" {
            if tagCounter > 0   {   tagString = favTagName + ", " + tagString   }
            else                {   tagString = favTagName                      }
        }
        
        return tagString
    }
    
}

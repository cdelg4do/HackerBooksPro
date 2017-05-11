//
//  JsonProcessing.swift
//  HackerBooks
//
//  Created by Carlos Delgado on 10/07/16.
//

import Foundation
import UIKit
import CoreData     // to use NSManagedObjectContext


// This file contains all necessary functions to perform JSON processing operations


// Aliases for custom types used when processing JSON data
typealias JsonObject        = AnyObject
typealias JsonDictionary    = [String : JsonObject]
typealias JsonList          = [JsonDictionary]

// Alias for a closure that receives a Bool
typealias boolClosure = (Bool) -> ()


// Function that downloads a remote JSON file and then loads the data to the model (all in background)
func generateData(fromRemoteUrl url: String,
                  inContext context: NSManagedObjectContext,
                  activityIndicator: UIActivityIndicatorView?,
                  completion: @escaping boolClosure) -> () {
    
    print("\nGenerating initial data from a remote JSON...\n")
    activityIndicator?.isHidden = false
    activityIndicator?.startAnimating()
    
    DispatchQueue.global(qos: .userInitiated).async {
        
        let jsonData: JsonList?
        
        // Download the remote data in background
        do {
            jsonData = downloadJson(fromUrl: url)
            if jsonData == nil {  throw JsonError.unableToGetDataFromRemoteJson   }
        }
        
        // If errors happened, call the completion closure with "false" in the main queue
        catch {
            DispatchQueue.main.async {
                activityIndicator?.stopAnimating()
                activityIndicator?.isHidden = true
            
                completion(false)
                return
            }
        }
        
        // Processing of the downloaded data (in background)
        decodeBookList(fromList: jsonData!, inContext: context)
        
        // Once the data is loaded into the model, call the completion closure with "true" in the main queue
        DispatchQueue.main.async {
            activityIndicator?.stopAnimating()
            activityIndicator?.isHidden = true
            
            completion(true)
            return
        }
    }
}


// Attempts to download a remote file, then parses and returns its contents (or nil, in case of failure)
func downloadJson(fromUrl urlString: String) -> JsonList? {
    
    print("\nDownloading remote JSON from \(urlString)...")
    
    let fileData: Data?
    guard let url = URL(string: urlString) else { return nil }
    
    do {
        fileData = try Data(contentsOf: url)
    }
    catch { return nil }
    
    if fileData == nil {
        return nil
    }
    
    
    print("\nParsing downloaded data...")
    
    guard let maybeList = try? JSONSerialization.jsonObject(with: fileData!, options: JSONSerialization.ReadingOptions.mutableContainers) as? JsonList, let jsonList = maybeList
        else {
            return nil
        }
    
    return jsonList
}


// Attempts to build the model objects from the parsed JSON data
// (in case some element fails -i.e. is not valid-, a warning is logged but the process continues with the next element)
func decodeBookList(fromList jsonList: JsonList, inContext context: NSManagedObjectContext) -> () {
    
    print("\nBuilding model objects from the parsed data...\n")
    
    for jsonElement in jsonList {
        
        do {
            try decodeBook(fromElement: jsonElement, inContext: context)
        }
        catch {
            print("\n** Error processing a JSON element: \(jsonElement) **\n")
        }
    }
    
    // Last, create the "My favorites" tag
    // (make its proxy for sorting start with "_", so it will appear first in the library)
    let _ = Tag(name: "My Favorites", proxyForSorting: "_favorites", inContext: context)
}


// Attempts to create a new Book object from a JSON element
func decodeBook(fromElement json: JsonDictionary, inContext context: NSManagedObjectContext) throws -> () {
    
    // First, extract all the necessary fields:
    
    // Book title
    guard let bookTitle = json["title"] as? String else { throw JsonError.wrongJSONFormat }
    
    // Cover image URL (make sure its a valid url)
    guard let imageUrlString = json["image_url"] as? String else { throw JsonError.wrongJSONFormat }
    guard NSURL(string: imageUrlString) != nil              else { throw JsonError.wrongURLFormatForJSONResource }
    
    // Pdf URL (make sure its a valid url)
    guard let pdfUrlString = json["pdf_url"] as? String     else { throw JsonError.wrongJSONFormat }
    guard NSURL(string: pdfUrlString) != nil                else { throw JsonError.wrongURLFormatForJSONResource }
    
    // Book authors
    guard let authorsString = json["authors"] as? String    else { throw JsonError.wrongJSONFormat }
    let bookAuthors = authorsString.components(separatedBy: ", ")
    
    // Book tags
    guard let tagsString = json["tags"] as? String          else { throw JsonError.wrongJSONFormat }
    let bookTags = tagsString.components(separatedBy: ", ")
    
    
    // If no errors were thrown, now create and connect all the managed objects:
    
    // Cover and Pdf (initially, both contain only the URLs)
    let bookCover = Cover(url: imageUrlString, inContext: context)
    let bookPdf = Pdf(url: pdfUrlString, inContext: context)
    
    // Create the new Book and associate it to the cover and Pdf objects
    let newBook = Book(title: bookTitle, cover: bookCover, pdf: bookPdf, inContext: context)
    
    // For each book author, get a reference to it and associate it to the book
    // (if that author does not exist yet, create it first)
    let authorsReq = NSFetchRequest<Author>(entityName: Author.entityName)
    
    for authorName in bookAuthors {
        
        let thisAuthor: Author
        let result: [Author]
        
        authorsReq.predicate = NSPredicate(format: "name == %@", authorName)
        
        do {    result = try context.fetch(authorsReq)  }
        catch { throw CoreDataError.fetchRequestFailure }
        
        if result.count == 0 {  thisAuthor = Author(name: authorName, inContext: context)   }
        else                 {  thisAuthor = result.first!                                  }
        
        newBook.addToAuthors(thisAuthor)
    }
    
    
    // For each book tag, get a reference to it and associate it to the book by creating a new BookTag object
    // (if that tag does not exist yet, create it first)
    let tagsReq = NSFetchRequest<Tag>(entityName: Tag.entityName)
    tagsReq.fetchBatchSize = 50
    tagsReq.sortDescriptors = [ NSSortDescriptor(key: "name", ascending: false) ]
    
    for tagName in bookTags {
        
        let thisTag: Tag
        let result: [Tag]
        
        tagsReq.predicate = NSPredicate(format: "name == %@", tagName)
        
        do {    result = try context.fetch(tagsReq)     }
        catch { throw CoreDataError.fetchRequestFailure }
        
        if result.count == 0 {  thisTag = Tag(name: tagName, proxyForSorting: tagName, inContext: context)  }
        else                 {  thisTag = result.first!                                                     }
        
        let _ = BookTag(book: newBook, tag: thisTag, inContext: context)
    }
}


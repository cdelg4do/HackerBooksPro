//
//  BookViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 29/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit
import CoreData     // to use NSManagedObjectContext


// This class is the view controller to show the detail of a book

class BookViewController: UIViewController {
    
    var currentBook: Book
    var context: NSManagedObjectContext
    
    
    //MARK: Reference to UI elements
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var bookCover: UIImageView!
    
    
    //MARK: Initializers
    
    init(currentBook: Book, context: NSManagedObjectContext) {
        
        self.currentBook = currentBook
        self.context = context
        
        super.init(nibName: "BookViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: view lifecycle events
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activity?.isHidden = true
        activity?.stopAnimating()
        
        bookCover.image = UIImage(named: "book_cover.png")
        
        syncViewFromModel(includingCover: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        syncCoverImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    
    //MARK: Actions from the UI elements
    
    // 'Show PDF' button
    @IBAction func showPdf(_ sender: AnyObject) {
        
        let pdfVC = PdfViewController(currentBook: currentBook, context: context)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Detail",
                                                           style: UIBarButtonItemStyle.plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationController?.pushViewController(pdfVC, animated: true)
    }
    
    
    // 'Toggle favorite' button
    @IBAction func toggleFavorite(_ sender: AnyObject) {
        
        // Check if there is a BookTag match with this book and the favorites tag
        let bookTagReq = NSFetchRequest<BookTag>(entityName: BookTag.entityName)
        let filterByTag = NSPredicate(format: "tag.proxyForSorting == %@", "_favorites")
        let filterByBook = NSPredicate(format: "book == %@", currentBook)
        bookTagReq.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterByTag, filterByBook])
        let res = try! context.fetch(bookTagReq)
        
        // If no matches were found, add the book to favorites
        if res.count == 0 {
            print("\nAdding book to favorites...\n")
            
            // Get the favorites tag
            let tagReq = NSFetchRequest<Tag>(entityName: Tag.entityName)
            tagReq.predicate = NSPredicate(format: "proxyForSorting == %@", "_favorites")
            let res1 = try! context.fetch(tagReq)
            let favoritesTag = res1.first!
            
            // Create a neew BookTag with this book and the favorites tag
            let _ = BookTag(book: currentBook, tag: favoritesTag, inContext: context)
            try! context.save()
        }
        
        // If matches were found (should not be more than one), remove the book from favorites
        else {
            print("\nRemoving the book from favorites...\n")
            
            context.delete(res.first!)
            try! context.save()
        }
        
        // Last, sync the view using the updated data
        syncViewFromModel(includingCover: false)
    }
    
    
    // 'Show notes' button
    @IBAction func showNotes(_ sender: AnyObject) {
        
        // Fetch request to search all notes of this book
        // (loaded in groups of 50, sorted by page number)
        let fr = NSFetchRequest<Note>(entityName: Note.entityName)
        fr.predicate = NSPredicate(format: "book == %@", currentBook)
        fr.fetchBatchSize = 50
        fr.sortDescriptors = [ NSSortDescriptor(key: "page", ascending: true) ]
        
        // Create the fetchResultsController for that fetch request
        let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Create the controller to show the results, and show it
        let notesVC = NotesViewController(bookTitle: currentBook.title!, fetchedResultsController: fc as! NSFetchedResultsController<NSFetchRequestResult>)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Detail",
                                                           style: UIBarButtonItemStyle.plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationController?.pushViewController(notesVC, animated: true)
    }
    
    
    //MARK: Auxiliary functions
    
    // Updates the view using the book data
    // (optionally, the book cover will be updated too)
    func syncViewFromModel(includingCover syncCover: Bool) {
        
        title = currentBook.title
        
        authorsLabel.text = currentBook.authorsToString()
        tagsLabel.text = currentBook.tagsToString()
        
        if syncCover {  syncCoverImage()    }
    }
    
    
    // Updates the book cover view
    func syncCoverImage() {
        
        let imageData = currentBook.cover?.coverData
        
        // If the database already has the cover image, show it on screen
        if imageData != nil {
            bookCover.image = UIImage(data: imageData as! Data)
            bookCover.alpha = 1.0
        }
        
        // If not, attempt to download the image (in the backgrond), then update the model and the view
        else {
            let urlString = (currentBook.cover?.url)!
            
            print("\nDownloading remote image...\n(\(urlString))\n")
            
            Utils.asyncDownloadImage(fromUrl: urlString, mustResize: true, activityIndicator: activity) { (image: UIImage?) in
                
                if image != nil {
                    print("\nImage successfully downloaded!\n")
                    
                    self.currentBook.cover?.image = image
                    
                    self.bookCover.image = image
                    self.bookCover.alpha = 1.0
                }
                else {
                    print("\nERROR: Unable to download remote image\n")
                }
            }
        }
    }
    
}

//
//  PdfViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit

import CoreData     // to use NSManagedObjectContext
import CoreGraphics // to use CGFloat


// This class is the view controller to show the PDF of a book

class PdfViewController: UIViewController {
    
    var currentBook: Book
    var context: NSManagedObjectContext
    
    // This variable registers the current page shown
    // When its value changes, a check is done in background to see if the new page has notes associated to it
    // (depending on the result, the 'add note' / 'edit note' buttons will be enabled or disabled)
    var lastPageShown : Int {
        
        didSet {
            DispatchQueue.global(qos: .userInitiated).async {
                
                if (self.lastPageShown > 0) {
                    
                    if self.hasNotes(pageNumber: self.lastPageShown) {
                        
                        DispatchQueue.main.async {
                            print("\nThe page (\(self.lastPageShown)) has a note associated to it\n")
                            
                            self.viewNoteButton.isEnabled = true
                            self.newNoteButton.isEnabled = false
                        }
                    }
                    
                    else {
                        DispatchQueue.main.async {
                            print("\nThe page (\(self.lastPageShown)) does NOT have notes associated to it\n")
                            
                            self.viewNoteButton.isEnabled = false
                            self.newNoteButton.isEnabled = true
                        }
                    }
                }
            
            }
        }
        
    }
    
    
    //MARK: Reference to UI elements
    @IBOutlet weak var pdfWebView: UIWebView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var viewNoteButton: UIBarButtonItem!
    @IBOutlet weak var newNoteButton: UIBarButtonItem!
    
    
    //MARK: Initializers
    
    init(currentBook: Book, context: NSManagedObjectContext) {
        
        self.currentBook = currentBook
        self.context = context
        self.lastPageShown = 0
        
        super.init(nibName: "PdfViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: view lifecycle events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity?.isHidden = true
        activity?.stopAnimating()
        
        viewNoteButton.isEnabled = false
        newNoteButton.isEnabled = false
        
        syncViewFromModel()
        
        // Right after the view loads, a check to see if the page has changed starts
        // (it will be executed every second)
        checkForPageChange(delayInSeconds: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Right after the view appears, update the value of lastPageShown
        // (to force the execution of the didSet observer)
        lastPageShown = currentPageNumber()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    
    //MARK: Actions from the UI elements
    
    // 'View note' button
    @IBAction func showNote(_ sender: AnyObject) {
        
        // Get the note associated to the current page (in background), then show it on a new screen
        DispatchQueue.global(qos: .userInitiated).async {
            
            let existingNote = self.findNote(forPage: self.lastPageShown)
            
            if existingNote != nil {
                DispatchQueue.main.async {
                    let noteVC = NoteViewController(currentNote: existingNote!, bookTitle: self.currentBook.title!, isNewNote: false, context: self.context)
                    
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Save",
                                                                            style: UIBarButtonItemStyle.plain,
                                                                            target: nil,
                                                                            action: nil)
                    
                    self.navigationController?.pushViewController(noteVC, animated: true)
                }
            }
        }
    }
    
    
    // 'Add note' button
    @IBAction func createNote(_ sender: AnyObject) {
        
        // Create a new blank note, associated to the current page and book
        let currentPage = currentPageNumber()
        let newNote = Note(book: currentBook, page: Int32(currentPage), minContext: context)
        newNote.text = ""
        
        // Create a NoteViewController associated to the new note, and show it
        let noteVC = NoteViewController(currentNote: newNote, bookTitle: currentBook.title!, isNewNote: true, context: context)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Save",
                                                           style: UIBarButtonItemStyle.plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationController?.pushViewController(noteVC, animated: true)
    }
    
    
    //MARK: Auxiliary functions
    
    // This method checks the current page shown every certain seconds.
    // If it has changed since the last time, stores the new page number in lastPageShown.
    func checkForPageChange(delayInSeconds delay: Int) {
        
        let currentPage = currentPageNumber()
        
        if lastPageShown != currentPage && delay > 0 {
            lastPageShown = currentPage
        }
        
        // Calculate the time for the next check, and queue a new recursive call to be invoked at that time
        let delayInNanoSeconds = UInt64(delay) * NSEC_PER_SEC
        let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: { self.checkForPageChange(delayInSeconds: delay) } )
    }
    
    
    // Determines if the given page has an associated note
    // (should be invoked in background)
    func hasNotes(pageNumber: Int) -> Bool {
        
        let note = findNote(forPage: pageNumber)
        
        if note == nil  {   return false    }
        else            {   return true     }
    }
    
    
    // Searches the associated note for the given page, if any.
    // (should be invoked in background)
    func findNote(forPage pageNumber: Int) -> Note? {
        
        let noteReq = NSFetchRequest<Note>(entityName: Note.entityName)
        let filterByBook = NSPredicate(format: "book == %@", currentBook)
        let filterByPage = NSPredicate(format: "page == \(pageNumber)" )
        noteReq.predicate = NSCompoundPredicate( andPredicateWithSubpredicates: [filterByBook, filterByPage] )
        let res = try! context.fetch(noteReq)
        
        if res.count == 0   {   return nil          }
        else                {   return res.first!   }
    }
    
    
    // Gets the current page number of the PDF
    func currentPageNumber() -> Int {
        
        // Reference to the PDF document (CGPDFDocument of Core Graphics)
        guard let pdfData = currentBook.pdf?.pdfData else { return 0 }
        guard let provider = CGDataProvider(data: pdfData as CFData) else { return 0 }
        guard let doc = CGPDFDocument(provider) else { return 0 }
        
        // Get the total page number in the document
        let pdfPageCount = CGFloat(doc.numberOfPages)
        
        // Total "height" of the contents (from the ScrollView in the UIWebView that shows the document)
        let totalContentHeight = pdfWebView.scrollView.contentSize.height;
        
        // Calculate how much is the "height" of one page
        let pdfPageHeight = totalContentHeight / pdfPageCount
        
        // Calculate how much is the "height" of the frame showing the document, then divide it by two
        let halfScreenHeight = pdfWebView.frame.size.height / 2;
        
        // Calculate the current "offset" from the document beginning
        let verticalContentOffset = pdfWebView.scrollView.contentOffset.y;
        
        // Last, calculate the current page number
        let pageNumber = Int ( ceil((verticalContentOffset + halfScreenHeight) / pdfPageHeight ) )
        
        return pageNumber
    }
    
    
    // Updates the view from the model data
    func syncViewFromModel() {
        
        title = currentBook.title
        syncPdfData()
    }
    
    
    // Gets the PDF data (from SQLite or from the Internet) and shows the document on screen
    func syncPdfData() {
        
        // If the PDF was previously downloaded, just show it on screen
        let pdfData = currentBook.pdf?.pdfData
        
        if pdfData != nil {
            
            print("\nShowing locally stored PDF...\n")
            
            pdfWebView.load( pdfData as! Data, mimeType: "application/pdf", textEncodingName: "utf-8", baseURL: URL(string: ".")! )
            
            lastPageShown = currentPageNumber()
        }
            
        
        // If the PDF was never downloaded, attempt to download it now (in background).
        // Then update the view and the model.
        else {
            let urlString = (currentBook.pdf?.url)!
            
            print("\nDownloading remote PDF...\n(\(urlString))\n")
            
            Utils.asyncDownloadData(fromUrl: urlString, activityIndicator: activity) { (downloadedData: Data?) in
                
                if downloadedData != nil {
                    print("\nRemote PDF successfully downloaded!\n")
                    
                    self.pdfWebView.load( downloadedData!, mimeType: "application/pdf", textEncodingName: "utf-8", baseURL: URL(string: ".")! )
                    
                    self.lastPageShown = self.currentPageNumber()
                    
                    self.currentBook.pdf?.pdfData = downloadedData as NSData?
                }
                else {
                    print("\nERROR: Unable to load the remote PDF\n")
                }
            }
            
        }
    }
    
}

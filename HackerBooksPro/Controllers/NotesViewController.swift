//
//  NotesViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 30/09/16.
//

import UIKit
import CoreData     // to use NSFetchRequest


// This class is the view controller to show a list with all notes in a book

class NotesViewController: CoreDataCollectionViewController {
    
    let cellId = "NoteCellId"   // Id for the CollectionView cells
    let cellWidth = 150         // cell width (in points)
    let cellHeight = 150        // cell height (in points)
    let cellMargin = 8          // cell inner margin (in points)
    
    let bookTitle: String
    
    // Computed variables to get the dimensions for the image to show in the cells
    var imageWidth: Int {
        get {   return cellWidth - 2 * (cellMargin)   }
    }
    
    var imageHeight: Int {
        get {   return (cellHeight / 2) as Int - cellMargin   }
    }
    
    
    //MARK: Initializers
    init(bookTitle: String, fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.bookTitle = bookTitle
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        super.init(fetchedResultsController: fetchedResultsController, layout: flowLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: controller lifecycle events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "My notes on this book"
        
        // Tell the collection view to create cells of the given type using the "NoteCell" xib file
        // and set the collection view background color
        collectionView?.register(UINib(nibName: "NoteCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        self.collectionView?.backgroundColor = UIColor.white
    }
    
}


// Class extensions

extension NotesViewController {
    
    // Method to create the table cells (not implemented in the base class)
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Get the note for this cell
        let note = fetchedResultsController?.object(at: indexPath) as! Note
        
        // Get the cell that corresponds to the specified item in the collection view
        // (unlike the UITableViewController, this always returns an UICollectionViewCell, not an optional)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        // Reference to the cell UI elements
        let cellImage = cell.viewWithTag(100) as? UIImageView
        let cellLabel = cell.viewWithTag(200) as? UILabel
        
        // Cell setup: show the note image (re-escalated) and a text under it with
        // the page number, modification date and the beginning of the note text
        let thumbnail: UIImage
        let thumbnailSize = CGSize(width: imageWidth, height: imageHeight)
        
        if note.photo?.image != nil {
            thumbnail = Utils.resizeImage((note.photo?.image)!, toSize: thumbnailSize)
        }
        else {
            thumbnail = Utils.resizeImage(UIImage(named: "note_icon.png")!, toSize: thumbnailSize)
        }
        
        cellImage?.image = thumbnail
        
        var noteText = note.text
        if noteText == nil || noteText == "" {   noteText = "<No text>"  }
        cellLabel?.text = "Page: \(note.page)\n\(Utils.dateToString(note.modificationDate!))\n\n\(noteText!)"
        
        
        return cell
    }
    
    
    // What to do when a cell is selected -> show a new screen with the detail of the selected note
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedNote = fetchedResultsController?.object(at: indexPath) as! Note
        
        let noteVC = NoteViewController(currentNote: selectedNote, bookTitle: title!, isNewNote: false, context: (fetchedResultsController?.managedObjectContext)! )
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Save",
                                                           style: UIBarButtonItemStyle.plain,
                                                           target: nil,
                                                           action: nil)
        
        self.navigationController?.pushViewController(noteVC, animated: true)
    }
    
}


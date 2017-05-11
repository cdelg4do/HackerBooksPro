//
//  NoteViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 01/10/16.
//

import UIKit
import CoreData     // to use NSManagedObjectContext


// This class is the view controller to show and edit the contents of a note

class NoteViewController: UIViewController {
    
    var isNewNote: Bool
    var currentNote: Note
    var bookTitle: String
    var context: NSManagedObjectContext
    
    
    //MARK: Reference to UI elements
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    
    
    //MARK: Initializers
    
    init(currentNote: Note, bookTitle: String, isNewNote: Bool, context: NSManagedObjectContext) {
        
        self.isNewNote = isNewNote
        
        self.currentNote = currentNote
        self.bookTitle = bookTitle
        self.context = context
        
        super.init(nibName: "NoteViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: view lifecycle events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If we are creating a new note, get the address name from the device gps (in background)
        // (allow a 5 secs. delay for the reverse geolocation to work)
        
        if isNewNote {
            let delayInNanoSeconds = UInt64(5) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: { self.syncLocationFromModel() } )
            self.addressLabel.text = "Getting current address..."
            
            mapButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textView.layer.borderWidth = 1
        self.textView.layer.borderColor = UIColor.gray.cgColor
        
        syncViewFromModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        syncModelFromView()
    }
    
    
    //MARK: Actions from the UI elements
    
    // 'Image' button
    @IBAction func showPicture(_ sender: AnyObject) {
        
        let photoVC = PhotoViewController(currentNote: currentNote, context: context)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Save",
                                                           style: UIBarButtonItemStyle.plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationController?.pushViewController(photoVC, animated: true)
    }
    
    // 'Map' button
    @IBAction func showMap(_ sender: AnyObject) {
        
        let mapVC = NoteMapViewController(currentNote: currentNote)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back",
                                                           style: UIBarButtonItemStyle.plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    // 'Discard' button
    @IBAction func deleteNote(_ sender: AnyObject) {
        
        print("\nDeleting current note...\n")
        
        context.delete(currentNote)
        try! context.save()
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Auxiliary functions
    
    // Update the view with data from the model
    func syncViewFromModel() {
        
        title = "Note at page \(currentNote.page)"
        self.textView.text = currentNote.text
        self.createdLabel.text = "Created: " + Utils.dateToString(currentNote.creationDate!)
        
        if (!isNewNote) {
            syncLocationFromModel()
        }
    }
    
    // Update the text with the address (should be called in background)
    func syncLocationFromModel() {
        
        if currentNote.hasLocation  {
            
            self.addressLabel.text = "Address: " + (currentNote.location?.address!)!
            mapButton.isEnabled = true
        }
        else {
            self.addressLabel.text = "Address: Unknown"
            mapButton.isEnabled = false
        }
    }
    
    // Update the model with the data from the view
    // (only the modification date and the note text)
    func syncModelFromView() {
        
        currentNote.text = self.textView.text
        currentNote.modificationDate = NSDate()
    }
    
}

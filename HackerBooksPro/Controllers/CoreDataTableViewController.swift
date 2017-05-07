//
//  CoreDataTableViewController.swift
//
//
//  Created by Carlos Delgado on 19/09/16.
//  (based on previous work from Fernando Rodríguez Romero)
//

import UIKit
import CoreData


// This class represents a Table View Controller that manages data linked to CoreData

class CoreDataTableViewController: UITableViewController {
    
    // MARK:  - Properties
    
    // fetchedResultsController is a controller that acts as intermediary between
    // a fetch request and the ViewController that will show the data
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        
        // With didSet we set the behavior when the propererty value changes
        // NOTE: this has no effect when the property is set from an initializer method, unless a defer is used (see below)
        didSet{
            
            // Set the delegate to itself, execute the query and reload the view
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData()
        }
    }
    
    // Class initializer: receives an NSFetchedResultsController and a style for the table
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, style : UITableViewStyle = .plain) {
        
        // Defer blocks are always executed at the end of the method (in this case, just after initializing the object)
        defer {
            
            // Here the object is already initialized, so this line will make the didSet to be executed
            fetchedResultsController = fc
        }
        
        super.init(style: style)
    }
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
}


// MARK:  - Subclass responsibility (methods to be implemented by subclasses of this class)

extension CoreDataTableViewController{
    
    // Method to create the table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        fatalError("This method MUST be implemented by a subclass of CoreDataTableViewController")
    }
}


// MARK:  - Table Data Source (methods to build the table)

extension CoreDataTableViewController{
    
    // Number of sections in the table
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if let fc = fetchedResultsController {
            
            guard let sections = fc.sections else {
                return 1
            }
            
            return sections.count
        }
        else {
            return 0
        }
    }
    
    // Number of rows in a given section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let fc = fetchedResultsController{
            return fc.sections![section].numberOfObjects;
        }
        else {
            return 0
        }
    }
    
    // Title for a given section
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let fc = fetchedResultsController{
            
            return fc.sections?[section].name;
        }
        else {
            return nil
        }
    }
    
    // Sections to show on the right for a given section index (like A, B, ... in a contact list)
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        if let fc = fetchedResultsController{
            return fc.section(forSectionIndexTitle: title, at: index)
        }
        else {
            return 0
        }
    }
    
    // Titles for the section indexes
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if let fc = fetchedResultsController{
            return  fc.sectionIndexTitles
        }
        else {
            return nil
        }
    }
}


// MARK:  - Fetches managing

extension CoreDataTableViewController{
    
    // Executes the query associated to the controller
    // (will be called when some object in the context changes)
    
    func executeSearch(){
        
        if let fc = fetchedResultsController {
            
            do {
                try fc.performFetch()
            }
            catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}


// MARK:  - NSFetchedResultsControllerDelegate protocol
// This protocol is needed to refresh the view when changes in the model happen
// (no need to call reloadData(), since the changes are automatically updated)

extension CoreDataTableViewController: NSFetchedResultsControllerDelegate{
    
    // What to do right before the data managed by the controller changes
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // What to do when a section is created or deleted
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type) {
            
            case .insert:
                tableView.insertSections(set, with: .fade)
            
            case .delete:
                tableView.deleteSections(set, with: .fade)
            
            default:
                break
        }
    }
    
    // What to do when an object of the table is created, deleted, modified or moved
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        switch(type) {
            
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            
            case .move:
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    // What to do right after the data managed by the controller changes
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

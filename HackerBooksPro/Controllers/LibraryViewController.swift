//
//  LibraryViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 29/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit
import CoreData


// This class is the CoreDataTableViewController that shows the existing books in the library

class LibraryViewController: CoreDataTableViewController {
    
    
    // What to do after the view is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "HackerBooks Pro"   // Set the title to show
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: Class extensions

extension LibraryViewController {
    
    // Method to create the table cells (not implemented in the base class)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Cell identifier (all cells will be the same kind)
        let cellId = "BookCell"
        
        // Get the book for this cell
        let bookTag = fetchedResultsController?.object(at: indexPath) as! BookTag
        let book = bookTag.book!
        
        // Reuse/create the cell
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        }
        
        // Cell setup: show the book title and the book author(s)
        // (the ?? operator lets us specify an alternate value, in case book.title is nil)
        cell?.textLabel?.text = book.title ?? "< Book without title >"
        cell?.detailTextLabel?.text = book.authorsToString()
        
        return cell!
    }
    
    
    // What to do when a table row is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Get the selected book
        let bookTag = fetchedResultsController?.object(at: indexPath) as! BookTag
        let book = bookTag.book!
        
        // Create the controller to show the book detail and navigate to it
        let bookVC = BookViewController(currentBook: book, context: (fetchedResultsController?.managedObjectContext)! )
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Library",
                                                           style: UIBarButtonItemStyle.plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationController?.pushViewController(bookVC, animated: true)
    }
}

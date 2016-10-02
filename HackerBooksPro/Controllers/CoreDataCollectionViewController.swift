//
//  CoreDataCollectionViewController.swift
//
//
//  Created by Fernando Rodríguez Romero in Objective-C and ported to
//  Swift3 by Enrique del Pozo Gómez on 29/09/16.
//  Copyright © 2016
//

import UIKit
import CoreData

class CoreDataCollectionViewController: UICollectionViewController {
    
    var sectionChanges:[NSDictionary] = []
    var objectChanges:[NSDictionary] = []
    
    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?{
        didSet{
            // Whenever the frc changes, we execute the search and
            // reload the table
            fetchedResultsController?.delegate = self
            executeSearch()
            collectionView?.reloadData()
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>,
         layout : UICollectionViewLayout){
        defer {
            fetchedResultsController = fc
        }
        super.init(collectionViewLayout: layout)
    }
    
    
    // Do not worry about this initializer. I has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}


// MARK:  - Subclass responsability
extension CoreDataCollectionViewController{
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("This method MUST be implemented by a subclass of CoreDataTableViewController")
    }
}

// MARK:  - Collection Data Source
extension CoreDataCollectionViewController{
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let fc = fetchedResultsController{
            guard let sections = fc.sections else {
                return 1
            }
            return sections.count
        }else{
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let fc = fetchedResultsController{
            
            return fc.sections![section].numberOfObjects;
        }else{
            return 0
        }
    }
}

// MARK:  - Fetches
extension CoreDataCollectionViewController{
    
    func executeSearch(){
        if let fc = fetchedResultsController{
            do{
                try fc.performFetch()
            }catch let e as NSError{
                print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
            }
        }
    }
}


// MARK:  - Delegate
extension CoreDataCollectionViewController: NSFetchedResultsControllerDelegate{
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controllerWillChangeContent")
        //collectionView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        
        let set = IndexSet(integer: sectionIndex)
        
        switch (type){
            
        case .insert:
            collectionView?.insertSections(set)
            
        case .delete:
            collectionView?.deleteSections(set)
            
            
        default:
            // irrelevant in our case
            break
            
        }
        
        var dictionary: [NSFetchedResultsChangeType:IndexSet] = [NSFetchedResultsChangeType:IndexSet]()
        dictionary[type] = set
        sectionChanges.append(dictionary as NSDictionary)
    }
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        
        switch(type){
            
        case .insert:
            collectionView?.insertItems(at: [newIndexPath!])
            
        case .delete:
            collectionView?.deleteItems(at: [indexPath!])
            
        case .update:
            collectionView?.reloadItems(at: [indexPath!])
            
        case .move:
            collectionView?.deleteItems(at: [indexPath!])
            collectionView?.insertItems(at: [newIndexPath!]
            )
        }
        
        var dictionary: [NSFetchedResultsChangeType:IndexPath] = [NSFetchedResultsChangeType:IndexPath]()
        dictionary[type] = indexPath
        objectChanges.append(dictionary as NSDictionary)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if (sectionChanges.count > 0){
            collectionView?.performBatchUpdates({
                for change:NSDictionary in self.sectionChanges{
                    change.enumerateKeysAndObjects({ key, obj, stop in
                        let key: NSFetchedResultsChangeType = key as! NSFetchedResultsChangeType
                        let obj: IndexSet = obj as! IndexSet
                        switch(key){
                        case .insert:
                            self.collectionView?.insertSections(obj)
                            break
                        case .delete:
                            self.collectionView?.deleteSections(obj)
                            break
                        case .update:
                            self.collectionView?.reloadSections(obj)
                            break
                        default:
                            break
                        }
                    })
                }
                
                }, completion: nil)
        }
        if(objectChanges.count > 0 && sectionChanges.count == 0){
            if (shouldReloadCollectionViewToPreventKnownIssue() || collectionView?.window == nil){
                
            }else{
                collectionView?.performBatchUpdates({
                    for change:NSDictionary in self.objectChanges{
                        change.enumerateKeysAndObjects({ key, obj, stop in
                            let key: NSFetchedResultsChangeType = key as! NSFetchedResultsChangeType
                            let obj: IndexPath = obj as! IndexPath
                            switch(key){
                            case .insert:
                                self.collectionView?.insertItems(at: [obj])
                                break
                            case .delete:
                                self.collectionView?.deleteItems(at: [obj])
                                break
                            case .update:
                                self.collectionView?.reloadItems(
                                    at: [obj])
                                break
                            default:
                                break
                            }
                        })
                    }
                    
                    }, completion: nil)
            }
        }
        sectionChanges.removeAll()
        objectChanges.removeAll()
    }
    
    func shouldReloadCollectionViewToPreventKnownIssue() -> Bool{
        var shouldReload: Bool = false
        
        for change:NSDictionary in self.objectChanges{
            change.enumerateKeysAndObjects({ key, obj, stop in
                let key: NSFetchedResultsChangeType = key as! NSFetchedResultsChangeType
                let obj: IndexPath = obj as! IndexPath
                switch(key){
                case .insert:
                    shouldReload = collectionView?.numberOfItems(inSection: obj.section) == 0 ? true:false
                    break
                case .delete:
                    shouldReload = collectionView?.numberOfItems(inSection: obj.section) == 1 ? true:false
                    break
                case .update:
                    shouldReload = false
                    break
                case .move:
                    shouldReload = false
                    break
                }
            })
        }
        return shouldReload
    }
}

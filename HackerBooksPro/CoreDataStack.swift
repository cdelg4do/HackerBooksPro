//
//  CoreDataStack.swift
//
//
//  Created by Carlos Delgado on 19/09/16.
//  (based on previous work from Fernando Rodríguez Romero)
//

import CoreData


// This class defines a customized CoreData stack to work with

struct CoreDataStack {
    
    // Use fileprivate on the properties to make them accessible outside this block (i.e. in an extension)
    fileprivate let model : NSManagedObjectModel    // the model described in the xcdatamodel
    fileprivate let modelURL : URL                  // url for the xcdatamodel model scheme on the filesystem
    fileprivate let dbURL : URL                     // url for the database on the filesystem
    
    // Contexts (object containers, each one is associated to a different queue to perform the core data operations)
    fileprivate let persistingContext : NSManagedObjectContext  // context to persist data on disk only (in background)
    fileprivate let backgroundContext : NSManagedObjectContext  // context to perform non-disk operations in background
    let context : NSManagedObjectContext                        // context to perform non-disk operations in the main queue (update views, etc)
    
    fileprivate let coordinator : NSPersistentStoreCoordinator  // an intermediate between the contexts and the physical storage
    
    
    // Initializer: loads the model corresponding to the given name and initializes all necessary structures to work with it
    // (in case any operation fails, will return nil)
    init?(modelName: String) {
        
        // Get the shema url (assumming it is int the app main bundle),
        // then initialize the model with that file contents
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            print("\nERROR: Unable to find \(modelName) in the main bundle\n")
            return nil
        }
        
        self.modelURL = modelURL
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            print("\nERROR: Unable to create a model from \(modelURL)\n")
            return nil
        }
        
        self.model = model
        
        
        // Create an store coordinator associated to the model
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        // Create the 3 contexts needed (one in the main queue, two in separate background queues)
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        backgroundContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        persistingContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Set the hierarchy (from parents to children): StoreCoordinator > persistingContext > context > backgroundContext
        backgroundContext.parent = context
        context.parent = persistingContext
        persistingContext.persistentStoreCoordinator = coordinator
        
        
        // Last, associate the Store Coordinator with a SQLite store in the Documents folder
        guard let docUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("\nERROR: Unable to reach the Documents folder\n")
            return nil
        }
        
        self.dbURL = docUrl.appendingPathComponent("model.sqlite")
        
        do {
            try addStoreToCoordinator(NSSQLiteStoreType, storeURL: dbURL)
        }
        catch {
            print("\nERROR: Unable to add store at \(dbURL)\n")
        }
    }
    
    
    // Auxiliary function to associate the StoreCoordinator with a store of the given type, at the given location
    // (if the store does not exist yet, it is created now)
    func addStoreToCoordinator(_ storeType: String, storeURL: URL) throws {
        
        // In case a previous version of the store already exists on the device, set the migration options
        // (automatic migration, lets CoreData figure it out)
        let migrationOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                                NSInferMappingModelAutomaticallyOption: true ]
        
        try coordinator.addPersistentStore(ofType: storeType, configurationName: nil, at: storeURL, options: migrationOptions)
    }
}


//MARK: class extension --> data removal

extension CoreDataStack  {
    
    // Auxiliary function to remove all stored objects (for testing, etc), leaves a store with all tables emptied
    func dropAllData() throws{
        
        try coordinator.destroyPersistentStore(at: dbURL, ofType:NSSQLiteStoreType , options: nil)
        try addStoreToCoordinator(NSSQLiteStoreType, storeURL: dbURL)
    }
    
}


//MARK: class extension --> background batch processing

extension CoreDataStack {
    
    // Alias for a function that performs some CoreData operation on a given context
    typealias Batch = (_ workerContext: NSManagedObjectContext) -> ()
    
    // Auxiliary function to perform CoreData operations in background
    // (use of @escaping is required to indicate the compiler that Batch() can execute after this block is finished)
    func performBackgroundBatchOperation(_ batch: @escaping Batch){
        
        // perform() executes a block in the queue associated to the context
        backgroundContext.perform() {
            
            batch(self.backgroundContext)
            
            // Once the operation finishes, save changes in order to make them visible to the parent context
            do {
                try self.backgroundContext.save()
            }
            catch {
                fatalError("\nERROR: Unable to save backgroundContext: \(error)")
            }
        }
    }
}


//MARK: class extension --> save data to disk

extension CoreDataStack {
    
    // This method stores the changes on disk
    // (first consolidates changes on the main context, then saves them to disk in background)
    func save() {
        
        // NOTE:
        //
        // NSManagedObjectContext.save() attempts to consolidate the unsaved changes of a context in the parent
        // (another context, or a StoreCoordinator):
        // 
        // - If the parent is another context, changes are just made visible in the parent (on memory)
        // - If the parent is a StoreCoordinator, changes are consolidated on disk (SQLite, etc)
        
        // performAndWait() executes a block on the context queue, sequentially
        context.performAndWait() {
            
            // The operation will happen only if there are unsaved changes in the main context
            if self.context.hasChanges {
                
                // Saves the main context changes, making them visible in the persistence context
                // (this is not made in background, but it does not affect performance since it all happens in memory)
                do {
                    try self.context.save()
                }
                catch {
                    fatalError("\nERROR: Unable to save main context: \(error)")
                }
                
                // Now, tell the persistence context to save the unsaved changes to disk (this will happen in background)
                self.persistingContext.perform() {
                    
                    do {
                        try self.persistingContext.save()
                    }
                    catch {
                        fatalError("\nERROR: Unable to save persisting context: \(error)")
                    }
                }
            }
        }
    }
    
    // This function starts the automatic save every certain seconds
    func autoSave(_ delayInSeconds : Int) {
        
        if delayInSeconds > 0 {
            
            print("Autosaving...")
            save()
            
            // Queue a recursive call in the main queue, to be executed after the given seconds
            let delayInNanoSeconds = UInt64(delayInSeconds) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            
            DispatchQueue.main.asyncAfter(deadline: time, execute: { self.autoSave(delayInSeconds) } )
        }
    }
}


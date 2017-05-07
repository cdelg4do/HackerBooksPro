//
//  AppDelegate.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 18/09/16.
//

import UIKit

import CoreData
import Foundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // Data Model
    // (CoreDataStack() returns an optional, we force to be not nil so that app will crash in that case
    let model = CoreDataStack(modelName: "Model")!
    
    // URL of the remote JSON that contains the info about the books
    let remoteJsonUrlString = "https://t.co/K9ziV0z3SJ"
    
    // Key for the flag that indicates if the JSON was already downloaded in previous executions
    let jsonAlreadyDownloadedKey = "JSON Already Downloaded on this device"
    
    // Flag that indicates if the table title should show that the data shown have just been downloaded
    // (if false, means that the data are already cached)
    var showTitleNewData = false
    
    // Computed variable that indicates if the device hardware is a tablet or not
    var HARDWARE_IS_IPAD: Bool {
        get {
            if UIDevice.current.userInterfaceIdiom == .pad { return true }
            else { return false }
        }
    }
    
    // Computed variable that indicates if the JSON file was already downloaded in previous executions
    var JSON_ALREADY_DOWNLOADED: Bool {
        
        get {
            return UserDefaults.standard.bool(forKey: jsonAlreadyDownloadedKey)
        }
    }
    
    
    // Shows the initial screen of the app (list of books, grouped by tags)
    func showLibrary() -> () {
        
        // Sets the autosave each 5 min.
        //print("\nSetting autosave\n")
        //model.autoSave(300)
        
        
        // Create the fetchRequest for the data initially shown
        // (nooks, loaded in blocks of 50, sorted by tag and then by title)
        let fr = NSFetchRequest<BookTag>(entityName: BookTag.entityName)
        fr.fetchBatchSize = 50
        fr.sortDescriptors = [ NSSortDescriptor(key: "tag.proxyForSorting", ascending: true),
                               NSSortDescriptor(key: "book.title", ascending: true) ]
        
        // Create the fetchResultsController
        // (the value of sectionNameKeyPath lets the table itself to use that property as sections)
        // (cacheName is the name of an optional file to cache data from SQLite, improves the queries speed)
        let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: model.context, sectionNameKeyPath: "tag.name", cacheName: nil)
        
        
        // Create the controller to show the books, and the navigation controller
        let nVC = LibraryViewController(fetchedResultsController: fc as! NSFetchedResultsController<NSFetchRequestResult>, style: .plain)
        let navVC = UINavigationController(rootViewController: nVC)
        
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // If the remote JSON was already downloaded in previous executions, load the book list from the local cache
        if JSON_ALREADY_DOWNLOADED {
            
            print("\nShowning library...\n")
            showLibrary()
        }
            
        // If the remote JSON was never downloaded, do it now. Then, store the data and show the book list
        else {
            
            generateData(fromRemoteUrl: remoteJsonUrlString, inContext: model.context, activityIndicator: nil) { (success: Bool) in
                
                if success {
                            //UserDefaults.standard.set(true, forKey: self.jsonAlreadyDownloadedKey)
                    
                            print("\nData successfully downloaded, showing library...\n")
                            self.showLibrary()
                }
                else {
                            fatalError("\n** ERROR: failed to download remote JSON, or it is not a valid JSON document **")
                }
            }
            
        }
        
        return true
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    
    // Before the app finishes, dump all unsaved changes to SQLite
    func applicationWillTerminate(_ application: UIApplication) {
        
        //print("\nSaving data before finishing application...\n")
        //model.save()
    }
}





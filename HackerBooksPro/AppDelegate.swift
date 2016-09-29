//
//  AppDelegate.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 18/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit

import CoreData
import Foundation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // Modelo de datos
    // (CoreDataStack() devuelve un opcional, lo forzamos para que la app casque en caso de devolver nil)
    let model = CoreDataStack(modelName: "Model")!
    
    // Url de descarga del JSON remoto con la información de los libros
    let remoteJsonUrlString = "https://t.co/K9ziV0z3SJ"
    
    // Key para el flag que indica que ya se cargó el JSON en el pasado
    let jsonAlreadyDownloadedKey = "JSON Already Downloaded on this device"
    
    // Variable que determina si hay que indicar en el título de la librería que se están cargando datos descargados
    var showTitleNewData = false
    
    // Variable que discrimina si el hardware es una tablet o no
    var HARDWARE_IS_IPAD: Bool {
        get {
            if UIDevice.current.userInterfaceIdiom == .pad { return true }
            else { return false }
        }
    }
    
    // Variable que discrimina si el fichero JSON remoto ya fue descargado en anteriores ejecuciones del programa
    var JSON_ALREADY_DOWNLOADED: Bool {
        
        get {
            return UserDefaults.standard.bool(forKey: jsonAlreadyDownloadedKey)
        }
    }
    
    
    // Función que muestra la ventana inicial de la app (listado de libros agrupados por tags)
    func showLibrary() -> () {
        
        // Crear el fetchRequest para los datos que mostraremos inicialmente
        // (libros, de 50 en 50, ordenadas primero por tag y después por título del libro)
        let fr = NSFetchRequest<BookTag>(entityName: BookTag.entityName)
        fr.fetchBatchSize = 50
        fr.sortDescriptors = [ NSSortDescriptor(key: "tag.proxyForSorting", ascending: true),
                               NSSortDescriptor(key: "book.title", ascending: true) ]
        
        // Crear el fetchResultsController
        // (el valor de sectionNameKeyPath permite que la propia tabla organizará las secciones por esa propiedad)
        // (cacheName es el nombre de un fichero intermedio entre SQLite y memoria, permite alererar algo las búsquedas)
        let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: model.context, sectionNameKeyPath: "tag.name", cacheName: nil)
        
        
        // Crear el controlador que mostrará las libretas
        let nVC = LibraryViewController(fetchedResultsController: fc as! NSFetchedResultsController<NSFetchRequestResult>, style: .plain)
        
        // Crear un navigation controller con él
        let navVC = UINavigationController(rootViewController: nVC)
        
        // Crear la window, asignarle el navigatio controller como root y mostrarla
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Si ya se descargó el JSON remoto en el pasado, cargamos la lista de libros a partir de los datos almacenados localmente
        if JSON_ALREADY_DOWNLOADED {
            
            print("\nMostrando librería...\n")
            showLibrary()
        }
            
        // Si nunca se había descargado el JSON remoto, se intenta descargar y construir los objetos del modelo
        
        else {
            
            generateData(fromRemoteUrl: remoteJsonUrlString, inContext: model.context, activityIndicator: nil) { (success: Bool) in
                
                if success {
                            //UserDefaults.standard.set(true, forKey: self.jsonAlreadyDownloadedKey)
                    
                            //print("\nGuardando datos iniciales en SQLite local...\n")
                            //self.model.save()
                    
                            print("\nDatos remotos descargados con éxito, mostrando librería...\n")
                            self.showLibrary()
                }
                else {
                            fatalError("\n** ERROR ** No fue posible descargar los datos remotos.\n")
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

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    
    
    
    //MARK: Funciones auxiliares
    
    

}





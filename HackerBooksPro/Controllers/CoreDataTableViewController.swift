//
//  CoreDataTableViewController.swift
//
//
//  Created by Carlos Delgado on 19/09/16.
//  (based on previous work from Fernando Rodríguez Romero)
//

import UIKit
import CoreData

class CoreDataTableViewController: UITableViewController {
    
    // MARK:  - Properties
    
    // fetchedResultsController es un controlador (pero no un ViewController) que hará de intermediario entre
    // una descripción de búsqueda (fetchRequest) y un ViewController (que puede ser una tabla, un CollectionView, etc)
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>? {
        
        // Con didSet establecemos un observador para los cambios de una propiedad computada del objeto (en este caso el fetchedResultsController)
        // Entonces asignamos el delegado (él mismo), ejecutamos la búsqueda y recargamos la tabla
        // ( Ojo: el didSet no se ejecuta cuando se crea el objeto en el inicializador, a menos que se use un defer (ver más abajo) )
        didSet{
            
            fetchedResultsController?.delegate = self
            executeSearch()
            tableView.reloadData()
        }
    }
    
    // Inicializador de la clase, recibe un NSFetchedResultsController y un estilo de tabla
    init(fetchedResultsController fc : NSFetchedResultsController<NSFetchRequestResult>, style : UITableViewStyle = .plain) {
        
        // El bloque "defer" se ejecutará siempre al final del método. En este caso, justo después de inicializar el objeto)
        // (como ya está terminada la inicialización, al asignar el valor a fetchedResultsController, inmediatamente se ejecutará el didSet)
        defer {
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


// MARK:  - Subclass responsability
// (métodos que deben implementar las subclases de esta clase)

extension CoreDataTableViewController{
    
    // Método para crear cada celda de la tabla
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        fatalError("This method MUST be implemented by a subclass of CoreDataTableViewController")
    }
}


// MARK:  - Table Data Source
// (métodos para la construcción de la tabla)
extension CoreDataTableViewController{
    
    // Número de secciones de la tabla
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
    
    // Número de filas en una sección
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let fc = fetchedResultsController{
            return fc.sections![section].numberOfObjects;
        }
        else {
            return 0
        }
    }
    
    // Título de una sección concreta
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let fc = fetchedResultsController{
            
            return fc.sections?[section].name;
        }
        else {
            return nil
        }
    }
    
    // Secciones a mostrar para una sección índice que pueden mostrarse a la derecha (ej. A, B, ... en una lista de contactos)
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        
        if let fc = fetchedResultsController{
            return fc.section(forSectionIndexTitle: title, at: index)
        }
        else {
            return 0
        }
    }
    
    // Título de las secciones índice
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        
        if let fc = fetchedResultsController{
            return  fc.sectionIndexTitles
        }
        else {
            return nil
        }
    }
    
    
}

// MARK:  - Fetches
// (gestión de las búsquedas)
extension CoreDataTableViewController{
    
    // Función de ejecución de la búsqueda asociada al controlador
    // (para usar cuando cambie algún objeto del contexto)
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


// MARK:  - Delegate
// (protocolo del delegado del NSFetchedResultsController, para refrescar la vista ante cambios en el modelo)
// (con esto no es necesario hacer un reloadData(), ya que se actualiza directamente lo que ha cambiado)
extension CoreDataTableViewController: NSFetchedResultsControllerDelegate{
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // Qué hacer cuando se actualiza o modifica una sección
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
            // irrelevant in our case
            
            break
        }
    }
    
    // Qué hacer cuando se actualiza o modifica un objeto
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
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

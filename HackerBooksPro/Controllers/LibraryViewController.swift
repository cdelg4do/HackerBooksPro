//
//  LibraryViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 29/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit

import CoreData     // para usar NSFetchRequest


class LibraryViewController: CoreDataTableViewController {
    
    
    // Operaciones a realizar una vez que se carga la vista
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "HackerBooks Pro"   // Mostrar un título
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}


// Extensiones de la clase

extension LibraryViewController {
    
    // Implementación del método para crear las celdas de la tabla (CoreDataTableViewController no lo implementa)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Identificador para la celda
        let cellId = "BookCell"
        
        // Obtener el libro que corresponde a la celda
        let bookTag = fetchedResultsController?.object(at: indexPath) as! BookTag
        let book = bookTag.book!
        
        // Obtener/crear la celda correspondiente
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        
        if cell == nil {
            
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        }
        
        // Configuración de la celda: el texto (el título del libro) y el subtexto (el/los autores)
        // (el ?? indica que se debe usar el contenido del opcional nb.name, o "New Notebook" si aquél es nil)
        cell?.textLabel?.text = book.title ?? "< Libro sin identificar >"
        cell?.detailTextLabel?.text = book.authorsToString()
        
        // Devolver la celda
        return cell!
    }
    
    
    
    // Utils:
    
    // Acción a realizar cuando se selecciona la fila de un libro
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    /*
        // Obtener el libro seleccionado
        let book = fetchedResultsController?.object(at: indexPath) as! Book
        
        // Crear el controlador para mostrar el libro seleccionado
        let bookVC = BookViewController(model: book)
        
        // Mostrar el controlador
        navigationController?.pushViewController(bookVC, animated: true)
    */
        
    }
    
}


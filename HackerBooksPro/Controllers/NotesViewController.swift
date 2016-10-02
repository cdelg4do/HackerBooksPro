//
//  NotesViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 30/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit

import CoreData     // para usar NSFetchRequest


class NotesViewController: CoreDataCollectionViewController {
    
    //MARK: Propiedades
    
    let cellId = "NoteCell"     // Identificador para las celdas del CollectionView
    let bookTitle: String       // Título del libro cuyas notas se muestran
    
    
    //MARK: Inicializadores designados
    init(bookTitle: String, fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.bookTitle = bookTitle
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: 150, height: 150)
        flowLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        super.init(fetchedResultsController: fetchedResultsController, layout: flowLayout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Ciclo de vida del controlador
    
    // Operaciones a realizar una vez que se carga la vista
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = self.bookTitle
        
        collectionView?.register(UINib(nibName: "NoteCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        self.collectionView?.backgroundColor = UIColor.white
    }
    
}


// Extensiones de la clase

extension NotesViewController {
    
    // Implementación del método para crear las celdas de la tabla
    // (obligatorio ya que CoreDataCollectionViewController no lo implementa)
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Obtener la nota que corresponde a la celda
        let note = fetchedResultsController?.object(at: indexPath) as! Note
        
        // Obtener/crear la celda correspondiente
        // (devuelve un UICollectionViewCell, a diferencia de en la TableView que devuelve un opcional)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        
        // Referencia a las vistas de la celda obtenida
        let cellImage = cell.viewWithTag(100) as? UIImageView
        let cellLabel = cell.viewWithTag(200) as? UILabel
        
        // Configuración de la celda: imagen (si la nota tiene una)
        // y texto (número de página, fecha de modificación y contenido de la nota)
        if note.photo?.image != nil {
            cellImage?.image = note.photo?.image
        }
        else {
            cellImage?.image = UIImage(named: "note_icon.png")
        }
        
        var noteText = note.text
        if noteText == nil || noteText == "" {   noteText = "<No text>"  }
        cellLabel?.text = "Page: \(note.page)\n\(Utils.dateToString(note.modificationDate!))\n\(noteText!)"
        
        // Devolver la celda
        return cell
    }
    
    
    // Acción a realizar cuando se selecciona la celda de una nota
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Obtener la nota seleccionada
        let selectedNote = fetchedResultsController?.object(at: indexPath) as! Note
        
        // Crear el controlador para mostrar la nota seleccionada, y mostrarlo
        let noteVC = NoteViewController(currentNote: selectedNote, bookTitle: title!, isNewNote: false, context: (fetchedResultsController?.managedObjectContext)! )
        self.navigationController?.pushViewController(noteVC, animated: true)
    }
    
}


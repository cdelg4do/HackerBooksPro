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
    
    //MARK: Constantes
    let cellId = "NoteCell"     // Identificador para las celdas del CollectionView
    let cellWidth = 150         // Anchura de la celda a mostrar (en puntos)
    let cellHeight = 150        // Altura de la celda a mostrar (en puntos)
    let cellMargin = 8          // Márgen interior de la celda (en puntos)
    
    //MARK: Otras propiedades
    let bookTitle: String       // Título del libro cuyas notas se muestran
    
    var imageWidth: Int {
        
        get {   return cellWidth - 2 * (cellMargin)   }
    }
    
    var imageHeight: Int {
        
        get {   return (cellHeight / 2) as Int - cellMargin   }
    }
    
    
    //MARK: Inicializadores designados
    init(bookTitle: String, fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>) {
        
        self.bookTitle = bookTitle
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: cellWidth, height: cellHeight)
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
        
        // Configuración de la celda:
        // - Imagen (si la nota tiene una o sino una imagen por defecto, redimensionadas para entrar en la celda)
        // - Texto (número de página, fecha de modificación y contenido de la nota)
        let thumbnail: UIImage
        let thumbnailSize = CGSize(width: imageWidth, height: imageHeight)
        
        if note.photo?.image != nil {
            thumbnail = Utils.resizeImage((note.photo?.image)!, toSize: thumbnailSize)
        }
        else {
            thumbnail = Utils.resizeImage(UIImage(named: "note_icon.png")!, toSize: thumbnailSize)
        }
        
        cellImage?.image = thumbnail
        
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


//
//  BookViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 29/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit

import CoreData     // para usar NSManagedObjectContext


class BookViewController: UIViewController {
    
    //MARK: Propiedades
    
    var currentBook: Book
    var context: NSManagedObjectContext
    
    
    //MARK: Referencia a los objetos de la interfaz
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var bookCover: UIImageView!
    
    
    //MARK: Inicializadores
    
    init(currentBook: Book, context: NSManagedObjectContext) {
        
        self.currentBook = currentBook
        self.context = context
        
        super.init(nibName: "BookViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Eventos del ciclo de vida de la vista
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        activity?.isHidden = true
        activity?.stopAnimating()
        
        bookCover.image = UIImage(named: "book_cover.png")
        
        syncViewFromModel(includingCover: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        syncCoverImage()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    
    
    //MARK: Acciones al pulsar los botones de la ventana
    
    // Botón de mostrar PDF del libro
    @IBAction func showPdf(_ sender: AnyObject) {
        
        // Crear un SimplePDFViewController con los datos del modelo
        let pdfVC = PdfViewController(currentBook: currentBook, context: context)
        
        // Hacer un push sobre mi NavigatorController
        navigationController?.pushViewController(pdfVC, animated: true)
    }
    
    
    // Botón de añadir/quitar favorito
    @IBAction func toggleFavorite(_ sender: AnyObject) {
        
        // Buscar en los BookTag si hay alguna coincidencia del tag de favoritos con el presente libro
        let bookTagReq = NSFetchRequest<BookTag>(entityName: BookTag.entityName)
        let filterByTag = NSPredicate(format: "tag.proxyForSorting == %@", "_favorites")
        let filterByBook = NSPredicate(format: "book == %@", currentBook)
        bookTagReq.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [filterByTag, filterByBook])
        let res = try! context.fetch(bookTagReq)
        
        // Si no hay coincidencias, se añade el libro a favoritos.
        if res.count == 0 {
            print("\nAñadiendo el libro a favoritos...\n")
            
            // Obtener una referencia al tag de favoritos
            let tagReq = NSFetchRequest<Tag>(entityName: Tag.entityName)
            tagReq.predicate = NSPredicate(format: "proxyForSorting == %@", "_favorites")
            let res1 = try! context.fetch(tagReq)
            let favoritesTag = res1.first!
            
            // Crear un nuevo bookTag con el tag de favoritos y el libro actual
            let _ = BookTag(book: currentBook, tag: favoritesTag, inContext: context)
            try! context.save()
        }
        
        // Si hay alguna coincidencia (debería haber una como mucho), entonces la eliminamos
        else {
            print("\nEliminando el libro de favoritos...\n")
            
            context.delete(res.first!)
            try! context.save()
        }
        
        // Por último, actualizar la vista con la información actualizada y salvar
        syncViewFromModel(includingCover: false)
    }
    
    
    // Botón de mostrar las notas del presente libro
    @IBAction func showNotes(_ sender: AnyObject) {
        
        // FetchRequest para los datos que se mostrarán
        // (las notas de este libro, cargadas de 50 en 50, ordenadas por página)
        let fr = NSFetchRequest<Note>(entityName: Note.entityName)
        fr.predicate = NSPredicate(format: "book == %@", currentBook)
        fr.fetchBatchSize = 50
        fr.sortDescriptors = [ NSSortDescriptor(key: "page", ascending: true) ]
        
        // Crear el fetchResultsController
        let fc = NSFetchedResultsController(fetchRequest: fr, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        // Crear el controlador que mostrará las libretas y mostrarlo
        let notesVC = NotesViewController(bookTitle: currentBook.title!, fetchedResultsController: fc as! NSFetchedResultsController<NSFetchRequestResult>)
        
        navigationController?.pushViewController(notesVC, animated: true)
    }
    
    
    
    //MARK: Funciones auxiliares
    
    // Función para actualizar la vista con los datos del libro
    // (opcionalmente, se actualizará también la portada)
    func syncViewFromModel(includingCover syncCover: Bool) {
        
        title = currentBook.title
        
        authorsLabel.text = currentBook.authorsToString()
        tagsLabel.text = currentBook.tagsToString()
        
        if syncCover {  syncCoverImage()    }
    }
    
    
    // Función que actualiza la portada del libro en pantalla
    
    func syncCoverImage() {
        
        // Si ya hay datos de la imagen descargados, la mostramos en pantalla
        let imageData = currentBook.cover?.coverData
        
        if imageData != nil {
            
            bookCover.image = UIImage(data: imageData as! Data)
            bookCover.alpha = 1.0
        }
        
        // Si aún no hay datos de la imagen, se intenta descargar la imagen remota en segundo plano,
        // Si la descarga se realiza con éxito, se actualizan la vista y el modelo.
        else {
            let urlString = (currentBook.cover?.url)!
            
            print("\nDescargando imagen remota...\n(\(urlString))\n")
            
            Utils.asyncDownloadImage(fromUrl: urlString, mustResize: true, activityIndicator: activity) { (image: UIImage?) in
                
                if image != nil {
                    print("\nImagen remota descargada con éxito!\n")
                    
                    self.bookCover.image = image
                    self.bookCover.alpha = 1.0
                    
                    self.currentBook.cover?.image = image
                }
                else {
                    print("\nERROR: No ha sido posible cargar la imagen remota\n")
                }
            }
            
        }
    }
    
    
    
    
}

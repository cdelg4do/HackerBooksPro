//
//  PdfViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit

import CoreData     // para usar NSManagedObjectContext
import CoreGraphics // para usar CGFloat


class PdfViewController: UIViewController {
    
    //MARK: Propiedades
    
    var currentBook: Book
    var context: NSManagedObjectContext
    
    // Número de página actual
    // Si cambia, se comprueba si hay notas asociadas a la nueva página (en segundo plano)
    // y se (des)habilitan los botones de la pantalla que correspondan
    var lastPageShown : Int {
        
        didSet {
            DispatchQueue.global(qos: .userInitiated).async {
                
                // Si la nueva página ya tiene alguna nota,
                // se habilita el botón de ver la nota creada y se deshabilita el de crear nota
                if self.hasNotes(pageNumber: self.lastPageShown) {
                    
                    DispatchQueue.main.async {
                        print("\nLa nueva página (\(self.lastPageShown)) SÍ tiene alguna nota asociada\n")
                        self.viewNoteButton.isEnabled = true
                        self.newNoteButton.isEnabled = false
                    }
                }
                // Si no, se deshabilita el botón de ver la nota creada y se habilita el de crear nota
                else {
                    
                    DispatchQueue.main.async {
                        print("\nLa nueva página (\(self.lastPageShown)) NO tiene notas asociadas\n")
                        self.viewNoteButton.isEnabled = false
                        self.newNoteButton.isEnabled = true
                    }
                }
            }
        }
        
    }
    
    
    //MARK: Referencia a los objetos de la interfaz
    @IBOutlet weak var pdfWebView: UIWebView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var viewNoteButton: UIBarButtonItem!
    @IBOutlet weak var newNoteButton: UIBarButtonItem!
    
    
    //MARK: Inicializadores
    
    init(currentBook: Book, context: NSManagedObjectContext) {
        
        self.currentBook = currentBook
        self.context = context
        self.lastPageShown = 0
        
        super.init(nibName: "PdfViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: Eventos del ciclo de vida de la vista
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity?.isHidden = true
        activity?.stopAnimating()
        
        viewNoteButton.isEnabled = false
        newNoteButton.isEnabled = false
        
        syncViewFromModel()
        checkForPageChange(delayInSeconds: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        // Nada más mostrar la vista, actualizar el valor de lastPageShown
        // (para forzar la ejecución del observador de esta propiedad)
        lastPageShown = currentPageNumber()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    
    
    //MARK: Acciones al pulsar los botones de la vista
    
    // Función que muestra la nota asociada a la página actual
    @IBAction func showNote(_ sender: AnyObject) {
        
        // Buscar la nota asociada en segundo plano,
        // crear un NoteViewController con esa nota, y mostrarlo (en primer plano)
        DispatchQueue.global(qos: .userInitiated).async {
            
            let existingNote = self.findNote(forPage: self.lastPageShown)
            
            if existingNote != nil {
                DispatchQueue.main.async {
                    let noteVC = NoteViewController(currentNote: existingNote!, bookTitle: self.currentBook.title!, isNewNote: false, context: self.context)
                    self.navigationController?.pushViewController(noteVC, animated: true)
                }
            }
        }
        
        
        
    }
    
    
    // Función que crea una nueva nota asociada a la página actual
    @IBAction func createNote(_ sender: AnyObject) {
        
        // Crear una nueva nota en blanco, asociada al libro y página actuales
        let currentPage = currentPageNumber()
        let newNote = Note(book: currentBook, page: Int32(currentPage), minContext: context)
        newNote.text = "Write something here..."
        
        // Crear un NoteViewController asociado a esa nota, y mostrarlo
        let noteVC = NoteViewController(currentNote: newNote, bookTitle: currentBook.title!, isNewNote: true, context: context)
        navigationController?.pushViewController(noteVC, animated: true)
    }
    
    
    
    //MARK: Funciones auxiliares
    
    
    // Función que cada cierto tiempo actualiza el contador de la página actual
    // (solo si hubo cambios desde la vez anterior)
    func checkForPageChange(delayInSeconds delay: Int) {
        
        let currentPage = currentPageNumber()
        
        if lastPageShown != currentPage && delay > 0 {
            lastPageShown = currentPage
        }
        
        // Calcular la hora de la siguiente comprobación
        let delayInNanoSeconds = UInt64(delay) * NSEC_PER_SEC
        let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
        
        // Encolar una nueva llamada a checkForPageChange() en la cola principal, se ejecutará a la hora calculada
        DispatchQueue.main.asyncAfter(deadline: time, execute: { self.checkForPageChange(delayInSeconds: delay) } )
    }
    
    
    // Función que indica si una página ya tiene una nota asociada
    // (debería invocarse en segundo plano)
    func hasNotes(pageNumber: Int) -> Bool {
        
        let note = findNote(forPage: pageNumber)
        
        if note == nil  {   return false    }
        else            {   return true     }
    }
    
    
    // Función que busca la nota asociada al libro y página actuales
    // (debería invocarse en segundo plano)
    func findNote(forPage pageNumber: Int) -> Note? {
        
        let noteReq = NSFetchRequest<Note>(entityName: Note.entityName)
        let filterByBook = NSPredicate(format: "book == %@", currentBook)
        let filterByPage = NSPredicate(format: "page == \(pageNumber)" )
        noteReq.predicate = NSCompoundPredicate( andPredicateWithSubpredicates: [filterByBook, filterByPage] )
        let res = try! context.fetch(noteReq)
        
        if res.count == 0   {   return nil}
        else                {   return res.first!    }
    }
    
    
    
    // Función que calcula el número de página actual del documento
    func currentPageNumber() -> Int {
        
        // Referencia al documento PDF del modelo (CGPDFDocument de Core Graphics)
        guard let pdfData = currentBook.pdf?.pdfData else { return 0 }
        guard let provider = CGDataProvider(data: pdfData as CFData) else { return 0 }
        guard let doc = CGPDFDocument(provider) else { return 0 }
        
        // Número total de páginas en el documento
        let pdfPageCount = CGFloat(doc.numberOfPages)
        
        // "Altura" total del contenido (a partir del ScrollView del UIWebView que muestra el pdf)
        let totalContentHeight = pdfWebView.scrollView.contentSize.height;
        
        // "Altura" del contenido de una sola página del documento
        let pdfPageHeight = totalContentHeight / pdfPageCount
        
        // "Altura" del marco en el que se muestra el pdf, a la mitad
        let halfScreenHeight = pdfWebView.frame.size.height / 2;
        
        // Desplazamiento actual del documento desde el inicio
        let verticalContentOffset = pdfWebView.scrollView.contentOffset.y;
        
        // Página actual
        let pageNumber = Int ( ceil((verticalContentOffset + halfScreenHeight) / pdfPageHeight ) )
        
        return pageNumber
    }
    
    
    
    // Función para actualizar la vista con los datos del libro
    func syncViewFromModel() {
        
        title = currentBook.title
        
        syncPdfData()
    }
    
    
    // Función que obtiene los datos del PDF para mostrar en pantalla
    
    func syncPdfData() {
        
        // Si ya hay datos del PDF descargados, lo mostramos en pantalla
        let pdfData = currentBook.pdf?.pdfData
        
        if pdfData != nil {
            
            print("\nMostrando PDF local...\n")
            
            pdfWebView.load( pdfData as! Data, mimeType: "application/pdf", textEncodingName: "utf-8", baseURL: URL(string: ".")! )
            
            lastPageShown = currentPageNumber()
        }
            
        // Si aún no hay datos de la imagen, se intenta descargar la imagen remota en segundo plano,
        // Si la descarga se realiza con éxito, se actualizan la vista y el modelo.
        else {
            let urlString = (currentBook.pdf?.url)!
            
            print("\nDescargando pdf remoto...\n(\(urlString))\n")
            
            Utils.asyncDownloadData(fromUrl: urlString, activityIndicator: activity) { (downloadedData: Data?) in
                
                if downloadedData != nil {
                    print("\nPdf remoto descargada con éxito!\n")
                    
                    self.pdfWebView.load( downloadedData!, mimeType: "application/pdf", textEncodingName: "utf-8", baseURL: URL(string: ".")! )
                    
                    self.lastPageShown = self.currentPageNumber()
                    
                    self.currentBook.pdf?.pdfData = downloadedData as NSData?
                }
                else {
                    print("\nERROR: No ha sido posible cargar el pdf remoto\n")
                }
            }
            
        }
    }
    
    
    
    
}


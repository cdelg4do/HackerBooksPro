//
//  PdfViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit

import CoreData     // para usar NSManagedObjectContext


class PdfViewController: UIViewController {
    
    //MARK: Propiedades
    
    var currentBook: Book
    var context: NSManagedObjectContext
    
    
    //MARK: Referencia a los objetos de la interfaz
    @IBOutlet weak var pdfWebView: UIWebView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var viewNoteButton: UIBarButtonItem!
    @IBOutlet weak var newNoteButton: UIBarButtonItem!
    
    
    //MARK: Inicializadores
    
    init(currentBook: Book, context: NSManagedObjectContext) {
        
        self.currentBook = currentBook
        self.context = context
        
        super.init(nibName: "PdfViewController", bundle: nil)
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
        
        syncViewFromModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    
    
    //MARK: Acciones al pulsar los botones de la ventana
    
    // Función que muestra la nota asociada a la página actual
    @IBAction func showNote(_ sender: AnyObject) {
        
        
    }
    
    
    // Función que crea una nueva nota asociada a la página actual
    @IBAction func createNote(_ sender: AnyObject) {
        
        
    }
    
    
    
    //MARK: Funciones auxiliares
    
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
            
            pdfWebView.load( pdfData as! Data, mimeType: "application/pdf", textEncodingName: "utf-8", baseURL: URL(string: ".")! )
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
                    
                    self.currentBook.pdf?.pdfData = downloadedData as NSData?
                }
                else {
                    print("\nERROR: No ha sido posible cargar el pdf remoto\n")
                }
            }
            
        }
    }
    
    
    
    
}


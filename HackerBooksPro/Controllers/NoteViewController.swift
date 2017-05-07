//
//  NoteViewController.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 01/10/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import UIKit

import CoreData     // para usar NSManagedObjectContext


class NoteViewController: UIViewController {
    
    //MARK: Propiedades
    
    var isNewNote: Bool
    var currentNote: Note
    var bookTitle: String
    var context: NSManagedObjectContext
    
    
    
    //MARK: Referencia a los objetos de la interfaz
    //@IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var mapButton: UIBarButtonItem!
    
    
    
    //MARK: Inicializadores
    
    init(currentNote: Note, bookTitle: String, isNewNote: Bool, context: NSManagedObjectContext) {
        
        self.isNewNote = isNewNote
        
        self.currentNote = currentNote
        self.bookTitle = bookTitle
        self.context = context
        
        super.init(nibName: "NoteViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    //MARK: Eventos del ciclo de vida de la vista
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isNewNote {
            
            // Usar la siguiente línea para que automáticamente pregunte seleccionar todo el texto
            //textView.selectAll(self)
            
            // Actualizar la ubicación en pantalla tras 5 segundos
            // (porque inmediatamente después de crearse la nota aún no ha dado tiempo a hacer la geolocalización inversa)
            let delayInNanoSeconds = UInt64(5) * NSEC_PER_SEC
            let time = DispatchTime.now() + Double(Int64(delayInNanoSeconds)) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: time, execute: { self.syncLocationFromModel() } )
            self.addressLabel.text = "Getting current address..."
            
            mapButton.isEnabled = false
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textView.layer.borderWidth = 1
        self.textView.layer.borderColor = UIColor.gray.cgColor
        
        //title = self.bookTitle
        //self.navigationController?.navigationBar.backItem?.title = "Back to PDF"
        syncViewFromModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        syncModelFromView()
    }
    
    
    
    //MARK: Acciones al pulsar los botones de la vista
    
    // Acción al pulsar el botón de imagen
    @IBAction func showPicture(_ sender: AnyObject) {
        
        // Crear un PhotoViewController asociado a esa nota, y mostrarlo
        let photoVC = PhotoViewController(currentNote: currentNote, context: context)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Save",
                                                           style: UIBarButtonItemStyle.plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationController?.pushViewController(photoVC, animated: true)
    }
    
    // Acción al pulsar el botón de mapa
    @IBAction func showMap(_ sender: AnyObject) {
        
        // Crear un NoteMapViewController asociado a esa nota, y mostrarlo
        let mapVC = NoteMapViewController(currentNote: currentNote)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back",
                                                           style: UIBarButtonItemStyle.plain,
                                                           target: nil,
                                                           action: nil)
        
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    // Acción al pulsar el botón de borrar
    @IBAction func deleteNote(_ sender: AnyObject) {
        
        print("\nEliminando la nota actual...\n")
        
        context.delete(currentNote)
        try! context.save()
        
        let _ = navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: Funciones auxiliares
    
    // Función para actualizar la vista con los datos de la nota
    func syncViewFromModel() {
        
        title = "Note at page \(currentNote.page)"
        self.textView.text = currentNote.text
        self.createdLabel.text = "Created: " + Utils.dateToString(currentNote.creationDate!)
        
        if (!isNewNote) {
            syncLocationFromModel()
        }
    }
    
    
    // Función para actualizar solo la ubicación
    func syncLocationFromModel() {
        
        if currentNote.hasLocation  {
            
            self.addressLabel.text = "Address: " + (currentNote.location?.address!)!
            mapButton.isEnabled = true
        }
        else {
            self.addressLabel.text = "Address: Unknown"
            mapButton.isEnabled = false
        }
    }
    
    
    // Función para actualizar el modelo con los datos de la vista
    // (solo actualizamos el texto y la fecha de última modificación)
    func syncModelFromView() {
        
        currentNote.text = self.textView.text
        currentNote.modificationDate = NSDate()
    }
    
}

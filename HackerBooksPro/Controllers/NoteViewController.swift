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
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var modifiedLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    
    
    
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
            textView.selectAll(self)
            isNewNote = false
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.textView.layer.borderWidth = 1
        self.textView.layer.borderColor = UIColor.gray.cgColor
        
        title = self.bookTitle
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
        //let photoVC = PhotoViewController(currentNote: currentNote, bookTitle: bookTitle, context: context)
        //navigationController?.pushViewController(photoVC, animated: true)
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
        
        let formatter = DateFormatter()
        //formatter.dateStyle = .medium
        //formatter.timeStyle = "HH:mm"
        formatter.dateFormat = "dd/MM/yyyy hh:mm"
        
        self.pageLabel.text = "  Page: \(currentNote.page)"
        self.createdLabel.text = "  Created: " + formatter.string(from: currentNote.creationDate as! Date)
        self.modifiedLabel.text = "  Modified: " + formatter.string(from: currentNote.modificationDate as! Date)
        self.textView.text = currentNote.text
    }
    
    
    // Función para actualizar el modelo con los datos de la vista
    func syncModelFromView() {
        
        currentNote.text = self.textView.text
        currentNote.modificationDate = NSDate()
    }
    
}

//
//  Note+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import Foundation
import CoreData

@objc(Note)
public class Note: NSManagedObject {
    
    // Nombre que corresponde a la entidad de esta clase en el modelo
    static let entityName = "Note"
    
    
    // Inicializador de la clase
    // (de conveniencia para que CoreData pueda utilizar los super.init() desde fuera)
    convenience init(book: Book, page: Int32, minContext context: NSManagedObjectContext) {
        
        // Obtenemos la entidad correspondiente al nombre anterior
        let ent = NSEntityDescription.entity(forEntityName: Note.entityName, in: context)!
        
        // Crear una nueva entidad del tipo obtenido, en el contexto
        self.init(entity: ent, insertInto: context)
        
        // Asignar valores iniciales a las propiedades
        self.book = book
        self.page = page
        self.creationDate = NSDate()
        self.modificationDate = NSDate()
        
        // Creamos una imagen vacía y la guardamos en la nota
        self.photo = Photo(note: self, inContext: context)
    }

}


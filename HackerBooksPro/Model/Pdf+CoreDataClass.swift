//
//  Pdf+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import Foundation
import CoreData

@objc(Pdf)
public class Pdf: NSManagedObject {
    
    // Nombre que corresponde a la entidad de esta clase en el modelo
    static let entityName = "Pdf"
    
    
    // Inicializador de la clase, inicialmente sin UIImage (para los libros cuyo PDF aún no fue descargado)
    // (de conveniencia para que CoreData pueda utilizar los super.init() desde fuera)
    convenience init(url: String, inContext context: NSManagedObjectContext) {
        
        // Obtenemos del contexto la entity description correspondiente al nombre anterior
        let ent = NSEntityDescription.entity(forEntityName: Pdf.entityName, in: context)!
        
        // Crear una nueva entidad del tipo obtenido, en el contexto
        self.init(entity: ent, insertInto: context)
        
        // Asignar la url indicada
        self.url = url
    }

}

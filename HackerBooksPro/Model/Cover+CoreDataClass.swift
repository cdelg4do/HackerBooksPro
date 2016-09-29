//
//  Cover+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//

import Foundation
import CoreData

import UIKit   // para usar UIImage


@objc(Cover)
public class Cover: NSManagedObject {
    
    // Nombre que corresponde a la entidad de esta clase en el modelo
    static let entityName = "Cover"
    
    // Propiedad computada para manejar la imagen como UIImage
    // (abstrayéndonos de la representación binaria interna del modelo, que es de tipo NSData)
    // De paso, eliminamos la dualidad entre Cocoa (NSData) y Swift (Data)
    
    var image: UIImage? {
        
        // El getter comprueba que los datos binarios de la imagen no estén vacíos (en cuyo caso devuelve nil).
        // Si no están vacíos, crea un nuevo UIImage a partir de los datos de photoData y lo devuelve.
        get {
            guard let data = coverData else {
                return nil
            }
            
            return UIImage(data: data as Data)!
        }
        
        // El setter comprueba que el valor asignado (newValue) no sea nil (en cuyo caso lo almacena sin más).
        // Si newValue no es nil, lo convierte en la representación binaria de un JPEG (Data) y la almacena como NSData.
        set {
            guard let img = newValue else {
                self.coverData = nil
                return
            }
            
            coverData = UIImageJPEGRepresentation(img, 1.0) as NSData?
        }
    }
    
    
    // Inicializador de la clase, inicialmente sin UIImage (para los libros cuya portada aún no fue descargada)
    // (de conveniencia para que CoreData pueda utilizar los super.init() desde fuera)
    convenience init(url: String, inContext context: NSManagedObjectContext) {
        
        // Obtenemos del contexto la entity description correspondiente al nombre anterior
        let ent = NSEntityDescription.entity(forEntityName: Cover.entityName, in: context)!
        
        // Crear una nueva entidad del tipo obtenido, en el contexto
        self.init(entity: ent, insertInto: context)
        
        // Asignar la url indicada
        self.url = url
    }

}

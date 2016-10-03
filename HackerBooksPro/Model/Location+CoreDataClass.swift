//
//  Location+CoreDataClass.swift
//  HackerBooksPro
//
//  Created by Carlos Delgado on 28/09/16.
//  Copyright © 2016 KeepCoding. All rights reserved.
//

import Foundation
import CoreData

import CoreLocation

@objc(Location)
public class Location: NSManagedObject {
    
    // Nombre que corresponde a la entidad de esta clase en el modelo
    static let entityName = "Location"
    
 /*
    // Inicializador de la clase
    // (de conveniencia para que CoreData pueda utilizar los super.init() desde fuera)
    convenience init(latitude: Double, longitude: Double, address: String, inContext context: NSManagedObjectContext) {
        
        // Obtenemos la entidad correspondiente al nombre anterior
        let ent = NSEntityDescription.entity(forEntityName: Location.entityName, in: context)!
        
        // Crear una nueva entidad del tipo obtenido, en el contexto
        self.init(entity: ent, insertInto: context)
        
        // Asignar valores iniciales a las propiedades
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
 */
    
    // Inicializador de la clase
    // (de conveniencia para que CoreData pueda utilizar los super.init() desde fuera)
    convenience init(location: CLLocation, forNote note: Note, inContext context: NSManagedObjectContext) {
        
        // Obtenemos la entidad correspondiente al nombre anterior
        let ent = NSEntityDescription.entity(forEntityName: Location.entityName, in: context)!
        
        // Crear una nueva entidad del tipo obtenido, en el contexto
        self.init(entity: ent, insertInto: context)
        
        // Asignar valores iniciales a las propiedades
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        addToNote(note)
        
        // Dirección correspondiente a esas coordenadas
        let coder = CLGeocoder()
        coder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            print("\nCalculando dirección para coordenadas (lat: \(self.latitude), long: \(self.longitude)...\n")
            
            self.address = "<Unknown address>"
            
            if error != nil {
                print("\nERROR: No ha sido posible realizar la geolocalización inversa\n" + (error?.localizedDescription)!)
                return
            }
            
            if let placemarks = placemarks, let placemark = placemarks.last {
                
                if let lines: Array<String> = placemark.addressDictionary?["FormattedAddressLines"] as? Array<String> {
                    
                    self.address = lines.joined(separator: ", ")
                }
                else {
                    print("\nERROR: No fue posible hallar una dirección para las coordenadas dadas\n")
                    return
                }
            }
            else {
                print("\nERROR: No fue posible hallar una dirección para las coordenadas dadas\n")
                return
            }
        })
        
    }
    
}



